---
name: scope-check
description: Use when deciding whether a target (domain, subdomain, IP, endpoint, or asset) is in scope for a bug bounty program before testing it. Symptoms: "is this in scope", pasting a program's scope table, wildcard scope like *.example.com, "am I allowed to test this", ambiguous in-scope/out-of-scope rules with carve-outs.
---

# scope-check

## Overview

Judge whether a candidate target is in scope for a program **before** the user
spends time on it — or, worse, tests something out of scope. Scope definitions
are messy: wildcards, asset-type restrictions, and "in scope except…" carve-outs.
Getting this wrong means a rejected report or unauthorized testing.

**Core principle:** When scope is ambiguous, the safe answer is "uncertain —
verify with the program," never a confident guess. A wrong "yes" can mean
testing something you are not authorized to touch.

## Anti-Hallucination Rule (Critical)

**Judge only against the scope text the user actually provides.** Do not:

- Invent scope rules, assets, or exclusions that aren't in the provided text.
- Assume a program's policy from its name or your background knowledge.
- Guess at a verdict when the text doesn't clearly cover the target.

If the provided scope does not clearly determine the answer, say so explicitly
and tell the user to confirm with the program's policy page. "I don't have
enough to say" is a correct and expected answer.

## Inputs

1. **The program's scope** — the in-scope and out-of-scope lists, pasted or
   linked. If the user hasn't provided it, ask for it. Do not proceed from
   memory of what a program "usually" allows.
2. **The candidate target** — the specific domain/subdomain/IP/endpoint.

## How to Judge

1. **Match against in-scope entries.** Handle wildcards precisely:
   - `*.example.com` matches `api.example.com`, `a.b.example.com` — but confirm
     whether the program treats multi-level subdomains as covered; some don't.
   - `example.com` (no wildcard) usually means only the apex, not subdomains.
   - Note asset-type limits: "web applications" may exclude the API, mail, etc.
2. **Check against out-of-scope entries and carve-outs.** An explicit exclusion
   always wins over a wildcard include. Watch for "in scope except
   `admin.example.com`" and "no testing of X vulnerability class."
3. **Check restrictions that aren't asset lists** — e.g. "no automated
   scanning", "no DoS", rate limits, testing-account requirements. A target can
   be in scope while a technique is not.
4. **Produce a verdict** from exactly three options — never fabricate a fourth
   or soften an out-of-scope into a maybe:

| Verdict | Meaning |
|---------|---------|
| ✅ In scope | Clearly matches an in-scope entry, no exclusion applies |
| ❌ Out of scope | Matches an exclusion, or matches nothing in-scope |
| ⚠️ Uncertain | Scope text doesn't clearly resolve it — verify with the program |

Always show the specific scope line your verdict rests on, so the user can check
your reasoning.

## Output Format

```
Target: <target>
Verdict: <✅ / ❌ / ⚠️>
Reason: <the exact scope entry that decides it, quoted>
Caveats: <any technique restrictions, rate limits, or asset-type limits>
```

If ⚠️: state exactly what's ambiguous and what the user should confirm.

## Common Mistakes

- **Treating a bare apex as a wildcard.** `example.com` in scope does not mean
  `dev.example.com` is. Don't assume.
- **Ignoring exclusions.** A carve-out beats a wildcard. Always scan the
  out-of-scope list before saying yes.
- **Confident guessing on ambiguity.** The whole value of this skill is refusing
  to do that. Ambiguous → ⚠️, every time.
- **Confusing asset scope with technique scope.** "In scope" for the asset
  doesn't authorize automated scanning or DoS if the rules forbid them.

## Ethics

This skill exists to keep testing authorized and in-bounds. Never rationalize a
target into scope because the user wants it to be. If it's not clearly in scope,
it's not in scope until the program confirms.
