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

    return getJson('https://packagist.org/packages/list.json?vendor=' + encodeURIComponent(vendor))
        .then(function (data) {
            return Promise.all(data.packageNames.map(function (name) {
                return getJson('https://packagist.org/packages/' + name + '.json')
                    .then(function (data) {
                        return data.package;
                    })
                    .catch(function () {
                        return null;
                    });
            }));
        })
        .then(function (packages) {
            return packages
                .filter(function (package_) {
                    return package_ !== null;
                })
                .sort(function (package1, package2) {
                    return package2.downloads.total - package1.downloads.total;
                });
        });
}

function formatNumber(number) {
    return number.toLocaleString('fr-FR');
}
