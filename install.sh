#!/bin/bash
set -e

REPO_URL="https://github.com/wesoudshoorn/pirate-skills.git"
GLOBAL_DIR="$HOME/.claude/skills/piratepage"
PROJECT_DIR=".claude/skills/piratepage"
STATE_DIR="$HOME/.piratepage"

# Parse flags
MODE="global"
UPDATE_ONLY=false
for arg in "$@"; do
  case "$arg" in
    --project) MODE="project" ;;
    --global)  MODE="global" ;;
    --update)  UPDATE_ONLY=true ;;
  esac
done

if [ "$MODE" = "project" ]; then
  INSTALL_DIR="$PROJECT_DIR"
else
  INSTALL_DIR="$GLOBAL_DIR"
fi

# Detect source: running from inside the repo?
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USE_LOCAL=false
[ -f "$SCRIPT_DIR/SKILL.md" ] && [ -f "$SCRIPT_DIR/VERSION" ] && USE_LOCAL=true

# --- Update mode (non-interactive, for auto-upgrade) ---
if [ "$UPDATE_ONLY" = true ]; then
  if [ ! -d "$INSTALL_DIR" ]; then
    echo "Not installed at $INSTALL_DIR"
    exit 1
  fi

  OLD_VERSION="$(cat "$INSTALL_DIR/VERSION" 2>/dev/null | tr -d '[:space:]')"

  if [ -d "$INSTALL_DIR/.git" ]; then
    # Git install — pull latest
    cd "$INSTALL_DIR"
    git fetch origin --quiet
    git reset --hard origin/main --quiet
  else
    # Vendored — clone fresh and swap
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT
    git clone --depth 1 --quiet "$REPO_URL" "$TMP_DIR/skill"

    # Swap files (keep install atomic-ish)
    rm -rf "$INSTALL_DIR.bak"
    mv "$INSTALL_DIR" "$INSTALL_DIR.bak"
    mkdir -p "$(dirname "$INSTALL_DIR")"
    cp -R "$TMP_DIR/skill" "$INSTALL_DIR"
    rm -rf "$INSTALL_DIR/.git"  # Keep vendored
    rm -rf "$INSTALL_DIR.bak"
  fi

  NEW_VERSION="$(cat "$INSTALL_DIR/VERSION" 2>/dev/null | tr -d '[:space:]')"

  # Write upgrade marker
  mkdir -p "$STATE_DIR"
  echo "$OLD_VERSION" > "$STATE_DIR/just-upgraded-from"
  rm -f "$STATE_DIR/last-update-check"
  rm -f "$STATE_DIR/update-snoozed"

  echo "Upgraded piratepage: $OLD_VERSION → $NEW_VERSION"
  exit 0
fi

# --- Interactive install/update ---
if ! command -v git &>/dev/null; then
  echo "Error: git is required. Install git and try again."
  exit 1
fi

if [ -d "$INSTALL_DIR" ]; then
  echo "piratepage is already installed at $INSTALL_DIR"
  echo ""
  read -r -p "Update it now? [y/N] " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Nothing changed."
    exit 0
  fi
  echo "Updating..."
  echo ""
fi

if [ "$USE_LOCAL" = true ]; then
  echo "Installing from local source: $SCRIPT_DIR"
  mkdir -p "$INSTALL_DIR/references" "$INSTALL_DIR/bin"
  cp "$SCRIPT_DIR/SKILL.md" "$INSTALL_DIR/SKILL.md"
  cp "$SCRIPT_DIR/VERSION" "$INSTALL_DIR/VERSION"
  cp "$SCRIPT_DIR/CHANGELOG.md" "$INSTALL_DIR/CHANGELOG.md" 2>/dev/null || true
  cp "$SCRIPT_DIR/install.sh" "$INSTALL_DIR/install.sh"
  cp "$SCRIPT_DIR/references/"*.html "$INSTALL_DIR/references/"
  cp "$SCRIPT_DIR/bin/"* "$INSTALL_DIR/bin/" 2>/dev/null || true
  chmod +x "$INSTALL_DIR/bin/"* 2>/dev/null || true
else
  echo "Downloading from GitHub..."
  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT

  git clone --depth 1 --quiet "$REPO_URL" "$TMP_DIR/skill"

  if [ ! -f "$TMP_DIR/skill/SKILL.md" ]; then
    echo "Error: SKILL.md not found in repo. The structure may have changed."
    exit 1
  fi

  mkdir -p "$(dirname "$INSTALL_DIR")"

  if [ "$MODE" = "global" ]; then
    # Global: move the whole clone (keeps .git for easy updates)
    rm -rf "$INSTALL_DIR"
    mv "$TMP_DIR/skill" "$INSTALL_DIR"
  else
    # Project: copy without .git (vendored)
    rm -rf "$INSTALL_DIR"
    cp -R "$TMP_DIR/skill" "$INSTALL_DIR"
    rm -rf "$INSTALL_DIR/.git"
  fi
fi

# Make scripts executable
chmod +x "$INSTALL_DIR/bin/"* 2>/dev/null || true
chmod +x "$INSTALL_DIR/install.sh" 2>/dev/null || true

# Verify
VERSION="$(cat "$INSTALL_DIR/VERSION" 2>/dev/null | tr -d '[:space:]')"
FILE_COUNT=$(ls "$INSTALL_DIR/references/"*.html 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo "Installed piratepage v$VERSION ($FILE_COUNT reference files)"
echo "  Location: $INSTALL_DIR"
echo ""
echo "Usage:"
echo "  Type /piratepage in Claude Code to generate a landing page."
echo ""
if [ "$MODE" = "project" ]; then
  echo "Team install: commit .claude/skills/piratepage/ so teammates get the skill automatically."
  echo "Updates will create diffs in your repo — run install.sh --project --update to pull latest."
else
  echo "Updates are checked automatically when you use /piratepage."
fi
echo ""
