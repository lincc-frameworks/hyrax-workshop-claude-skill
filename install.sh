#!/usr/bin/env bash
set -euo pipefail

# --- hyrax-workshop-skill installer ---
# Copies the hyrax-dataset-class skill into your user-global Claude Code skills
# directory (~/.claude/skills/), so it is available in every Claude Code session
# regardless of which project (or notebook) you are working in.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_SRC="$SCRIPT_DIR/.claude/skills/hyrax-dataset-class"
SKILL_DEST="$HOME/.claude/skills/hyrax-dataset-class"

# macOS and Linux share the same ~/.claude location.
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

mkdir -p "$HOME/.claude/skills"
rm -rf "$SKILL_DEST"
cp -r "$SKILL_SRC" "$SKILL_DEST"

echo "✓ Skill installed to $SKILL_DEST"
echo ""
echo "It is now available in every Claude Code session. To use it, say:"
echo "  Use \$hyrax-dataset-class to create a dataset class for my data."
