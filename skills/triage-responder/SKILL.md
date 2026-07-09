---
name: triage-responder
description: Use when a submitted bug bounty report gets pushback and you need to draft a reply — statuses like Needs More Info, Informative, Not Applicable (N/A), Duplicate, or a request to demonstrate more impact. Symptoms: "program said needs more info", "they marked it informative", "closed as N/A", "how do I respond to triage", "disputing a duplicate", "they want more impact".
---

# triage-responder

## Overview

A submitted report isn't the end — most get a response before any bounty, and a
weak or emotional reply kills reports that were actually valid. This skill drafts
a professional, persuasive reply to a triager's pushback: persistent without
being rude, sharpening the argument without overstating it.

**Core principle:** You are trying to help a triager reach the right decision,
not to win an argument. Answer what they actually asked, add only substance you
can back up, and keep it short and respectful. Assume good faith.

## When to Use

- A report was marked **Needs More Info**, **Informative**, **N/A**,
  **Duplicate**, or the program asked you to **show more impact**.
- The user wants to respond to a triager and isn't sure how to frame it.

**When NOT to use:** for writing the original report (that's `report-writer`).

## Anti-Hallucination Rule (Critical)

**Respond only from what the user actually observed and can substantiate.** Do
not:

- Invent new technical claims, new impact, or evidence the user didn't gather.
- Assert the report was accepted/paid, or that policy says something, unless the
  user provided that.
- Claim you tested a chained/escalated attack you only *theorized*.

If a stronger response would need evidence the user doesn't have, say so and tell
them what to go collect — don't fabricate it into the reply. **If the triager is
correct and the finding genuinely doesn't hold up, say that plainly and advise
accepting the decision.** A bounty is never worth a false claim.

## Inputs — Ask If Missing

1. The **original finding** (or its key facts: bug, asset, impact).
2. The **triager's message and the status** they set.
3. What the user **can actually substantiate** beyond the original report.

## Response Playbook

Match the reply to the status:

| Status | The move |
|--------|----------|
| **Needs More Info** | Answer exactly what was asked, concisely. Supply the missing repro step, request/response, or PoC. Don't re-explain what they already have. |
| **Informative** ("no/low security impact") | Only push back if you have a *concrete* attack scenario showing real impact. Spell out who is harmed and how. If you don't have one, accept it gracefully. |
| **N/A / Not Applicable** | Point to the specific behavior that makes it a genuine security issue, factually. If it hinges on a misread detail, clarify that detail. |
| **Duplicate** | Politely ask for the reference, or note a concrete difference if the finding is genuinely distinct (different endpoint, different root cause). Never accuse the program of hiding it. |
| **Show more impact** | Provide a realistic escalation grounded in what's already demonstrated — chaining, enumeration scale, affected users. No hypotheticals you can't support. |

## Tone Rules

- Professional and concise — a few tight sentences, not a wall of text.
- No entitlement, no threats, no "I'll post this publicly / on Twitter."
- Persistent but respectful; you can disagree without being combative.
- Lead with the substance (the fact or evidence), not with the disagreement.

## Output

Produce a ready-to-send reply. Below it, add one line noting any evidence the
user should attach (screenshot, second request, log) to make the reply land.

## Common Mistakes

- **Arguing severity emotionally** ("this is clearly critical!!") instead of
  showing impact. Show, don't insist.
- **Overclaiming to win.** Inflating impact to reverse a decision destroys
  credibility and can get you penalized. Claim exactly what you can prove.
- **Walls of text.** Triagers handle many reports; respect their time.
- **Re-litigating settled points.** Address the current objection, not the
  whole history.
- **Being combative.** The triager is a person doing a job; treat them as an
  ally in getting to the right call.

## Ethics

Never misrepresent what was tested or observed to change a decision. If the
finding doesn't hold up, the honest move is to accept the status and move on.
