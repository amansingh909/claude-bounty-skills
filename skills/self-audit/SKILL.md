---
name: self-audit
description: Use when reviewing a web app you own or are explicitly authorized to test — a first-party, defensive security self-review that finds issues, helps you fix them, and writes the regression test so they can't come back. Symptoms: "audit my app", "check my own site for security issues", "self-audit my web app", "what should I test on my app", "review my app before others find bugs", "audit what changed in this PR", "did my fix actually work", "re-audit after fixing", pointing these skills at an asset in your own registry.
---

# self-audit

## Overview

You own an app and want to find (and fix) its security issues before someone
else does. Given an asset — from your `assets/` registry or pasted inline — this
skill runs a full defensive loop:

> **plan → prove (read-only) → prioritize → fix → regression-test → re-verify**

and records what it found in a ledger so the next audit starts where this one
left off.

It maps the stack to the checks most worth running, hands you a **prioritized,
concrete test plan**, and — if you opt in — runs the **read-only** subset against
your own asset. For anything it confirms, it doesn't stop at "here's a bug": it
ranks it by severity, proposes the fix, writes a **test that fails now and passes
once you fix it**, and (after you fix) re-introspects to confirm the fix landed.

This is the one skill in the repo that may *run* things. It does so only under
strict guardrails (below), and every claim it makes is tied to a response it
actually observed — so running checks makes the no-fabrication guarantee
*stronger*, not weaker.

## Authorization Gate (Critical)

Before issuing **any** request, confirm the target is one you own or are
explicitly authorized to test:

- If the target is in `assets/` (you declared it), that is the confirmation.
- If it was pasted inline and is not in the registry, ask the user to confirm
  ownership/authorization before running anything. Until then, stay advisory.

This skill is **defensive**: it exists to harden your own apps. It never targets
third-party assets without authorization, and it will decline to.

## Anti-Hallucination Rule (Critical)

Reason only from what you observe or are given:

- Do not invent endpoints, parameters, technologies, or versions not stated in
  the asset or seen in a real response.
- Do not claim a vulnerability you have not demonstrated. "Worth checking because
  X" until a real response confirms it, then "confirmed: here is the response."
- Do not claim a fix works because it *should* — claim it because you re-observed
  the config change and the regression test passed (see Close the Loop).
- If you lack the info to plan (unknown stack, no endpoints), ask — don't pad.

## Input

- An asset file from `assets/` (preferred), or an inline description: domain,
  tech stack, auth model, notable endpoints.
- Optionally, output the user already captured (curl/httpx responses) to interpret.
- Optionally, the asset's **prior findings ledger** (see below) — read it first so
  you re-check what was open and don't re-report what's already fixed or accepted.
- Optionally, a **diff / PR / changed-files list** to scope the audit to (see
  Audit-the-Diff Mode).

## Advisory Plan (default behavior)

Map the stack to the checks that matter, prioritized. Use signals actually
present in the asset:

| Stack / signal | Checks to prioritize |
|----------------|----------------------|
| REST/GraphQL API, `/api/*` with id params | IDOR / broken object-level authz — increment/swap ids across your own accounts |
| Role-based access (user/admin panels) | Broken function-level authz — request admin routes as a low-priv user |
| **Backend you own** (any stack — Supabase, Firebase, an ORM app, GraphQL, serverless) | **Introspect its authz config directly** — the highest-signal first-party check. Read the rules/grants/route-handlers as ground truth and find where a role can reach what it shouldn't. Per-stack specifics in the deep pass below. |
| Any deployed app | Exposed secrets (`.env`, keys in JS bundles, source maps), security headers, cookie flags |
| Auth flows | Session fixation, weak reset tokens, missing rate limits on login |
| File upload / rendering | Stored XSS, SSRF via URL fetchers, path traversal |

Output a tight, ordered plan. For each item: **what to check, why, and the exact
request** (e.g. a `curl` line). Keep it focused — the highest-signal checks for
*this* stack, not a generic OWASP dump.

## First-Party Deep Pass — introspect your own backend (highest signal)

Because it's *your* app, you can do what no black-box tester can: read the
backend's own authorization config as ground truth. This is where first-party
audits find the criticals that surface probing never will — broken authorization,
over-broad permissions, missing auth checks. **The principle is stack-agnostic:**
whatever the backend, enumerate *who can do what without proper authorization*,
read the authz rules/config/code directly, and find the gap between what a role
*should* reach and what it *can*. Prefer this pass whenever you can authenticate
to the backend (its console, management API/MCP, or the source/config repo).

Go to wherever your stack keeps its authorization — a few common ones:

- **Supabase / Postgres RLS** (Supabase MCP or a read-only DB connection):
  security advisors (`get_advisors`); `anon`/`authenticated` grants on tables &
  functions (`has_function_privilege`, `role_table_grants`); RLS status and
  `USING (true)`/`WITH CHECK (true)` policies; `anon`-executable
  `SECURITY DEFINER` functions with no `auth.uid()` check (actor passed as a
  spoofable parameter → RLS bypass); `anon`-readable views/matviews (matviews
  can't enforce RLS). These often *chain*.
- **Firebase / Firestore / Storage:** read your security rules — any
  `allow read, write: if true`, rules missing `request.auth != null`, or checks
  that trust client-supplied fields. Test against the Firebase emulator; review
  Storage rules separately from database rules.
- **App-layer authz** (Django, Rails, Laravel, Node/Express + Prisma/TypeORM, …):
  usually there's no RLS — the check lives in code. Read the route
  handlers/serializers: endpoints that fetch by id with no ownership/tenant filter
  (IDOR), admin routes missing a role check, mass-assignment letting a user set
  fields they shouldn't, ORM queries that forget to scope by the current user/org.
- **GraphQL** (Hasura, Apollo, PostGraphile): per-role field/row/column
  permissions, unauthenticated queries, whether introspection is exposed in prod,
  Hasura permission rules with `{}` (allow-all) filters.
- **Cloud / serverless** (AWS Amplify/AppSync, Lambda + API Gateway, Cloudflare
  Workers): IAM policies and resource grants (over-broad `*`), whether API Gateway
  authorizers are actually attached, AppSync resolver auth rules, public buckets.
- **Any backend:** enumerate IAM/role grants, default-open policies, admin
  endpoints, and secrets/keys reachable from the client bundle.

**Prove it safely.** Confirm findings at the **config/permission + code level**
(read-only introspection) rather than by mutating production. A non-mutating live
call — a syntactically valid request with a non-existent id that returns a normal
result instead of a `401`/permission error — confirms *reachability* without
changing any state. Introspection queries stay `SELECT`/inspection only (see the
query-layer guardrail below). Never run a call that could write to prod as part
of the audit; hand those to the user as deliberate, advisory steps.

## First-Party-Only Checks — the owner's unfair advantage

The deep pass reads your backend's authz config; these are the *other* checks a
black-box tester can't run, because they don't have what you have — the repo, the
pipeline, the dependency tree. High signal, mostly read-only, and routinely
missed because attack-surface tools never see them:

| You have | Check | Read-only tooling |
|----------|-------|-------------------|
| The git repo | **Secrets in history** — a key committed once and "removed" later still lives in history | `gitleaks detect`, `trufflehog git file://.` |
| The dependency tree | **Known-CVE dependencies** — one of the most common real-world breach vectors | `npm audit`, `pip-audit`, `osv-scanner`; inspect lockfiles |
| The CI/CD config | **Pipeline misconfig** — `pull_request_target` running untrusted code, over-scoped `GITHUB_TOKEN`/`permissions`, secrets echoed to logs, deploy creds in plaintext | read `.github/workflows/*` and other CI config |
| The IaC | **Cloud misconfig** — public buckets, `0.0.0.0/0` ingress, wildcard IAM, unencrypted stores | read Terraform/CloudFormation/Pulumi; never `apply` |
| The app logic | **Business-logic flaws** — TOCTOU races on balances/coupons/inventory, negative quantities, price/qty tampering, replayable one-time actions | read the handler; reason about concurrent and edge inputs |

You *find* these by reading your own source — no live traffic needed. Where one
needs a live check to confirm, it obeys the same read-only rule as everything
else, and a state-changing confirmation is handed back as an advisory step.

## Severity & Prioritization

Don't hand back a flat list — rank each finding so the user knows what to fix
first, using the same model as [`report-writer`](../report-writer/SKILL.md) to
keep the repo consistent:

- **Severity** from data sensitivity × auth required × blast radius ×
  preconditions. Unauthenticated + any-user + sensitive data → Critical;
  self-only + non-sensitive + rare config → Low. State the reasoning; don't just
  assert a number.
- **Classify** with a CWE (e.g. CWE-862 missing authorization, CWE-639 IDOR,
  CWE-693 missing security control) so the fix and the regression test have a name.
- **Order** the output by fix-first priority (exploitability × impact), not by the
  order you happened to find things.

If the user then wants to file this somewhere (an internal ticket, a coordinated
disclosure), hand off to `report-writer` — it takes the same finding and produces
the write-up.

## Audit-the-Diff Mode — continuous, not big-bang

A full-surface audit is heavy to run every time. When the user points you at a
**diff, PR, or changed-files list** (or asks to "audit what changed"), scope to
the delta: which checks above does *this change* actually touch? A new `/api/*`
route → IDOR/authz; a changed RLS policy or migration → re-run the deep pass on
those objects; a new dependency → CVE check; an edited workflow → pipeline
misconfig. This makes self-audit a pre-commit / pre-deploy gate, not only a
periodic sweep. Cross-check the delta against the findings ledger so a regression
in a previously-fixed area is flagged loudly.

## Opt-In Active Mode (guardrails)

After presenting the plan, offer to run the read-only subset yourself. If the
user accepts, obey ALL of these:

- **Own-asset-only:** target passed the Authorization Gate above.
- **Read-only (HTTP):** `GET`/`HEAD` only. Never `POST`/`PUT`/`PATCH`/`DELETE`,
  never a payload meant to change state. A check that needs a non-GET request is
  handed back as an advisory step for the user to run deliberately — you do not
  run it.
- **Read-only (query layer):** backend introspection through an MCP or DB
  connection is `SELECT`/inspection **only** — never `INSERT`/`UPDATE`/`DELETE`/
  `ALTER`/`DROP`/`CREATE`/`GRANT`, even on your own asset. The HTTP rule governs
  requests; this governs SQL and management APIs. Anything that could write to
  prod stays advisory-only.
- **Backend introspection (own asset):** authenticated *read-only* management/DB
  introspection of your own backend — advisors, schema, grants, RLS status,
  function source — is allowed and is the preferred way to prove a finding. It
  changes nothing.
- **Rate-limited:** pace requests conservatively; never hammer production.
- **Evidence-bound:** report only what a response actually showed; quote/cite it.

Then interpret: what each response means, which checks are clear, which need the
user to run the non-GET follow-up.

## Close the Loop — fix, regression test, re-verify

Finding a bug is half the job; a defensive audit's real output is *fixed, and
can't-come-back*. For every **confirmed** finding, offer the full triad:

1. **Fix** — the concrete change, specific to what was seen: the
   `REVOKE EXECUTE … FROM anon`, the missing ownership/tenant filter, the
   `request.auth != null` rule, the security header, the pinned dependency version.
2. **Regression test** — a test that **fails against the current code and passes
   once the fix lands**, in the app's own stack: a pgTAP/SQL test asserting `anon`
   can't `EXECUTE` the function, an integration test where user A gets `403` on
   user B's object, a Firebase rules-emulator test, a CI check for the flagged
   dependency. Write it in the red state first — this is the anti-hallucination
   ethos applied to fixes: the passing test *is* the proof the fix works, and it
   stops the vuln from silently returning later.
3. **Re-verify** — after the user applies the fix, re-run the same read-only
   introspection/check and confirm the change actually took effect ("re-read
   `has_function_privilege('anon', …)` → now `false`; regression test is green").

Never assert a fix works because it "should." Same evidence bar as findings:
re-observe the config and run the test.

## Findings Ledger — so the next audit starts smart

Persist results to the asset file so audits compound instead of restarting cold.
Append/update a ledger table in `assets/<app>.md` (local-only, never committed):

| id | finding | CWE | severity | status | evidence | fixed |
|----|---------|-----|----------|--------|----------|-------|
| F-1 | anon `EXECUTE` on `set_org_plan` | CWE-862 | Critical | fixed | grant + fn source | 2026-07-09 |
| F-2 | missing CSP / cookie `Secure` | CWE-693 | Medium | open | response headers | — |

On each run: read the ledger first, re-check `open` items, mark newly-`fixed` ones
(with the re-verify evidence), and flag loudly if a previously-`fixed` item has
regressed. Statuses: `open`, `fixed`, `accepted-risk` (record *why* the user chose
to accept it). This is the memory that turns one-shot audits into a trend line.

For work that spans more than one asset (e.g. a whole program), also keep a running
`notes/<program>.md` log (gitignored) — the ledger here is the structured per-asset
state; the notes log is the session-by-session timeline. Both stay local.

## Output Format

```
Plan for <asset> (<stack>):
1. [severity] <check> — <why> — CWE-XXX — run: <exact request>
2. ...

[if active mode accepted]
Ran (read-only): <requests>
Observations:
- <endpoint/object> → <status/finding, tied to the actual response/config>
Needs your hands-on (non-GET / write): <checks handed back>

Confirmed findings (fix-first order):
- [severity] <finding> (CWE-XXX)
    Fix:        <concrete change>
    Regression: <test that fails now, passes after the fix>
    Re-verify:  <read-only check to run after fixing>

Ledger update (assets/<app>.md): F-N <finding> → <status>
```

## Common Mistakes

- **Running before confirming ownership.** Always pass the Authorization Gate.
- **Non-GET in active mode / write at the query layer.** State-changing requests
  and any non-`SELECT` introspection are always advisory-only.
- **Claiming a bug from a hunch.** No finding without a cited response.
- **Stopping at the finding.** A confirmed issue with no fix + regression test is
  half-done — close the loop.
- **Claiming a fix works unverified.** Re-observe the config and run the test;
  same evidence bar as the original finding.
- **Generic checklist dumping.** Prioritize for the actual stack; stay tight.

## Ethics

Self-audit is defensive security on assets you own or are authorized to test. It
does not evade or target anything it isn't allowed to. Pair with `scope-check`
if you're ever unsure whether an asset is yours to test.
