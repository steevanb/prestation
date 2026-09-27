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

Site CV / vitrine de Steevan BARBOYON (InfoDroid) — `info-droid.com` (`info-droid.fr` redirige vers le `.com`). Site 100 % statique (HTML/CSS/JS, aucun PHP) hébergé sur GitHub Pages.

## Démarrer en local

```bash
bin/start
```

Lance `python3 -m http.server` sur le répertoire `docs/`. Site accessible sur `http://localhost:8083`.

## Livraison en production

GitHub Pages sert la branche `master`, répertoire `/docs`, du dépôt `steevanb/prestation`. Chaque push/merge sur `master` est publié automatiquement, il n'y a aucun script de livraison.

- `docs/CNAME` contient le domaine personnalisé `info-droid.com` (le DNS pointe sur les IP GitHub Pages).
- `info-droid.fr` n'est pas géré par GitHub Pages (un seul domaine personnalisé par site) : la redirection vers `https://info-droid.com` est configurée chez le registrar.
- `docs/.nojekyll` désactive le traitement Jekyll.

## Architecture du site

Le site est une page unique `docs/index.html` qui agrège plusieurs sections : à propos, compétences, expériences professionnelles, études, liens externes. L'année du copyright est mise à jour en JS (`#copyrightYear`).

Pages secondaires :
- `docs/github.html` — inclus en `<iframe>` dans `index.html`, affiche le widget GitHub de `steevanb` (API GitHub appelée côté navigateur) avec le nombre de dépôts et de téléchargements Packagist dans le titre.
- `docs/packagist-stats.html` — statistiques détaillées de chaque paquet Packagist `steevanb/*`.

Les stats Packagist sont récupérées côté navigateur par `docs/js/packagist.js` (`fetchPackagistPackages()`) : `packages/list.json?vendor=steevanb` puis `packages/<nom>.json` pour chaque paquet (l'API Packagist autorise le CORS).

Le menu de navigation et les blocs d'expériences ont une structure répétitive HTML — toute nouvelle expérience doit suivre exactement le format des `<div class="em clearfix">` existantes (icône `<i class="fa fa-briefcase">`, `<h3>` avec sous-titre `<span>`, paragraphe `<p>` descriptif, puis une série de `<div class="date">` : la première contient l'icône calendrier + dates, les suivantes contiennent les tags techno/rôle).

**Format des dates dans les expériences** : `Mois AAAA - Mois AAAA` avec capitales aux deux mois (ex. `Avril 2025 - Juin 2025`), ou `Depuis Mois AAAA` pour une mission en cours. Toujours respecter ce format pour rester cohérent.

## Pièges connus

- Aucun code serveur possible : tout ce qui est dynamique doit passer par du JS côté navigateur et des API qui autorisent le CORS.
- Ne pas supprimer `docs/CNAME` : GitHub Pages perdrait le domaine personnalisé.
