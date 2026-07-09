# Example: recon-triage

Turning a wall of live-host output into a focused shortlist — reasoning only
from signals present in the data, never inventing hosts or vulnerabilities.

## Input

```
www.shopcorp.com        [200] [ShopCorp - Home] [nginx]
cdn.shopcorp.com        [200] [static] [cloudflare]
api.shopcorp.com        [401] [Unauthorized] [nginx]
staging.shopcorp.com    [200] [ShopCorp Staging] [nginx] [PHP/7.2.1]
jenkins.shopcorp.com    [403] [Forbidden] [Jetty]
blog.shopcorp.com       [200] [Welcome to nginx!] [nginx]
mail.shopcorp.com       [200] [Webmail] [nginx] :8443
```

## Output

```
Top targets to look at first:
1. staging.shopcorp.com — non-prod host (weaker auth / debug), and the data
   shows PHP/7.2.1, an outdated version worth checking for known issues.
2. jenkins.shopcorp.com — internal CI tooling exposed; 403 suggests an auth
   boundary worth probing for misconfig or unauthenticated endpoints.
3. api.shopcorp.com — 401 auth boundary on the API; APIs are high-value surface
   (authz flaws, IDOR). Boring name, but obvious attack surface.
4. mail.shopcorp.com — webmail on a non-standard port (:8443); forgotten/less-
   hardened services often live off-port.
5. blog.shopcorp.com — default "Welcome to nginx!" title on a live host suggests
   an unfinished or forgotten deploy behind it.

Lower priority / likely noise:
- www.shopcorp.com — main marketing site, standard.
- cdn.shopcorp.com — Cloudflare-fronted static CDN, low value.

Notes: PHP/7.2.1 on staging is the only version string in the data — everything
else is inferred from naming/status/port, not from confirmed software, and none
of these is confirmed vulnerable. This is a priority list, not a findings list.
```

Nothing here claims a bug exists — only where your manual attention is most
likely to pay off, with the specific signal behind each pick.
