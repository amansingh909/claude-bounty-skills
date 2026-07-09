# assets/ — your own-asset registry

Declare the apps **you own or are explicitly authorized to test** here, one
markdown file per app. The skills (especially `self-audit`) read these files for
standing context so you don't re-paste your stack every time.

## Privacy: your real files never get committed

`.gitignore` tracks **only** `EXAMPLE.md` and this `README.md`. Every other
`assets/*.md` is ignored, so your real asset files — real domains, admin
endpoints, auth notes — stay on your machine and are never pushed to the public
repo. Verify anytime with `git check-ignore assets/yourapp.md`.

## Format

Copy `EXAMPLE.md` to `assets/<yourapp>.md` and fill it in. Fields:

| Field | Meaning |
|-------|---------|
| `name` | short handle for the app |
| `domain` | primary domain |
| `scope` | list of things you own/authorize (wildcards ok) |
| `out_of_scope` | anything to explicitly avoid |
| `tech` | stack — drives which vuln classes `self-audit` prioritizes |
| `backend` | managed backend + how to introspect it read-only (e.g. Supabase project + MCP) — enables `self-audit`'s deep first-party pass |
| `auth` | how auth works, notable panels/roles |
| `notes` | free-form: past findings, areas of concern, things to re-check |

Below the frontmatter you can also keep a **findings ledger** — a table
`self-audit` reads at the start of each run and updates at the end (open / fixed /
accepted-risk), so audits compound instead of restarting cold. See `EXAMPLE.md`
for the shape. Like everything outside `EXAMPLE.md`, it stays local and is never
committed.

## Authorization

Only register assets you own or are explicitly authorized to test. This registry
is for **defensive** self-review — finding and fixing issues in your own apps.
