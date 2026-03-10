#!/usr/bin/env bash
# Standalone setup for public Claude Code dotfiles.
# Creates symlinks from this repo into ~/.claude/.
# Idempotent -- safe to re-run.
#
# Usage: ./setup.sh

set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

step() { echo -e "\n${GREEN}===${NC} $1 ${GREEN}===${NC}"; }

ok=0; skipped=0; blocked=0

link() {
  local target="$1" link_path="$2"

  if [ -L "$link_path" ] && [ "$(readlink "$link_path")" = "$target" ]; then
    echo -e "  ${GREEN}OK${NC} $link_path"
    skipped=$((skipped + 1))
    return
  fi

  if [ -L "$link_path" ]; then
    echo -e "  ${YELLOW}RELINK${NC} $link_path (was -> $(readlink "$link_path"))"
    rm "$link_path"
  elif [ -e "$link_path" ]; then
    echo -e "  ${RED}BLOCKED${NC} $link_path (real file/dir exists -- move it manually)"
    blocked=$((blocked + 1))
    return
  fi

  mkdir -p "$(dirname "$link_path")"
  ln -s "$target" "$link_path"
  echo -e "  ${GREEN}LINKED${NC} $link_path -> $target"
  ok=$((ok + 1))
}

step "Claude config symlinks (public)"

mkdir -p "$HOME/.claude"
mkdir -p "$HOME/.claude/hooks"
mkdir -p "$HOME/.claude/skills"

# Files
for f in CLAUDE.md MISTAKES.md MISTAKES-LOG.md LEARNINGS.md LEARNINGS-ARCHIVE.md persona.md README.md; do
  link "$CONFIG_DIR/$f" "$HOME/.claude/$f"
done

# settings.json is copied (not symlinked) so local changes don't pollute the repo
if [ ! -f "$HOME/.claude/settings.json" ]; then
  cp "$CONFIG_DIR/settings.json" "$HOME/.claude/settings.json"
  sed -i '' "s|__HOME__|$HOME|g" "$HOME/.claude/settings.json"
  echo -e "  ${GREEN}COPIED${NC} settings.json"
  ok=$((ok + 1))
else
  echo -e "  ${GREEN}OK${NC} settings.json (already exists, not overwriting)"
  skipped=$((skipped + 1))
fi

# Directories (all-public, safe to directory-symlink)
link "$CONFIG_DIR/reference" "$HOME/.claude/reference"
link "$CONFIG_DIR/agents" "$HOME/.claude/agents"

# Hooks (per-file symlinks to allow private hooks to coexist)
for f in "$CONFIG_DIR"/hooks/*.sh; do
  [ -f "$f" ] || continue
  link "$f" "$HOME/.claude/hooks/$(basename "$f")"
done

# Skills (per-directory symlinks to allow private skills to coexist)
for d in "$CONFIG_DIR"/skills/*/; do
  [ -d "$d" ] || continue
  name="$(basename "$d")"
  link "$d" "$HOME/.claude/skills/$name"
done

echo -e "\n  Created: ${GREEN}${ok}${NC}  Skipped: ${YELLOW}${skipped}${NC}  Blocked: ${RED}${blocked}${NC}"
echo -e "\nDone. Run 'claude' to start using your config."
