# claude-bounty-skills

**Claude Code skills for bug bounty hunting — and security-auditing the web apps
you own.** They bring the judgment — you bring the tools.

These aren't wrappers that run `subfinder` for you (that's a shell command, not
a skill). Each one adds the reasoning layer where an LLM actually helps, and
together they cover the full arc of a bounty: **recon → scope → report → defend.**

Every skill is built to **never fabricate**: it reasons only from what you give
it, and when it's unsure it says so instead of guessing.

---

## Two ways to use this

1. **Bug bounty** — on programs you're enrolled in. Recon → scope → report → defend.
2. **Self-audit** — on apps **you own**. Register them in [`assets/`](assets/),
   then `self-audit` maps your stack to the checks worth running and (opt-in) runs
   the read-only ones against your own asset. Defensive: find and fix issues
   before someone else does.

---

## The skills

| Skill | Stage | What it does |
|-------|-------|--------------|
| **`recon-triage`** | Recon | Reads your enumeration output (subfinder/httpx/amass) and tells you which hosts to look at first, and why. Prioritizes attention — never claims a vuln. |
| **`scope-check`** | Scope | Judges whether a target is in scope from a program's (often messy, wildcard-laden) scope text. Biased toward "⚠️ uncertain, verify" over a confident wrong answer. |
| **`report-writer`** | Report | Turns raw finding notes into a triage-ready vulnerability report (HackerOne/Bugcrowd/Intigriti). Suggests severity with reasoning and a CWE, never overstates impact. |
| **`triage-responder`** | Defend | Drafts a professional reply when a report gets pushback (Needs More Info, Informative, N/A, Duplicate). Sharpens the argument without inflating it. |
| **`self-audit`** | Audit | Reviews an app **you own** (from your `assets/` registry): maps its stack to the highest-signal checks, hands you a concrete plan, and — if you opt in — runs the read-only subset against your own asset. Read-only, own-asset-only, never fabricates. |

Each lives in `skills/<name>/SKILL.md`. See per-skill examples in
[`examples/`](examples/).

---

## Install

One command (clones to a temp dir, copies the skills, cleans up):

```bash
# user-level (available in every project)
curl -fsSL https://raw.githubusercontent.com/amansingh909/claude-bounty-skills/master/install.sh | bash

# or project-level (run from your project root)
curl -fsSL https://raw.githubusercontent.com/amansingh909/claude-bounty-skills/master/install.sh | bash -s -- --project
```

Or do it by hand:

```bash
git clone https://github.com/amansingh909/claude-bounty-skills.git
mkdir -p ~/.claude/skills                                  # user-level
cp -r claude-bounty-skills/skills/* ~/.claude/skills/

# or project-level, from your project root:
mkdir -p .claude/skills && cp -r claude-bounty-skills/skills/* .claude/skills/
```

> Piping a script from the internet into `bash` is convenient but you're trusting
> the source — [read `install.sh`](install.sh) first if you'd rather not.

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

**`triage-responder`** — your report came back "Informative"; you give it the
finding and the triager's message, and it drafts a professional reply that
sharpens the real impact — or, if you can't back a stronger claim, tells you to
accept it rather than overclaim. Worked example:
[`examples/triage-responder.md`](examples/triage-responder.md).

**`self-audit`** — you register your app in `assets/` and say "self-audit
acme"; it returns a prioritized, stack-specific test plan and offers to run the
read-only checks against your own asset, reporting only what it actually
observed. Because it's *your* app, it also runs the **deep first-party pass** —
introspecting your own backend's authorization config where the serious authz
bugs live, on whatever stack you run (Supabase RLS/grants, Firebase rules, an ORM
app's route-level checks, GraphQL permissions, cloud IAM). Worked example:
[`examples/self-audit.md`](examples/self-audit.md).

---

## Authorization, ethics & scope

**Authorized testing only.** Use these skills against (a) an active program
you're enrolled in, or (b) assets **you own or are explicitly authorized to
test**. By registering an asset or running `self-audit`, you attest you have that
authorization.

The design is **defensive**: `scope-check` keeps you in-bounds, `report-writer`
flags out-of-scope findings, and `self-audit` runs only read-only checks against
assets you've declared as your own. Don't point any of this at targets you're not
permitted to test.

> Note: nothing here attempts to influence any AI provider's safety systems. It
> keeps the *work* authorized, read-only, and defensive — that's what makes it
> legitimate.

---

## License

[MIT](LICENSE)
