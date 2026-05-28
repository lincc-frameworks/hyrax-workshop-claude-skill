#!/usr/bin/env bash
set -euo pipefail

# --- hyrax-workshop-skill installer ---
# Copies the hyrax-dataset-class skill into your user-global skills directories
# for Claude Code (~/.claude/skills/) and Codex CLI (~/.codex/skills/), so it
# is available in every session regardless of which project (or notebook) you
# are working in.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_SRC="$SCRIPT_DIR/.claude/skills/hyrax-dataset-class"

# macOS and Linux share the same home-directory layout for both tools.
case "$(uname)" in
  Darwin|Linux) ;;
  *)
    echo "ERROR: This installer supports macOS and Linux."
    echo "Please follow the manual instructions in README.md."
    exit 1
    ;;
esac

if [[ ! -d "$SKILL_SRC" ]]; then
  echo "ERROR: Could not find the skill at $SKILL_SRC."
  echo "Run this script from the cloned hyrax-workshop-claude-skill repo."
  exit 1
fi

# Claude Code
mkdir -p "$HOME/.claude/skills"
rm -rf "$HOME/.claude/skills/hyrax-dataset-class"
cp -r "$SKILL_SRC" "$HOME/.claude/skills/hyrax-dataset-class"
echo "✓ Installed for Claude Code → $HOME/.claude/skills/hyrax-dataset-class"

# Codex CLI
mkdir -p "$HOME/.codex/skills"
rm -rf "$HOME/.codex/skills/hyrax-dataset-class"
cp -r "$SKILL_SRC" "$HOME/.codex/skills/hyrax-dataset-class"
echo "✓ Installed for Codex CLI  → $HOME/.codex/skills/hyrax-dataset-class"

echo ""
echo "The skill is now available in every Claude Code and Codex CLI session."
echo "To use it, say:"
echo "  Use \$hyrax-dataset-class to create a dataset class for my data."
