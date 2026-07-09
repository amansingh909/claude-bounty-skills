#!/usr/bin/env bash
# Installs the claude-bounty-skills into your Claude Code skills directory.
#
#   Default (user-level):   installs to ~/.claude/skills
#   --project:              installs to ./.claude/skills (run from project root)
#
# Usage:
#   ./install.sh
#   ./install.sh --project
#   curl -fsSL <raw-url>/install.sh | bash
#   curl -fsSL <raw-url>/install.sh | bash -s -- --project

set -euo pipefail

REPO_URL="https://github.com/amansingh909/claude-bounty-skills.git"

# --- resolve target directory --------------------------------------------------
TARGET="${HOME}/.claude/skills"
SCOPE="user-level (~/.claude/skills)"
if [ "${1:-}" = "--project" ]; then
  TARGET="$(pwd)/.claude/skills"
  SCOPE="project-level (./.claude/skills)"
fi

echo "==> Installing claude-bounty-skills — ${SCOPE}"

# --- get the source ------------------------------------------------------------
# If run from inside a clone, use it; otherwise clone into a temp dir we clean up.
if [ -d "skills" ] && [ -f "skills/report-writer/SKILL.md" ]; then
  SRC="$(pwd)/skills"
  CLEANUP=""
else
  command -v git >/dev/null 2>&1 || { echo "error: git is required" >&2; exit 1; }
  TMP="$(mktemp -d)"
  CLEANUP="${TMP}"
  echo "==> Cloning ${REPO_URL}"
  git clone --depth 1 --quiet "${REPO_URL}" "${TMP}/repo"
  SRC="${TMP}/repo/skills"
fi

# --- install -------------------------------------------------------------------
mkdir -p "${TARGET}"
installed=()
for dir in "${SRC}"/*/; do
  name="$(basename "${dir}")"
  cp -r "${dir}" "${TARGET}/${name}"
  installed+=("${name}")
done

# --- cleanup -------------------------------------------------------------------
[ -n "${CLEANUP}" ] && rm -rf "${CLEANUP}"

echo "==> Installed ${#installed[@]} skills to ${TARGET}:"
for s in "${installed[@]}"; do echo "      - ${s}"; done
echo "==> Done. Open Claude Code and describe a bounty or self-audit task to trigger them."
