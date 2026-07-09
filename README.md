# claude-bounty-skills

**Claude Code skills for bug bounty hunting.** They bring the judgment — you
bring the tools.

These aren't wrappers that run `subfinder` for you (that's a shell command, not
a skill). Each one adds the reasoning layer where an LLM actually helps: turning
messy notes into a clean report, judging fuzzy scope, and triaging a wall of
recon output down to what's worth your time.

Every skill is built to **never fabricate**: it reasons only from what you give
it, and when it's unsure it says so instead of guessing.

---

## The skills

| Skill | What it does |
|-------|--------------|
| **`report-writer`** | Turns raw finding notes into a triage-ready, properly-framed vulnerability report (HackerOne-style). Suggests severity with reasoning, never overstates impact. |
| **`scope-check`** | Judges whether a target is in scope from a program's (often messy, wildcard-laden) scope text. Biased toward "⚠️ uncertain, verify" over a confident wrong answer. |
| **`recon-triage`** | Reads your enumeration output (subfinder/httpx/amass) and tells you which hosts to look at first, and why. Prioritizes attention — never claims a vuln. |

Each lives in `skills/<name>/SKILL.md`. See per-skill examples in
[`examples/`](examples/).

---

## Install

Clone into your Claude Code skills directory:

```bash
# user-level (available in every project)
git clone https://github.com/amansingh909/claude-bounty-skills.git
cp -r claude-bounty-skills/skills/* ~/.claude/skills/

# or project-level
cp -r claude-bounty-skills/skills/* .claude/skills/
```

Then just describe your task in Claude Code — the skill triggers on the matching
situation (e.g. "help me write up this IDOR", "is `dev.example.com` in scope?",
"triage this httpx output").

---

## Examples

**`report-writer`** — you paste:
> found IDOR on /api/v2/invoices/{id}, incrementing id returns other users
> invoices with name + billing address, tested with 2 of my own accounts

…and it produces a full titled report with numbered repro steps, a redacted
PoC, realistic impact, a justified severity, and remediation. Worked example:
[`examples/report-writer.md`](examples/report-writer.md).

**`scope-check`** — you paste a scope table and a target; it returns a
✅ / ❌ / ⚠️ verdict with the exact scope line it rests on. Worked example:
[`examples/scope-check.md`](examples/scope-check.md).

**`recon-triage`** — you paste 400 lines of httpx output; it returns a tight
shortlist of the hosts worth manual attention with the signal behind each.
Worked example: [`examples/recon-triage.md`](examples/recon-triage.md).

---

## Ethics & scope

These skills assume **authorized testing only** — an active program you're
enrolled in, or assets you own. `scope-check` exists specifically to keep you
in-bounds, and `report-writer` will flag a finding that looks out of scope. Don't
use these against targets you're not permitted to test.

---

## License

[MIT](LICENSE)
