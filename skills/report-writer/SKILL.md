---
name: report-writer
description: Use when writing up a security vulnerability finding for a bug bounty program (HackerOne, Bugcrowd, Intigriti) or a disclosure — turns raw notes about a bug into a structured, triage-ready report with proper impact framing. Symptoms: "how do I write this up", "draft a report", "submit this finding", messy repro notes that need formatting.
---

# report-writer

## Overview

Turn a hunter's raw finding — the bug, what they did, what happened — into a
clean, triage-ready vulnerability report. Triagers skim fast and reject reports
that are vague, missing repro steps, or that overstate impact. A well-structured
report with realistic, clearly-argued impact gets triaged faster and rated
higher.

**Core principle:** A report's job is to let a triager reproduce the bug and
understand its impact in under two minutes, without asking follow-up questions.

## When to Use

- The user has found a bug and needs to submit it to a program.
- The user has messy notes ("I changed the id param and got another user's
  data") that need to become a real report.
- The user asks to "write up", "draft", or "format" a finding.

**When NOT to use:** for triaging/prioritizing recon output (that's
`recon-triage`), or for deciding whether a target is in scope (that's
`scope-check`).

## Required Inputs — Ask If Missing

Do not fabricate any of these. If the user hasn't provided one, ask for it
before writing the report:

1. **Vulnerability type** (e.g. IDOR, reflected XSS, SSRF, broken access control)
2. **Affected asset** — exact URL/endpoint/parameter, and which program
3. **Reproduction steps** — the actual sequence performed
4. **Observed result** — what proved the bug (the response, the data leaked)
5. **Impact** — what a malicious actor could actually do with this

If impact is unclear, help the user reason about it from the vulnerability type
and affected asset — but never invent capabilities that the evidence does not
support. Overstated impact gets reports rejected.

## Report Structure

Produce the report in this order. Use the full template in
[report-template.md](report-template.md) for the exact section layout and a
worked IDOR example.

1. **Title** — `<Vuln type> on <asset> allows <impact>`. Specific, not "XSS found".
2. **Summary** — 2–3 sentences: what the bug is, where, and why it matters.
3. **Steps to Reproduce** — numbered, copy-pasteable, starting from a clean
   state. Include exact requests (method, path, headers, body) where relevant.
4. **Proof of Concept** — the request/response or payload that demonstrates it.
   Redact real victim data; use the hunter's own second account instead.
5. **Impact** — concrete, realistic consequences. Tie to CVSS if the program
   uses it, but explain in plain terms first.
6. **Remediation** — the standard fix for this class of bug, specific to what
   was seen.

## Severity Guidance

Suggest a severity, but frame it as a suggestion and justify it:

| Signal | Pushes severity up | Pushes severity down |
|--------|--------------------|--------------------|
| Data accessed | PII, credentials, financial | Public/non-sensitive data |
| Auth required | None (unauthenticated) | Admin/privileged only |
| Scope of impact | Any user, mass exploitable | Self-only, single record |
| Preconditions | None | User interaction, rare config |

State the reasoning ("unauthenticated access to other users' PII → High/Critical")
so the triager can agree or adjust, rather than asserting a number.

## Common Mistakes

- **Overclaiming impact.** "Full account takeover" when you only read one
  non-sensitive field. Triagers downgrade and lose trust. Claim exactly what the
  evidence shows.
- **Vague repro.** "Change the id and you get other data." Give the exact
  request and the exact response field that proves it.
- **Real victim data in the PoC.** Use two accounts you control. Never include
  another real user's data.
- **No clean starting state.** Steps that assume prior setup the triager doesn't
  have. Start from login/fresh.
- **Missing the "so what".** A bug with no articulated impact reads as a
  non-issue. Always connect the technical fact to a real-world consequence.

## Ethics

Only write reports for testing the user is authorized to do — an active program
they are enrolled in, or a target they own. If the finding describes testing
that appears out of scope or unauthorized, say so and stop.
