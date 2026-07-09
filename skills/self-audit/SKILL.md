---
name: self-audit
description: Use when reviewing a web app you own or are explicitly authorized to test — a first-party, defensive security self-review. Symptoms: "audit my app", "check my own site for security issues", "self-audit my web app", "what should I test on my app", "review my app before others find bugs", pointing these skills at an asset in your own registry.
---

# self-audit

## Overview

You own an app and want to find (and fix) its security issues before someone
else does. Given an asset — from your `assets/` registry or pasted inline — this
skill maps its tech stack to the checks most worth running, hands you a
**prioritized, concrete test plan**, and then (if you opt in) runs the
**read-only** subset against your own asset and interprets what it sees.

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
- If you lack the info to plan (unknown stack, no endpoints), ask — don't pad.

## Input

- An asset file from `assets/` (preferred), or an inline description: domain,
  tech stack, auth model, notable endpoints.
- Optionally, output the user already captured (curl/httpx responses) to interpret.

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
changing any state. Never run a call that could write to prod as part of the
audit; hand those to the user as deliberate, advisory steps.

## Opt-In Active Mode (guardrails)

After presenting the plan, offer to run the read-only subset yourself. If the
user accepts, obey ALL of these:

- **Own-asset-only:** target passed the Authorization Gate above.
- **Read-only:** `GET`/`HEAD` only. Never `POST`/`PUT`/`PATCH`/`DELETE`, never a
  payload meant to change state. A check that needs a non-GET request is handed
  back as an advisory step for the user to run deliberately — you do not run it.
- **Backend introspection (own asset):** authenticated *read-only* management/DB
  introspection of your own backend — advisors, schema, grants, RLS status,
  function source — is allowed and is the preferred way to prove a finding. It
  changes nothing. Anything that could write to prod stays advisory-only, even on
  your own app.
- **Rate-limited:** pace requests conservatively; never hammer production.
- **Evidence-bound:** report only what a response actually showed; quote/cite it.

Then interpret: what each response means, which checks are clear, which need the
user to run the non-GET follow-up.

## Output Format

```
Plan for <asset> (<stack>):
1. <check> — <why> — run: <exact request>
2. ...

[if active mode accepted]
Ran (read-only): <requests>
Observations:
- <endpoint> → <status/finding, tied to the actual response>
Needs your hands-on (non-GET): <checks handed back>

Suggested fixes: <short, per confirmed issue>
```

## Common Mistakes

- **Running before confirming ownership.** Always pass the Authorization Gate.
- **Non-GET in active mode.** State-changing requests are always advisory-only.
- **Claiming a bug from a hunch.** No finding without a cited response.
- **Generic checklist dumping.** Prioritize for the actual stack; stay tight.

## Ethics

Self-audit is defensive security on assets you own or are authorized to test. It
does not evade or target anything it isn't allowed to. Pair with `scope-check`
if you're ever unsure whether an asset is yours to test.
