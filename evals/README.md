# evals/ — does each skill actually trigger?

A skill only helps if Claude Code *fires* it on the right request. Reading the
source can't prove that; running it can. This folder holds a reproducible check
anyone can re-run — stronger evidence than an author-made screenshot.

## `triggers.tsv`

Tab-separated `prompt <TAB> expected-skill`. `expected` is a skill name, or `none`
for a prompt that should trigger **nothing** (this guards against over-triggering).
The fixture doubles as documentation of what each skill is meant to catch.

## Running the eval

`scripts/eval-triggers.sh` emulates Claude Code's skill router: it shows a model
every skill's live `description` and asks which one (if any) best matches each
prompt, then scores the pick against the fixture.

```bash
ANTHROPIC_API_KEY=sk-... bash scripts/eval-triggers.sh
bash scripts/eval-triggers.sh --dry-run   # print the router prompt + a payload, no API call
```

Needs `curl`, `jq`, and an API key. Override the model with `EVAL_MODEL`
(default: `claude-haiku-4-5-20251001`).

## Notes

- **Not run in CI.** It costs API tokens and needs a key CI can't safely hold
  (fork PRs get no secrets), so it's a maintainer-run check, not a merge gate. The
  frontmatter validator (`scripts/validate-skills.sh`) *is* the CI gate — and it
  also checks this fixture only references real skills.
- **Cyber-safeguard caveat.** These prompts are security-flavored, so a run may
  occasionally trip Claude's real-time cyber classifier (see the main README). The
  routing task itself is benign classification; if you hit it, that's the API
  layer, not the eval.
- A live demo (an asciinema cast / GIF of a skill firing in real Claude Code) is
  the most human-convincing proof — see the README for the recording recipe.
