#!/bin/bash
set -e

SKILL_DIR="$HOME/.claude/skills/piratepage"
REPO_URL="https://github.com/wesoudshoorn/pirate-skills"

# Determine source: if this script lives inside the skill directory already,
# use local copy. Otherwise clone from GitHub.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USE_LOCAL=false
if [ -f "$SCRIPT_DIR/SKILL.md" ]; then
  USE_LOCAL=true
fi

# Check if already installed
if [ -d "$SKILL_DIR" ]; then
  echo "PiratePage skill is already installed at $SKILL_DIR"
  echo ""
  read -r -p "Update it now? [y/N] " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Nothing changed."
    exit 0
  fi
  echo "Updating..."
  echo ""
fi

mkdir -p "$SKILL_DIR/references"

if [ "$USE_LOCAL" = true ]; then
  # Running from inside the repo — copy files directly
  echo "Installing from local source: $SCRIPT_DIR"
  cp "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"
  cp "$SCRIPT_DIR/references/"*.html "$SKILL_DIR/references/"
else
  # Clone from GitHub into a temp directory and copy
  echo "Downloading from $REPO_URL ..."
  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT

  if ! command -v git &>/dev/null; then
    echo "Error: git is required but not found. Install git and try again."
    exit 1
  fi

  git clone --depth 1 --quiet "$REPO_URL" "$TMP_DIR/skill"

  if [ ! -f "$TMP_DIR/skill/SKILL.md" ]; then
    echo "Error: download succeeded but SKILL.md not found. The repo structure may have changed."
    exit 1
  fi

  cp "$TMP_DIR/skill/SKILL.md" "$SKILL_DIR/SKILL.md"
  cp "$TMP_DIR/skill/references/"*.html "$SKILL_DIR/references/"
fi

# Verify the install
FILE_COUNT=$(ls "$SKILL_DIR/references/"*.html 2>/dev/null | wc -l | tr -d ' ')

echo "Done. Installed $FILE_COUNT reference files to $SKILL_DIR"
echo ""
echo "Usage:"
echo "  Type /piratepage in Claude Code to start generating a landing page."
echo ""
echo "What's included:"
echo "  SKILL.md          — Skill instructions (read automatically by Claude Code)"
echo "  references/       — HTML patterns for all section types"
echo ""
