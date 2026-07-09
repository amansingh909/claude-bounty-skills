---
name: recon-triage
description: Use when a bug bounty recon phase has produced a large list of hosts/subdomains/endpoints and you need to decide what to look at first. Symptoms: hundreds of lines of subfinder/amass/httpx output, "which of these is interesting", "what should I look at first", "triage this recon", a wall of live hosts with tech/status/port data.
---

# recon-triage

## Overview

Recon tools produce volume; hunters need focus. Given the output of enumeration
tools (resolved subdomains, an httpx table of live hosts with tech/status/ports),
this skill triages it: which hosts deserve manual attention first, and **why**.

**This is deliberately not a tool runner.** It does not run subfinder or httpx —
running a tool is a shell command, not a skill. The value here is the judgment
layer applied to output the user already has: turning 400 hosts into "look at
these 6 first, here's the reasoning."

## Anti-Hallucination Rule (Critical)

**Triage only the hosts present in the provided input.** Do not:

- Invent hosts, subdomains, endpoints, technologies, or versions not in the data.
- Assume a host runs software the input doesn't state.
- Claim a vulnerability exists — this skill prioritizes *attention*, not findings.
  The output is "worth looking at because X", never "this is vulnerable."

If the input is empty, malformed, or too sparse to triage, say so and ask for
the actual tool output. Never pad the list to look thorough.

## Input

The raw output of the user's recon tools — for example:

- A plain list of subdomains (from subfinder/amass/assetfinder).
- An httpx table: host, status code, title, tech stack, content-length, port.
- Any similar host/endpoint inventory the user pastes.

If the format is unusual, ask what the columns mean rather than guessing.

## Triage Rubric

Rank hosts by how likely they are to hide something, using signals actually
present in the data:

| Signal | Why it's interesting |
|--------|---------------------|
| Non-prod naming (`dev`, `staging`, `uat`, `test`, `qa`, `internal`) | Weaker auth, debug modes, older code |
| Admin / internal tooling (`admin`, `jenkins`, `grafana`, `jira`, `vpn`) | High-value, often mis-scoped |
| Unusual tech / outdated versions (when the data states a version) | Known-CVE surface |
| Odd status codes (401/403 on interesting paths, 500s) | Auth boundaries, error leakage |
| Non-standard ports | Forgotten services, admin panels |
| One-off outliers (a host unlike its siblings) | Shadow IT, misconfig |
| Default titles ("Welcome to nginx", framework defaults) | Unfinished/forgotten deploys |

Down-rank: CDN/marketing pages, static asset hosts, obvious redirects to the
apex, and hosts with no distinguishing signal.

## Output Format

Lead with a short prioritized shortlist, then the reasoning:

```
Top targets to look at first:
1. <host> — <the signal(s) from the data that make it interesting>
2. <host> — <reason>
...

Lower priority / likely noise:
- <host or group> — <why de-prioritized>

Notes: <anything the data suggests but doesn't confirm, flagged as unconfirmed>
```

Keep the shortlist tight (typically 5–10). If everything looks like noise, say
that honestly rather than manufacturing interest.

## Common Mistakes

- **Inventing detail.** Saying a host "likely runs an old WordPress" when the
  input never mentioned WordPress. Only reason from what's there.
- **Claiming vulnerability.** "This is exploitable." No — the output is
  *priority*, not a finding. Frame as "worth checking because…".
- **Ranking everything.** A triage that flags 200 of 400 hosts isn't triage.
  Be selective; the point is focus.
- **Ignoring the boring-but-right.** Sometimes the interesting host is a plain
  `api.` subdomain — don't over-index on flashy names at the expense of obvious
  attack surface like APIs and auth endpoints.

## Ethics

Prioritizing attack surface assumes the hosts are in an authorized program. If a
host looks out of scope, flag it — pair with `scope-check` before testing.
