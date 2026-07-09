# Example: triage-responder

Recovering a report that came back **Informative** — by sharpening the impact
argument with a concrete scenario, not by inflating it.

## Input

> **Original finding:** Reflected XSS on `search.acme.com/?q=` — payload
> `"><script>alert(document.domain)</script>` executes in the page context,
> unauthenticated.
>
> **Triager's response (status: Informative):** "Thanks for the report. This
> executes on a static marketing subdomain with no user session or sensitive
> functionality, so we're closing as Informative — limited security impact."
>
> **What I can substantiate:** The subdomain shares the parent cookie scope
> (`Domain=.acme.com`), and I confirmed the session cookie for the main app
> (`app.acme.com`) is *not* `HttpOnly`. I have the `Set-Cookie` response showing
> both.

## Output

> Hi, thanks for taking a look. I'd like to add impact context that I think
> changes the assessment.
>
> While `search.acme.com` is a marketing subdomain, its cookies are scoped to
> `Domain=.acme.com` — the same parent as the authenticated app at
> `app.acme.com`. I've confirmed (see attached `Set-Cookie` response) that the
> `app.acme.com` session cookie is not flagged `HttpOnly`.
>
> That means the reflected XSS here can read the main application's session
> cookie via `document.cookie` from a victim who is logged in and visits a
> crafted `search.acme.com/?q=` link, enabling session hijacking of the primary
> app — not just a self-contained alert on a static page.
>
> Happy to provide a full PoC that exfiltrates the cookie to a listener I
> control if that would help. Thanks again for your time.

*Attach:* the `Set-Cookie` response showing `Domain=.acme.com` without
`HttpOnly`, and (if requested) a working cookie-exfiltration PoC against your own
test session.

## What it does when you *don't* have stronger impact

If the user couldn't substantiate the cookie-scope angle — if the subdomain
really is isolated with no shared cookies and nothing sensitive — the skill
won't manufacture impact. It says so, and advises accepting the Informative
status rather than sending a pushback built on a claim you can't back up.
