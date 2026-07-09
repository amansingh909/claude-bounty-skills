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
| Supabase / Firebase / row-level security | RLS/rules bypass — read/write rows you shouldn't own |
| Any deployed app | Exposed secrets (`.env`, keys in JS bundles, source maps), security headers, cookie flags |
| Auth flows | Session fixation, weak reset tokens, missing rate limits on login |
| File upload / rendering | Stored XSS, SSRF via URL fetchers, path traversal |

Output a tight, ordered plan. For each item: **what to check, why, and the exact
request** (e.g. a `curl` line). Keep it focused — the highest-signal checks for
*this* stack, not a generic OWASP dump.

## Opt-In Active Mode (guardrails)

After presenting the plan, offer to run the read-only subset yourself. If the
user accepts, obey ALL of these:

- **Own-asset-only:** target passed the Authorization Gate above.
- **Read-only:** `GET`/`HEAD` only. Never `POST`/`PUT`/`PATCH`/`DELETE`, never a
  payload meant to change state. A check that needs a non-GET request is handed
  back as an advisory step for the user to run deliberately — you do not run it.
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
