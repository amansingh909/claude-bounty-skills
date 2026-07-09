#!/usr/bin/env bash
# Validate that every skills/*/SKILL.md has correct, loadable frontmatter.
#
# Claude Code only loads a skill if its SKILL.md opens with a YAML frontmatter
# block containing `name` and `description`, and the `name` matches the folder.
# This catches a bad edit before it ships.
#
# Run locally from the repo root:  bash scripts/validate-skills.sh
# Runs in CI on every push / PR:    .github/workflows/validate-skills.yml
set -uo pipefail

fail=0
err() { echo "    ✗ $1"; fail=1; }

if [ ! -d skills ]; then
  echo "error: no skills/ directory — run this from the repo root" >&2
  exit 1
fi

shopt -s nullglob
skills=(skills/*/SKILL.md)

if [ ${#skills[@]} -eq 0 ]; then
  echo "error: no skills/*/SKILL.md found under skills/" >&2
  exit 1
fi

echo "Validating ${#skills[@]} skill(s)…"
for f in "${skills[@]}"; do
  dir="$(basename "$(dirname "$f")")"
  echo "  • $dir"

  # 1. Frontmatter must open with '---' on line 1.
  if [ "$(sed -n '1p' "$f" | tr -d '\r')" != "---" ]; then
    err "must start with '---' (YAML frontmatter) on line 1"
    continue
  fi

  # 2. Frontmatter must close with a matching '---'.
  close=$(awk 'NR>1 && /^---[[:space:]]*$/ {print NR; exit}' "$f")
  if [ -z "$close" ]; then
    err "frontmatter block is never closed with '---'"
    continue
  fi

  fm=$(sed -n "2,$((close - 1))p" "$f")

  # 3. name: present and equal to the directory name.
  if ! printf '%s\n' "$fm" | grep -q '^name:'; then
    err "missing 'name:' in frontmatter"
  else
    name=$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -1)
    if [ -z "$name" ]; then
      err "'name:' is empty"
    elif [ "$name" != "$dir" ]; then
      err "name '$name' does not match directory '$dir' — Claude Code requires they match"
    fi
  fi

  # 4. description: present and non-empty (this is what drives skill triggering).
  if ! printf '%s\n' "$fm" | grep -q '^description:'; then
    err "missing 'description:' in frontmatter"
  else
    desc=$(printf '%s\n' "$fm" | sed -n 's/^description:[[:space:]]*//p' | head -1)
    if [ -z "$desc" ]; then
      err "'description:' is empty — skills trigger off this text"
    fi
  fi
done

echo ""
if [ "$fail" -ne 0 ]; then
  echo "✗ Skill frontmatter validation FAILED"
  exit 1
fi
echo "✓ All skills have valid frontmatter"
