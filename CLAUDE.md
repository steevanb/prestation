# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Instructions

**RÈGLE CAPITALE — JAMAIS de demande de confirmation.**

- Ne jamais demander "tu veux que je le fasse ?", "je continue ?", "j'intègre lesquels ?", "à quel pourcentage ?". Pas de listes "à choisir".
- Quand l'utilisateur dit "propose / trouve / fais X", **prendre une décision soi-même** avec des défauts raisonnables et exécuter directement. L'utilisateur corrigera après si besoin.
- Quand plusieurs modifs sont listées dans un même message, toutes les enchaîner sans pause.
- Seules vraies exceptions autorisées : ambiguïté bloquante (l'action ne peut pas démarrer sans info manquante critique) ou opération destructive irréversible (rm -rf, force push, suppression de branche, etc.).
- Ne pas narrer ce qu'on s'apprête à faire avant de le faire ("Je vais maintenant…"). Faire, puis annoncer brièvement le résultat.
- Sortie texte en fin de tâche : 1 à 2 phrases max sur ce qui a changé. Pas de questions de relance.

# Projet

Site CV / vitrine de Steevan BARBOYON (InfoDroid) — `info-droid.fr`. Projet PHP statique servi par nginx + php-fpm.

## Démarrer en local

```bash
bin/start
```

Lance la stack docker-compose (`docker/docker-compose.yml`) qui build l'image `docker/web` (Ubuntu 18.04 + nginx + PHP 7.2-fpm) et monte la racine du repo dans `/var/www/prestation`. Site accessible sur `http://localhost:8083`.

## Livraison en production

```bash
delivery/site
```

Build l'image `docker/delivery` puis exécute `site.sh` à l'intérieur. Le script :
1. demande confirmation interactive,
2. demande un tag git,
3. clone ce tag depuis `git@github.com:info-droid/prestation.git`,
4. fait un `composer install --no-dev --classmap-authoritative`,
5. zippe et `scp` vers `infodroid@info-droid.fr:/data/www/prestation/delivery_<date>__tag_<tag>`,
6. bascule le symlink `current` et reload nginx.

Prérequis : copier deux clés SSH privées dans `docker/delivery/ssh/` :
- `github` — accès `git@github.com:info-droid/prestation.git`
- `server_site` — accès `infodroid@info-droid.fr`

Ce dossier est gitignoré.

## Architecture du site

Le site est une page unique `public/index.php` (HTML quasi statique, une seule balise PHP pour l'année du copyright) qui agrège plusieurs sections : à propos, compétences, expériences professionnelles, études, liens externes.

Deux endpoints PHP secondaires inclus en `<iframe>` ou utilisés via XHR :
- `public/github.php` — agrège l'activité GitHub publique de `steevanb`.
- `public/packagist-stats.php` — utilise `knplabs/packagist-api` (seule dépendance runtime).

Le menu de navigation et les blocs d'expériences ont une structure répétitive HTML — toute nouvelle expérience doit suivre exactement le format des `<div class="em clearfix">` existantes (icône `<i class="fa fa-briefcase">`, `<h3>` avec sous-titre `<span>`, paragraphe `<p>` descriptif, puis une série de `<div class="date">` : la première contient l'icône calendrier + dates, les suivantes contiennent les tags techno/rôle).

**Format des dates dans les expériences** : `Mois AAAA - Mois AAAA` avec capitales aux deux mois (ex. `Avril 2025 - Juin 2025`), ou `Depuis Mois AAAA` pour une mission en cours. Toujours respecter ce format pour rester cohérent.

## Pièges connus

- L'image de delivery historique (`php:7.4-cli-buster`) ne build plus : Debian buster est EOL depuis juin 2024 et ses dépôts retournent 404 sur `deb.debian.org`. Le Dockerfile a été migré vers `php:8.3-cli-bookworm`.
- L'image `docker/web` est sur Ubuntu 18.04 + PHP 7.2 (PPA `ondrej/php`) — vieille mais suffisante pour ce site quasi statique. Ne pas y toucher sans vérifier que le `composer install` au boot du conteneur fonctionne toujours avec les versions de dépendances actuelles.
- `vhost.conf` whiteliste explicitement les trois `.php` exposés (`index`, `github`, `packagist-stats`) — tout nouveau script PHP à exposer doit être ajouté à la regex.
