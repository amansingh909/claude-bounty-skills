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
