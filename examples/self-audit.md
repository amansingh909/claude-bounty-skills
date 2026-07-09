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

Every observation above is tied to a real response — nothing is asserted that
wasn't seen. The IDOR check, which needs state you control, is handed back rather
than guessed.
