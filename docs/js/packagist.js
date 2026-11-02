// Récupère les paquets Packagist d'un vendor, triés par nombre total de téléchargements décroissant
function fetchPackagistPackages(vendor) {
    function getJson(url) {
        return fetch(url).then(function (response) {
            if (!response.ok) {
                throw new Error(url + ' : HTTP ' + response.status);
            }

            return response.json();
        });
    }

    // Le statut "abandoned" est pris dans list.json : packages/<nom>.json est mis en cache jusqu'à 12 h par le CDN Packagist
    return getJson('https://packagist.org/packages/list.json?vendor=' + encodeURIComponent(vendor) + '&fields[]=abandoned')
        .then(function (data) {
            return Promise.all(Object.keys(data.packages).map(function (name) {
                return getJson('https://packagist.org/packages/' + name + '.json')
                    .then(function (packageData) {
                        return Object.assign({}, packageData.package, {abandoned: data.packages[name].abandoned});
                    })
                    .catch(function () {
                        return null;
                    });
            }));
        })
        .then(function (packages) {
            return Promise.all([packages, fetchGithubPublicRepositories(vendor)]);
        })
        .then(function (results) {
            var githubPublicRepositories = results[1];

            return groupRenamedPackages(
                vendor,
                results[0].filter(function (package_) {
                    return package_ !== null;
                })
            )
                .filter(function (package_) {
                    return !isPrivateGithubRepository(vendor, package_.repository, githubPublicRepositories);
                })
                .sort(function (package1, package2) {
                    return package2.downloads.total - package1.downloads.total;
                });
        });
}

// Regroupe les paquets renommés sous leur nom actuel, en additionnant les téléchargements.
// Un paquet est un ancien nom s'il est abandonné au profit d'un autre paquet du vendor,
// ou si son dépôt porte le nom d'un autre paquet du vendor (ex. php-typed-array → php-collection).
function groupRenamedPackages(vendor, packages) {
    var packagesByName = {};
    packages.forEach(function (package_) {
        packagesByName[package_.name] = package_;
    });

    function getNewName(package_) {
        if (typeof package_.abandoned === 'string' && packagesByName[package_.abandoned]) {
            return package_.abandoned;
        }

        var repositoryName = vendor + '/' + String(package_.repository || '').replace(/\.git$/, '').split('/').pop();

        return repositoryName !== package_.name && packagesByName[repositoryName] ? repositoryName : null;
    }

    function getCurrentName(package_) {
        var visited = {};
        while (getNewName(package_) !== null && !visited[package_.name]) {
            visited[package_.name] = true;
            package_ = packagesByName[getNewName(package_)];
        }

        return package_.name;
    }

    var groups = {};
    packages.forEach(function (package_) {
        var currentName = getCurrentName(package_);
        if (!groups[currentName]) {
            groups[currentName] = Object.assign({}, packagesByName[currentName], {
                downloads: {total: 0, monthly: 0, daily: 0},
                previousNames: []
            });
        }

        var group = groups[currentName];
        group.downloads.total += package_.downloads.total;
        group.downloads.monthly += package_.downloads.monthly;
        group.downloads.daily += package_.downloads.daily;
        if (package_.name !== currentName) {
            group.previousNames.push(package_.name);
        }
    });

    return Object.keys(groups).map(function (name) {
        return groups[name];
    });
}

// Noms (en minuscules) des dépôts GitHub publics d'un utilisateur, ou null si l'API GitHub ne répond pas.
// Un seul appel (100 dépôts max) pour ménager la limite de 60 requêtes/heure de l'API GitHub sans authentification.
function fetchGithubPublicRepositories(user) {
    return fetch('https://api.github.com/users/' + encodeURIComponent(user) + '/repos?per_page=100')
        .then(function (response) {
            if (!response.ok) {
                throw new Error('GitHub : HTTP ' + response.status);
            }

            return response.json();
        })
        .then(function (repositories) {
            return repositories.map(function (repository) {
                return repository.name.toLowerCase();
            });
        })
        .catch(function () {
            return null;
        });
}

// Dépôt github.com/<user>/* absent de la liste des dépôts publics : passé en privé (ou supprimé),
// Packagist ne le met plus à jour mais conserve le paquet. Sans réponse de GitHub, rien n'est considéré privé.
function isPrivateGithubRepository(user, repositoryUrl, githubPublicRepositories) {
    var matches = new RegExp('^https?://github\\.com/' + user + '/([^/]+?)(\\.git)?/?$', 'i').exec(repositoryUrl || '');

    return githubPublicRepositories !== null
        && matches !== null
        && githubPublicRepositories.indexOf(matches[1].toLowerCase()) === -1;
}

// Date (au jour près) du dernier téléchargement d'un ou plusieurs paquets (nom actuel + anciens noms), ou null si jamais téléchargé.
// Packagist ne fournit pas l'heure exacte, seulement des stats journalières.
function fetchPackagistLastDownloadDate(names) {
    return Promise.all(names.map(function (name) {
        return fetch('https://packagist.org/packages/' + name + '/stats/all.json?average=daily&from=2012-01-01')
            .then(function (response) {
                if (!response.ok) {
                    throw new Error(name + ' : HTTP ' + response.status);
                }

                return response.json();
            })
            .then(function (stats) {
                var values = stats.values[name] || [];
                for (var index = values.length - 1; index >= 0; index--) {
                    if (values[index] > 0) {
                        return stats.labels[index];
                    }
                }

                return null;
            });
    }))
        .then(function (dates) {
            var lastDate = dates
                .filter(function (date) {
                    return date !== null;
                })
                .sort()
                .pop();

            return lastDate === undefined ? null : new Date(lastDate + 'T00:00:00');
        });
}

function formatNumber(number) {
    return number.toLocaleString('fr-FR');
}
