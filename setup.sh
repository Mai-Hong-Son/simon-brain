#!/usr/bin/env bash
# setup.sh — dựng lại nền simon-brain trên một máy mới. Idempotent: chạy lại bao nhiêu lần cũng an toàn.
#
# Máy mới chỉ cần:
#   git clone <remote> ~/Documents/simon-brain
#   cd ~/Documents/simon-brain && ./setup.sh
#
# Git sync phần NỘI DUNG (wiki/skills/agents); script này cắm phần DÂY ĐIỆN mà git
# không mang theo được: symlink vào ~/.claude/ để Claude Code load, và vùng ~/exp/.
set -euo pipefail

BRAIN="$(cd "$(dirname "$0")" && pwd)"

# link <target> <linkpath> — tạo/sửa symlink; không đè file thật.
link() {
  local target="$1" linkpath="$2"
  if [ -L "$linkpath" ]; then
    [ "$(readlink "$linkpath")" = "$target" ] && { echo "ok      $linkpath"; return; }
    rm "$linkpath"
  elif [ -e "$linkpath" ]; then
    echo "SKIP    $linkpath — file thật đang tồn tại, xử lý tay"; return
  fi
  ln -s "$target" "$linkpath"
  echo "linked  $linkpath -> $target"
}

# 1. Lối tắt ~/simon-brain
link "$BRAIN" "$HOME/simon-brain"

# 2. Skills: symlink TỪNG item (không thay cả thư mục — ~/.claude/skills còn đồ khác)
mkdir -p "$HOME/.claude/skills" "$HOME/.claude/agents"
for d in "$BRAIN"/skills/*/; do
  [ -d "$d" ] || continue
  link "${d%/}" "$HOME/.claude/skills/$(basename "$d")"
done

# 3. Agents: từng file .md
for f in "$BRAIN"/agents/*.md; do
  [ -e "$f" ] || continue
  link "$f" "$HOME/.claude/agents/$(basename "$f")"
done

# 4. Vùng thí nghiệm (AGENTS.md §0 — mặc định không ghi wiki)
mkdir -p "$HOME/exp"

echo "Done. Nền simon-brain đã cắm vào ~/.claude/"
