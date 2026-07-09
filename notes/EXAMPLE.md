---
program: acme-bounty
platform: HackerOne
scope_ref: "*.acme.example in scope; blog.acme.example out of scope"
started: 2026-07-01
---

# acme-bounty — engagement log

This is a **fictional** template. Copy it to `notes/<program>.md` (git ignores it)
and let the skills keep it current. Nothing outside `EXAMPLE.md` is ever committed.

## Log

- **2026-07-01 — recon-triage.** 412 httpx hosts → shortlisted 6. Top:
  `admin-dev.acme.example` (non-prod admin, 401) and `api.acme.example` (large
  surface, versioned routes).
- **2026-07-02 — scope-check.** `admin-dev.acme.example` → ✅ in scope (matches
  `*.acme.example`, no exclusion). `blog.acme.example` → ❌ out (explicit exclusion).
- **2026-07-03 — report-writer.** Drafted IDOR report on `/api/invoices/{id}`
  (verified with two of my own accounts). Saved to `reports/idor-invoices.md`.
- **2026-07-06 — triage-responder.** Program set "Needs More Info" → replied with
  the cross-account request/response pair. Awaiting re-triage.

## Findings

| id | finding | asset | CWE | severity | status |
|----|---------|-------|-----|----------|--------|
| A-1 | IDOR on `/api/invoices/{id}` | api.acme.example | CWE-639 | High | reported (NMI) |
| A-2 | non-prod admin panel exposed | admin-dev.acme.example | CWE-284 | Medium | investigating |
