#!/usr/bin/env bash
# Trigger eval: does each skill fire on the prompts it should — and stay quiet on
# the ones it shouldn't?
#
# Emulates Claude Code's skill router: shows a model every skill's live
# `description` and asks which single skill (if any) best matches a user message,
# then scores the pick against evals/triggers.tsv. Reproducible proof anyone can
# re-run — stronger than an author-made screenshot.
#
# Usage:
#   ANTHROPIC_API_KEY=sk-... bash scripts/eval-triggers.sh
#   bash scripts/eval-triggers.sh --dry-run   # print the router prompt + a payload, no API call
#
# Needs: curl, jq, and (except --dry-run) ANTHROPIC_API_KEY.
# Model:  override with EVAL_MODEL (default: claude-haiku-4-5-20251001).
set -uo pipefail

MODEL="${EVAL_MODEL:-claude-haiku-4-5-20251001}"
FIXTURE="evals/triggers.tsv"
DRY=0
[ "${1:-}" = "--dry-run" ] && DRY=1

command -v jq   >/dev/null 2>&1 || { echo "error: jq is required"   >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "error: curl is required" >&2; exit 1; }
[ -f "$FIXTURE" ] || { echo "error: $FIXTURE not found (run from repo root)" >&2; exit 1; }

# Build the router instruction from the live skill descriptions (stays in sync).
choices=""
for f in skills/*/SKILL.md; do
  name=$(basename "$(dirname "$f")")
  desc=$(sed -n 's/^description:[[:space:]]*//p' "$f" | head -1)
  choices+="- ${name}: ${desc}"$'\n'
done

SYS="You are the skill router for Claude Code. Given a user message and the list of skills below (each with a description of when to use it), choose the SINGLE skill whose description best matches the message. If none clearly applies, answer exactly: none. Respond with ONLY the skill name (or none) — no punctuation, no explanation.

Skills:
${choices}"

if [ "$DRY" -eq 1 ]; then
  echo "=== router system prompt ==="
  printf '%s\n' "$SYS"
  echo "=== example payload (first fixture prompt) ==="
  first=$(grep -vE '^[[:space:]]*#|^[[:space:]]*$' "$FIXTURE" | head -1 | cut -f1)
  jq -n --arg model "$MODEL" --arg sys "$SYS" --arg msg "$first" \
    '{model:$model,max_tokens:16,system:$sys,messages:[{role:"user",content:$msg}]}'
  exit 0
fi

[ -n "${ANTHROPIC_API_KEY:-}" ] || { echo "error: set ANTHROPIC_API_KEY (or use --dry-run)" >&2; exit 1; }

pass=0; total=0; misses=""
while IFS=$'\t' read -r prompt expected; do
  case "$prompt" in ''|'#'*) continue;; esac
  total=$((total + 1))
  payload=$(jq -n --arg model "$MODEL" --arg sys "$SYS" --arg msg "$prompt" \
    '{model:$model,max_tokens:16,system:$sys,messages:[{role:"user",content:$msg}]}')
  resp=$(curl -s https://api.anthropic.com/v1/messages \
    -H "x-api-key: ${ANTHROPIC_API_KEY}" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json" \
    -d "$payload")
  got=$(printf '%s' "$resp" | jq -r '(.content[0].text // ("error: " + (.error.message // "unknown")))' \
        | tr '[:upper:]' '[:lower:]' | tr -d ' .\r\n')
  exp=$(printf '%s' "$expected" | tr '[:upper:]' '[:lower:]' | tr -d ' .\r\n')
  if [ "$got" = "$exp" ]; then
    pass=$((pass + 1)); printf "  \xe2\x9c\x93 %-16s %s\n" "$got" "$prompt"
  else
    misses+="    got '${got}', expected '${exp}' — ${prompt}"$'\n'
    printf "  \xe2\x9c\x97 %-16s (want %s) %s\n" "$got" "$exp" "$prompt"
  fi
done < "$FIXTURE"

echo ""
[ -n "$misses" ] && { echo "Misses:"; printf '%s' "$misses"; echo ""; }
pct=$(( total > 0 ? pass * 100 / total : 0 ))
echo "Trigger accuracy: ${pass}/${total} (${pct}%)  model=${MODEL}"
