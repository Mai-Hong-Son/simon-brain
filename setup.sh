#!/usr/bin/env bash
# setup.sh — rebuild the simon-brain foundation on a new machine. Idempotent: safe to re-run any time.
#
# A new machine only needs:
#   git clone <remote> ~/Documents/simon-brain
#   cd ~/Documents/simon-brain && ./setup.sh
#
# The repo always lives at ~/Documents/simon-brain — no extra shortcuts are created.
#
# Git syncs the CONTENT (wiki/skills/agents); this script plugs in the WIRING git can't
# carry: symlinks into ~/.claude/ so Claude Code loads them, and the products/spikes folders.
set -euo pipefail

BRAIN="$(cd "$(dirname "$0")" && pwd)"

# link <target> <linkpath> — create/fix a symlink; never overwrites a real file.
link() {
  local target="$1" linkpath="$2"
  if [ -L "$linkpath" ]; then
    [ "$(readlink "$linkpath")" = "$target" ] && { echo "ok      $linkpath"; return; }
    rm "$linkpath"
  elif [ -e "$linkpath" ]; then
    echo "SKIP    $linkpath — a real file exists here, handle manually"; return
  fi
  ln -s "$target" "$linkpath"
  echo "linked  $linkpath -> $target"
}

# 1. Skills: symlink EACH item (never replace the whole dir — ~/.claude/skills holds other things)
mkdir -p "$HOME/.claude/skills" "$HOME/.claude/agents"
for d in "$BRAIN"/skills/*/; do
  [ -d "$d" ] || continue
  link "${d%/}" "$HOME/.claude/skills/$(basename "$d")"
done

# 2. Agents: each .md file
for f in "$BRAIN"/agents/*.md; do
  [ -e "$f" ] || continue
  link "$f" "$HOME/.claude/agents/$(basename "$f")"
done

# 3. Project group folders (AGENTS.md §0 — spikes don't write to the wiki by default)
mkdir -p "$HOME/Documents/products" "$HOME/Documents/spikes"

echo "Done. The simon-brain foundation is plugged into ~/.claude/"
