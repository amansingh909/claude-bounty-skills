# Example: `self-audit`

**You have an asset registered** (`assets/acme.md`, gitignored):

```yaml
name: acme
domain: acme.example
scope: ["*.acme.example"]
tech: [Next.js, Supabase, Vercel]
auth: email+password; admin panel at admin.acme.example; roles user/admin
```

**You say:** "self-audit acme"

---

**The skill responds — advisory plan first:**

> Plan for acme.example (Next.js + Supabase + Vercel):
>
> 1. **IDOR on `/api/*` id params** — Next.js API routes often trust the id.
>    Run as user A: `curl -s https://acme.example/api/invoices/1001 -H "Cookie: <A>"`
>    then request an id you know belongs to user B.
> 2. **Supabase RLS** — confirm you can't read rows you don't own.
>    Run: `curl -s 'https://acme.example/rest/v1/profiles?select=*' -H "apikey: <anon>"`
> 3. **Exposed secrets** — check the JS bundle / source maps for keys.
>    Run: `curl -s https://acme.example/_next/static/... | grep -iE "key|secret|token"`
> 4. **Security headers / cookie flags** (read-only) — `curl -sI https://acme.example`
>
> Items 1–4 above are read-only (GET/HEAD). Want me to run the read-only ones
> (2, 3, 4) now against your own asset? Item 1's cross-account check needs your
> two sessions, so I'll hand that to you.

**You say:** "yes, run the read-only ones"

---

**Active mode (own-asset, GET-only, rate-limited):**

> Ran (read-only):
> - `curl -sI https://acme.example` → missing `Content-Security-Policy`;
>   session cookie set without `Secure`. (observed in the response headers)
> - `curl -s '.../rest/v1/profiles?select=*' -H "apikey: <anon>"` → returned `[]`
>   (RLS appears to block anon reads — good).
> - bundle grep → no keys found in the checked file.
>
> **Needs your hands-on (non-GET / two sessions):**
> - IDOR check on `/api/invoices/{id}` — run the cross-account requests yourself.
>
> **Suggested fixes:**
> - Add a `Content-Security-Policy` header.
> - Set `Secure` (and `HttpOnly`, `SameSite`) on the session cookie.

---

**The deep pass — introspecting acme's own Supabase (read-only, since you own it):**

This is where the serious bugs live. Because you own the backend, you can read its
config as ground truth instead of guessing from outside.

> Connected the Supabase MCP for project `acme-prod` and read config read-only:
>
> - `get_advisors(security)` → 3 × `anon_security_definer_function_executable`.
> - Grants: `has_function_privilege('anon', 'public.set_org_plan(...)', 'EXECUTE')`
>   = true.
> - Read the body of `set_org_plan(p_org_id uuid, p_plan text, p_changed_by uuid)`:
>   `SECURITY DEFINER`, **no `auth.uid()`/`auth.role()` check**, and the actor is
>   the untrusted `p_changed_by` parameter → an unauthenticated caller can change
>   **any** org's plan and bypass RLS. (CWE-862.)
> - Matview `public.usage_report_6mo` has `SELECT` granted to `anon` → leaks per-org
>   figures **and** the `org_id` UUIDs `set_org_plan` needs. The two **chain** into
>   an unauthenticated write.
>
> Proven at the **grant + code level** (read-only) — nothing was mutated.
> Reachability confirmed with a non-mutating call (valid shape, non-existent UUID
> → normal result, not a `401`).

---

**Closing the loop — fix, regression test, re-verify (fix-first order):**

> **[Critical] Unauthenticated org-plan write via `set_org_plan` chain (CWE-862)**
>
> **Fix:**
> ```sql
> REVOKE EXECUTE ON FUNCTION public.set_org_plan(uuid, text, uuid) FROM anon;
> -- and inside the function, derive the actor from auth.uid() instead of p_changed_by
> ```
> Move `usage_report_6mo` behind an RLS-protected `security_invoker` view.
>
> **Regression test** (pgTAP — fails now, passes after the fix):
> ```sql
> select is(
>   has_function_privilege('anon', 'public.set_org_plan(uuid, text, uuid)', 'EXECUTE'),
>   false,
>   'anon must not be able to EXECUTE set_org_plan'
> );
> ```
> Run in CI so the grant can never silently come back.
>
> **Re-verify (after you apply the fix):** re-read
> `has_function_privilege('anon', 'public.set_org_plan(...)', 'EXECUTE')` → now
> `false`, and the pgTAP test above goes green. *Then* it's closed — not before.
>
> **[Medium] Missing CSP / cookie without `Secure` (CWE-693)** — add the header and
> the cookie flags; regression: a header-assertion test in the app's e2e suite.

**Ledger update** (`assets/acme.md`, local-only):

> | id | finding | CWE | severity | status | evidence | fixed |
> |----|---------|-----|----------|--------|----------|-------|
> | F-1 | anon `EXECUTE` on `set_org_plan` chain | CWE-862 | Critical | open → *fixed on re-verify* | grant + fn source | — |
> | F-2 | missing CSP / cookie `Secure` | CWE-693 | Medium | open | response headers | — |

---

Every finding above is tied to real config or a real response. The deep pass
proves broken authorization at the grant + code level **without mutating
anything**; the checks that need state you control (the IDOR, the plan-change
write) are handed back as deliberate steps rather than guessed; and each confirmed
issue ships with a fix, a **test that fails today and passes once fixed**, and a
read-only re-verify step — so the bug is closed *and* can't quietly return.

> This example uses Supabase, but the deep pass is the same shape on any stack —
> Firebase security rules, an ORM app's route-level ownership checks (Django /
> Rails / Node), GraphQL role permissions, or cloud IAM. The skill goes to
> whichever source of truth your backend keeps its authorization in.
