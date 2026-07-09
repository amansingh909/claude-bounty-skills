# Example: scope-check

A worked run showing the three verdict types, including the safety-first
"uncertain" behavior that keeps you in-bounds.

## Input

> **Program scope**
> In scope: `*.acme.com`, `acme.io` (apex only)
> Out of scope: `admin.acme.com`, anything under `internal.acme.com`, no
> automated scanning, no DoS
>
> Check: `api.acme.com`, `admin.acme.com`, `blog.acme.io`

## Output

```
Target: api.acme.com
Verdict: ✅ In scope
Reason: matches in-scope wildcard "*.acme.com"
Caveats: no automated scanning, no DoS — manual testing only

Target: admin.acme.com
Verdict: ❌ Out of scope
Reason: explicitly listed under out-of-scope ("admin.acme.com"); an exclusion
        overrides the *.acme.com wildcard

Target: blog.acme.io
Verdict: ⚠️ Uncertain
Reason: scope lists "acme.io (apex only)" — a subdomain like blog.acme.io is not
        clearly covered, and there is no *.acme.io wildcard
Action: confirm with the program whether acme.io subdomains are in scope before
        testing
```

Note the third verdict: rather than guessing "yes, it's a subdomain of an
in-scope domain," the skill flags the ambiguity. `acme.io` was listed *apex
only*, so a confident "in scope" could put you into unauthorized testing.
