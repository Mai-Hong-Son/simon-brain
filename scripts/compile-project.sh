#!/usr/bin/env bash
# compile-project.sh <project> — prints a project's decision list for its wiki page, one line per
# ADR, generated from the ADRs' own `Decision:` and `Status:` lines (AGENTS.md §0: the repo is the
# source, the wiki page is compiled from it). Paste it between the page's adr-list markers.
# Exit: 0 list printed | 1 printed, but an ADR lacks a line (named on stderr) | 2 usage
#       3 project not converted yet (no ADR has a `Decision:` line) | 4 project not on this machine
set -uo pipefail

name="${1:-}"
[ -n "$name" ] || { echo "usage: compile-project.sh <project>" >&2; exit 2; }

dir=""
IFS=: read -ra roots <<< "${PROJECT_ROOTS:-$HOME/Documents/products:$HOME/Documents/spikes}"
for r in "${roots[@]}"; do [ -d "$r/$name" ] && dir="$r/$name"; done
[ -n "$dir" ] || exit 4

shopt -s nullglob
adrs=("$dir"/docs/decisions/[0-9]*.md)
[ "${#adrs[@]}" -gt 0 ] && grep -q '^Decision:' "${adrs[@]}" || exit 3

rc=0
for f in "${adrs[@]}"; do
  base="$(basename "$f")"; num="${base%%-*}"
  decision="$(sed -n 's/^Decision: *//p' "$f" | head -1)"
  # "Status: **accepted** (Sơn…)" and "Status: proposed — branch…" both give the first word.
  status="$(grep -m1 -oE 'Status:[* ]*[A-Za-z-]+' "$f" | sed -E 's/^Status:[* ]*//' | tr '[:upper:]' '[:lower:]')"
  [ -n "$decision" ] || { echo "$base: no Decision: line" >&2; rc=1; continue; }
  [ -n "$status" ] || { echo "$base: no Status: line" >&2; rc=1; continue; }
  echo "- **ADR $num** ($status): $decision"
done
exit "$rc"
