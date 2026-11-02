# Noms de domaine

`info-droid.com` est le domaine principal (GitHub Pages) ; `info-droid.fr` redirige vers lui.

## DNS — état vérifié le 13/10/2026 (`.com` chez OVH, NS `dns20.ovh.net` / `ns20.ovh.net` ; `.fr` chez Cloudflare)

`info-droid.com` (servi par GitHub Pages, certificat Let's Encrypt couvrant `info-droid.com` + `www.info-droid.com`, HTTPS forcé) :
- Apex : 4 `A` `185.199.108-111.153` + 4 `AAAA` `2606:50c0:8000-8003::153` (IP GitHub Pages).
- `www` : `CNAME steevanb.github.io.`
- Pas de wildcard (`*.info-droid.com` ne résout pas).
- `MX` : `mx3.mail.ovh.net` / `mx4.mail.ovh.net`. SPF `v=spf1 -all` (aucun envoi de mail depuis `@info-droid.com`), DMARC `_dmarc` `v=DMARC1; p=reject`.
- `TXT` `_github-pages-challenge-steevanb` = `9cce00125caa946aa3065d93f9692e` : vérification du domaine dans les réglages Pages du compte GitHub (https://github.com/settings/pages, statut « Verified »). À conserver, sinon GitHub retire la vérification et le domaine peut être revendiqué par un autre compte.
- Redirections : `http://info-droid.com`, `http://www.info-droid.com` et `https://www.info-droid.com` → 301 vers `https://info-droid.com/` (chemin conservé). `https://info-droid.com` → 200.

`info-droid.fr` (non géré par GitHub Pages, un seul domaine personnalisé par site) — **DNS chez Cloudflare** (compte gratuit, plan Free) depuis le 13/10/2026 : NS `patryk.ns.cloudflare.com` / `teresa.ns.cloudflare.com` déclarés chez OVH (registrar, onglet « Serveurs DNS » → « Utiliser mes propres DNS »). Toute modif DNS du `.fr` se fait dans Cloudflare, plus dans OVH (l'ancienne zone OVH reste en sauvegarde mais n'est plus servie). DNSSEC désactivé.
- Apex, `www` et `*` : `A 213.186.33.5` en **Proxied** (l'IP n'est jamais contactée) + Redirect Rule Cloudflare « All incoming requests » → `concat("https://info-droid.com", http.request.uri.path)`, 301, query string conservée.
- HTTP et HTTPS fonctionnent sur tous les hôtes (certificat Cloudflare/Let's Encrypt `info-droid.fr` + `*.info-droid.fr`) : `https://foo.info-droid.fr/packagist-stats.html?a=1` → `https://info-droid.com/packagist-stats.html?a=1`.
- Mail (tous en **DNS only**, à conserver) : service MX Plan OVH, `MX` `mx0` (1) / `mx1` (5) / `mx2` (50) / `mx3` (100) / `mx4` (200) `.mail.ovh.net`, SPF `v=spf1 include:mx.ovh.com ~all`, DKIM (`ovhmo1372126-selector1._domainkey` → `ovhmo1372126-selector1._domainkey.1844146.lu.dkim.mail.ovh.net`, `ovhmo1372126-selector2._domainkey` → `ovhmo1372126-selector2._domainkey.1844145.lu.dkim.mail.ovh.net`), DMARC `_dmarc` `v=DMARC1; p=none; rua=mailto:contact@info-droid.fr` (mode observation), `pop3` en `CNAME ns0.ovh.net.`. Si OVH régénère ses enregistrements mail (DKIM, MX…), il faut les recopier à la main dans Cloudflare.

## Reste à faire

1. Supprimer la redirection web OVH de `info-droid.fr` (manager OVH, onglet « Redirection ») : plus utilisée depuis le passage à Cloudflare.
2. Revérifier la redirection `.fr` (HTTP/HTTPS, apex, `www`, sous-domaine) après expiration des caches DNS (TTL 1 h après le 13/10/2026 12h16).
3. Passer le DMARC du `.fr` de `p=none` à `p=quarantine` après quelques semaines de rapports propres.
4. Supprimer les `MX` du `.com` (`mx3`/`mx4.mail.ovh.net`, aucun service mail rattaché) ou les remplacer par un null MX (`MX 0 .`).
5. Optionnel : activer DNSSEC (Cloudflare pour le `.fr`, OVH pour le `.com`).

## Pièges

- Ne jamais réactiver la redirection web OVH ni remettre les NS OVH sur `info-droid.fr` : elle ne gère pas le HTTPS. La redirection passe par Cloudflare.
- Ne pas supprimer le `TXT` `_github-pages-challenge-steevanb` du `.com` : GitHub retirerait la vérification du domaine.
