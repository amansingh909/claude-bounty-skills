---
name: acme
domain: acme.example
scope: ["*.acme.example"]
out_of_scope: ["blog.acme.example", "status.acme.example"]
tech: [Next.js, Supabase, Vercel]
backend: Supabase project acme-prod — connect via Supabase MCP for read-only introspection (advisors, grants, RLS, function source)
auth: email+password; admin panel at admin.acme.example; roles user/admin
notes: |
  Re-check IDOR on /api/invoices/{id} after the March refactor.
  Confirm Supabase RLS on the `orders` and `profiles` tables.
  Watch for exposed keys in the Vercel build output.
---

# acme (example asset)

This is a **fictional** template. Copy it to `assets/<yourapp>.md` (which git
ignores) and replace every value with your own app's real details. Nothing you
put in a non-EXAMPLE file is ever committed.

Free-form notes below the frontmatter are for your own context — past findings,
suspicious areas, endpoints you keep meaning to test.

## Findings ledger

`self-audit` reads this table at the start of a run and updates it at the end, so
each audit builds on the last instead of starting cold. Statuses: `open`,
`fixed`, `accepted-risk` (note *why*). Like the rest of a non-EXAMPLE asset file,
it stays local and is never committed.

| id | finding | CWE | severity | status | evidence | fixed |
|----|---------|-----|----------|--------|----------|-------|
| F-1 | anon `EXECUTE` on `set_org_plan` (RLS bypass) | CWE-862 | Critical | fixed | grant + function source | 2026-07-09 |
| F-2 | missing CSP / session cookie without `Secure` | CWE-693 | Medium | open | response headers | — |
| F-3 | `lodash` pinned to a version with a known prototype-pollution CVE | CWE-1035 | Medium | accepted-risk | `npm audit` — not reachable from the exposed API | — |
