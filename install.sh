#!/usr/bin/env bash
set -euo pipefail

# --- hyrax-workshop-skill installer ---
# Copies the hyrax-dataset-class skill into your project's .claude/skills/ directory.
# Run this from the ROOT of your project (where your .claude/ directory lives).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_SRC="$SCRIPT_DIR/.claude/skills/hyrax-dataset-class"
SKILL_DEST="./.claude/skills/hyrax-dataset-class"

# macOS only
if [[ "$(uname)" != "Darwin" ]]; then
  echo "ERROR: This installer only supports macOS with a default Claude Code setup."
  echo "Please follow the manual instructions in README.md."
  exit 1
fi

# Must be run from inside a project with a .claude directory
if [[ ! -d "./.claude" ]]; then
  echo "ERROR: No .claude/ directory found in the current directory."
  echo "Make sure you are running this script from the root of your project,"
  echo "not from inside the hyrax-workshop-skill folder."
  echo ""
  echo "See README.md for manual installation instructions."
  exit 1
fi

mkdir -p "./.claude/skills"
cp -r "$SKILL_SRC" "$SKILL_DEST"

echo "✓ Skill installed to $SKILL_DEST"
echo ""
echo "To use it, open Claude Code in your project and say:"
echo "  Use \$hyrax-dataset-class to create a dataset class for my data."
