# notes/ — your local engagement log

A gitignored workspace where the skills keep a running record of your work on a
target, so a new Claude session **picks up where the last one left off** instead of
starting cold — and so every generated doc has one safe, never-committed home.

## One file per engagement

Copy `EXAMPLE.md` to `notes/<program>.md` (git ignores it) and let the skills
maintain it as you work:

- `recon-triage` appends its shortlist and the signal behind each host,
- `scope-check` records each verdict with the deciding scope line,
- `report-writer` logs the reports it drafts,
- `triage-responder` logs the triage exchanges and outcomes.

For apps you own, `self-audit` keeps structured findings in `assets/<app>.md`; use
a notes log here for the session-by-session timeline across a whole program.

The skills **read the log at the start** of a session (that's the continuity — no
forgetting) and **append at the end** (that's the history). They only ever read a
log that already exists — they never invent past work.

## Privacy: nothing here is committed

`.gitignore` tracks **only** `EXAMPLE.md` and this `README.md`. Every other file
under `notes/` — real program names, live findings, drafted reports — stays on your
machine and is never pushed. Verify anytime with
`git check-ignore notes/yourprogram.md`. Common generated-doc locations
(`reports/`, `findings/`, `engagements/`, `*.local.md`) are ignored too, so a saved
report can't leak by accident.

## Format

Frontmatter (program, platform, scope reference, dates) + a timestamped log + a
findings/status table. See `EXAMPLE.md`.
