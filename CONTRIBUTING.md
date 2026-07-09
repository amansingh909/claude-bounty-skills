# Contributing

Thanks for wanting to improve **claude-bounty-skills**. It's a small, opinionated
repo, so a little guidance keeps additions consistent with the rest.

## What this repo is (the bar for a new skill)

Every skill is a **judgment layer**, not a tool runner. It reasons from what the
user provides — or, for `self-audit`, from read-only responses it actually
observed — and **never fabricates**. A skill that would guess, invent findings, or
run active/destructive actions doesn't belong here.

Skills are only for **authorized, defensive** security work: bug bounty on
programs you're enrolled in, or auditing assets you own. Nothing that assists
unauthorized testing.

## Anatomy of a skill

Follow the shared shape the existing five use — it's what makes the set feel like
one product:

1. **Frontmatter** — `SKILL.md` must open with it:
   ```
   ---
   name: <kebab-case, MUST match the folder name>
   description: Use when <trigger>. Symptoms: "<phrase>", "<phrase>", …
   ---
   ```
   The `description` is what triggers the skill, so lead with *when to use it* and
   include concrete **Symptoms** — the phrases a user would actually type.
2. **Body**, in this order: `Overview` → an `Anti-Hallucination Rule` (restated in
   your skill's own terms) → `Input` → a rubric/playbook (usually a table) →
   `Output Format` → `Common Mistakes` → `Ethics`.
3. A worked example in `examples/<name>.md`, using a **fictional** target.
4. A few rows in [`evals/triggers.tsv`](evals/triggers.tsv) — prompts that should
   fire your skill, and at least one negative that should *not*.

## Before you open a PR

Run the validator locally — CI runs the same check, and a PR can't merge until
it's green:

```bash
bash scripts/validate-skills.sh
```

Optionally, check triggering (needs an API key — see [`evals/README.md`](evals/README.md)):

```bash
ANTHROPIC_API_KEY=sk-... bash scripts/eval-triggers.sh
```

## Opening the PR

`master` is protected: every change goes through a pull request, and the
`validate` check must pass to merge.

1. Fork the repo and create a branch.
2. Make your change; run the validator.
3. Open a PR and fill in the template.

Keep PRs focused — one skill, or one clear improvement, at a time.
