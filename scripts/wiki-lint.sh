#!/usr/bin/env bash
# wiki-lint.sh — mechanical health check of wiki/ (AGENTS.md §5.3). Reports, never fixes.
# Usage: ./scripts/wiki-lint.sh            full report
#        ./scripts/wiki-lint.sh --summary  one line per check
# Exit code is 0: this is a report for Sơn to pick from, not a gate (2 only on a malformed budget
# override).
set -uo pipefail

BRAIN="$(cd "$(dirname "$0")/.." && pwd)"
WIKI="$BRAIN/wiki"
SUMMARY=0; [ "${1:-}" = "--summary" ] && SUMMARY=1
STALE_DAYS=90; HUB_MAX=100; BULLET_MAX=10; LINT_EVERY=10
# Context budgets, in words (≈1.3 tokens each). Every word under them is paid by every session they
# load into; overridable from the environment so the check can be seen to fire.
ALWAYS_MAX=${ALWAYS_MAX:-2500}; PROJECT_MAX=${PROJECT_MAX:-5000}; LOOP_DAYS=${LOOP_DAYS:-14}
for v in ALWAYS_MAX PROJECT_MAX LOOP_DAYS; do
  [[ "${!v}" =~ ^[0-9]+$ ]] || { echo "wiki-lint: $v must be a whole number, got '${!v}'" >&2; exit 2; }
done

pages() { find "$WIKI/concepts" "$WIKI/entities" "$WIKI/projects" -name '*.md' | sort; }
slug()  { basename "$1" .md; }
# days_since YYYY-MM-DD → whole days from that midnight to today's; fails on a date that does not
# exist (BSD date silently rolls 2026-02-30 over to 03-02, so the round trip is checked).
today_s=$(date -j -f '%Y-%m-%d %H:%M:%S' "$(date +%Y-%m-%d) 00:00:00" +%s)
days_since() {
  local s; s=$(date -j -f '%Y-%m-%d %H:%M:%S' "$1 00:00:00" +%s 2>/dev/null) || return 1
  [ "$(date -j -r "$s" +%Y-%m-%d)" = "$1" ] || return 1
  echo $(( (today_s - s) / 86400 ))
}
fm()    { awk -v k="$2" '/^---$/{n++; next} n==1 && $1==k":" {sub(/^[^:]*: */,""); print; exit}' "$1"; }

section() { printf '\n== %s\n' "$1"; }
report()  { # report <count> <label> [lines...]
  local n="$1" label="$2"; shift 2
  if [ "$SUMMARY" = 1 ]; then printf '%3d  %s\n' "$n" "$label"; return; fi
  section "$label: $n"; [ "$n" -gt 0 ] && printf '%s\n' "$@"
}

# ---------------------------------------------------------------- 1. frontmatter
out=()
for p in $(pages); do
  for k in title type status updated tags sources; do
    [ -z "$(fm "$p" "$k")" ] && out+=("$(slug "$p"): missing '$k'")
  done
  u="$(fm "$p" updated)"
  [[ "$u" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || out+=("$(slug "$p"): 'updated' is not YYYY-MM-DD ($u)")
done
report "${#out[@]}" "Frontmatter problems" "${out[@]+"${out[@]}"}"

# ---------------------------------------------------------------- 2. broken wikilinks
out=()
while IFS=: read -r file link; do
  find "$WIKI" -name "$link.md" | grep -q . || out+=("$(slug "$file") -> [[$link]]")
done < <(grep -rH '\[\[' "$WIKI" --include='*.md' | grep -v -E '^[^:]*:> ' | grep -o '^[^:]*:.*' \
          | awk -F: '{f=$1; $1=""; while (match($0,/\[\[[^]|#]*/)) { print f ":" substr($0,RSTART+2,RLENGTH-2); $0=substr($0,RSTART+RLENGTH) } }' | sort -u)
report "${#out[@]}" "Broken wikilinks (pages worth writing, or typos)" "${out[@]+"${out[@]}"}"

# ---------------------------------------------------------------- 3. orphans (no inbound link from a content page; index.md does not count)
out=()
for p in $(pages); do
  s="$(slug "$p")"
  grep -rl "\[\[$s\]\]\|\[\[$s|" "$WIKI/concepts" "$WIKI/entities" "$WIKI/projects" | grep -v "/$s.md$" | grep -q . || out+=("$s")
done
report "${#out[@]}" "Orphans (no inbound link besides index.md)" "${out[@]+"${out[@]}"}"

# ---------------------------------------------------------------- 4. missing from index.md
out=()
for p in $(pages); do grep -q "\[\[$(slug "$p")\]\]" "$WIKI/index.md" || out+=("$(slug "$p")"); done
report "${#out[@]}" "Pages missing from index.md" "${out[@]+"${out[@]}"}"

# ---------------------------------------------------------------- 5. hubs over the line (index.md + type: hub)
out=()
for p in "$WIKI/index.md" $(pages); do
  t="$(fm "$p" type)"; n=$(wc -l < "$p" | tr -d " ")
  if [ "$(slug "$p")" = index ] || [ "$t" = hub ]; then
    [ "$n" -gt "$HUB_MAX" ] && out+=("$(slug "$p"): $n lines (hub limit $HUB_MAX)")
  fi
done
report "${#out[@]}" "Hubs over $HUB_MAX lines (§4)" "${out[@]+"${out[@]}"}"

# ---------------------------------------------------------------- 6. long pages (informational: every line of an @imported page is loaded each session)
out=()
for p in $(pages); do n=$(wc -l < "$p" | tr -d " "); [ "$n" -gt "$HUB_MAX" ] && out+=("$(slug "$p"): $n lines, $(wc -w < "$p" | tr -d " ") words"); done
report "${#out[@]}" "Content pages over $HUB_MAX lines (context cost if @imported)" "${out[@]+"${out[@]}"}"

# ---------------------------------------------------------------- 7. bullets over BULLET_MAX lines
out=()
for p in $(pages); do
  while read -r line; do out+=("$(slug "$p"): $line"); done < <(
    awk -v M="$BULLET_MAX" '
      function flush(){ if (n>M) printf "bullet at line %d = %d lines\n", s, n }
      /^- /{ flush(); s=NR; n=1; next }
      /^  /{ if (s) n++; next }
      { flush(); s=0; n=0 }
      END{ flush() }' "$p")
done
report "${#out[@]}" "Bullets over $BULLET_MAX lines (extract a child page, §4)" "${out[@]+"${out[@]}"}"

# ---------------------------------------------------------------- 8. §2 narrative language
out=()
while IFS= read -r l; do out+=("$l"); done < <(
  grep -rn -i -E '\b(today|yesterday|this session|in this session|we tried|just now|the agent ran)\b' \
    "$WIKI/concepts" "$WIKI/entities" "$WIKI/projects" | grep -v -E '^[^:]*:[0-9]+:(sources:|> )' \
    | sed "s|$WIKI/||" | cut -c1-120)
report "${#out[@]}" "Narrative wording (§2) — check each by hand, quotes are allowed" "${out[@]+"${out[@]}"}"

# ---------------------------------------------------------------- 9. stale pages
out=()
for p in $(pages); do
  u="$(fm "$p" updated)"; [[ "$u" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || continue
  age=$(days_since "$u") || { out+=("$(slug "$p"): 'updated' is not a real date ($u)"); continue; }
  [ "$age" -gt "$STALE_DAYS" ] && out+=("$(slug "$p"): updated $u ($age days)")
done
report "${#out[@]}" "Stale pages (updated > $STALE_DAYS days ago)" "${out[@]+"${out[@]}"}"

# ---------------------------------------------------------------- 10. contradiction markers
out=()
while IFS= read -r l; do out+=("$l"); done < <(grep -rn 'Contradiction' "$WIKI" --include='*.md' | sed "s|$WIKI/||" | cut -c1-120)
report "${#out[@]}" "Unresolved ⚠️ Contradiction markers" "${out[@]+"${out[@]}"}"

# ---------------------------------------------------------------- 11. promotion candidates (§3)
out=()
while IFS= read -r l; do out+=("$l"); done < <(grep -rn -i 'promotion candidate' "$WIKI/projects" | sed "s|$WIKI/projects/||" | cut -c1-110)
report "${#out[@]}" "Promotion candidates tagged in project pages (§3: ≥2 projects → concept)" "${out[@]+"${out[@]}"}"

# ---------------------------------------------------------------- 12. log cadence
ingests=$(awk '/\] lint \|/{n=0} /\] ingest \|/{n++} END{print n+0}' "$WIKI/log.md")
last_lint=$(grep -o '^## \[[0-9-]*\] lint' "$WIKI/log.md" | tail -1 | grep -o '[0-9-]\{10\}')
bad_log=$(grep -c -v -E '^(## \[[0-9]{4}-[0-9]{2}-[0-9]{2}\] (ingest|query|lint) \| .* \| @[a-z-]+$|#|>|$)' "$WIKI/log.md")
report "$ingests" "Ingests since last lint (${last_lint:-never}; lint is due every $LINT_EVERY)"
report "$bad_log" "log.md lines not in the fixed format"

# ---------------------------------------------------------------- 13. readers (AGENTS.md §0: a page declares who reads it, and the declaration must be TRUE)
# A page nothing loads is a page nobody reads: measured 2026-10-01, pages that were only named in
# prose had each been opened in 2 of the 16 product sessions before that day. So `read_when` is
# checked against the thing that would do the loading, not taken on trust.
GLOBAL="$BRAIN/config/global-rules.md"
links_to() { grep -q "\[\[$2\]\]\|\[\[$2|" "$1"; }   # links_to <file> <slug>
out=(); unverified=(); loaded=(); unapproved=()
# An @import outside the repo is skipped until someone approves external imports for that repo in
# an interactive session; the flag lives in ~/.claude.json, so this check is per machine.
# Measured 2026-10-02: four repos had the import line, and a fresh session could not quote the page.
CLAUDE_JSON="${CLAUDE_JSON:-$HOME/.claude.json}"
approved() { # exit 0 approved, 1 not approved, anything else unknown (no python3, bad file)
  python3 - "$CLAUDE_JSON" "$1" <<'PY'
import json, os, sys
key = lambda d: os.path.realpath(d.rstrip("/"))
try:
    projects = json.load(open(sys.argv[1]))["projects"]
    flags = {key(k): v for k, v in projects.items()}.get(key(sys.argv[2])) or {}
    sys.exit(0 if flags.get("hasClaudeMdExternalIncludesApproved") is True else 1)
except Exception: sys.exit(2)
PY
}
json_unreadable=0
always_words=$(wc -w < "$GLOBAL" | tr -d ' ')
for p in $(pages); do
  s="$(slug "$p")"; rel="${p#"$BRAIN"/}"; r="$(fm "$p" read_when)"
  case "$r" in
    always)
      grep -q "^@.*/$rel\$" "$GLOBAL" || out+=("$s: 'always', but config/global-rules.md has no @import of it")
      always_words=$(( always_words + $(wc -w < "$p" | tr -d ' ') )); loaded+=("$p") ;;
    project:*)
      name="${r#project:}"; dir=""
      for d in "$HOME/Documents/products/$name" "$HOME/Documents/spikes/$name"; do [ -d "$d" ] && dir="$d"; done
      if [ -z "$dir" ]; then unverified+=("$s: project '$name' is not on this machine")
      elif ! grep -q "^@.*/$rel\$" "$dir/CLAUDE.md" 2>/dev/null; then
        out+=("$s: '$r', but $name/CLAUDE.md has no @import of it")
      else approved "$dir" 2>/dev/null; case $? in
        0) ;;
        1) unapproved+=("$s: ${dir/#$HOME/~} never approved external imports — sessions there skip the page") ;;
        *) [ "$json_unreadable" = 1 ] || unverified+=("${CLAUDE_JSON/#$HOME/~} unreadable (or no python3): import approval unknown")
           json_unreadable=1 ;;
      esac; fi
      loaded+=("$p") ;;
    skill:*)
      name="${r#skill:}"
      grep -q "$s" "$BRAIN/skills/$name/SKILL.md" 2>/dev/null || out+=("$s: '$r', but skills/$name/SKILL.md never names it")
      loaded+=("$p") ;;
    on-demand*) : ;;   # judged below, once every loaded page is known
    "") out+=("$s: no read_when — nothing is set up to read this page") ;;
    *)  out+=("$s: read_when '$r' is not one of: always | project:<name> | skill:<name> | on-demand — <question>") ;;
  esac
done
for p in $(pages); do
  s="$(slug "$p")"; r="$(fm "$p" read_when)"; [[ "$r" == on-demand* ]] || continue
  found=0
  for l in "${loaded[@]+"${loaded[@]}"}"; do links_to "$l" "$s" && { found=1; break; }; done
  [ "$found" = 1 ] || out+=("$s: on-demand, but no page that IS loaded links to it")
done
report "${#out[@]}" "Pages whose declared reader does not exist (read_when, §0)" "${out[@]+"${out[@]}"}"
report "${#unverified[@]}" "Not verifiable on this machine" "${unverified[@]+"${unverified[@]}"}"
report "${#unapproved[@]}" "Imports never approved on this machine (open claude there once, approve)" "${unapproved[@]+"${unapproved[@]}"}"
report "$always_words" "Words loaded into EVERY session (global rules + pages marked 'always')"

# ---------------------------------------------------------------- 14. context budgets
out=()
[ "$always_words" -gt "$ALWAYS_MAX" ] && out+=("always tier: $always_words words (budget $ALWAYS_MAX) — cut a rule's story, keep the rule")
for p in $(pages); do
  r="$(fm "$p" read_when)"; [[ "$r" == project:* ]] || continue
  n=$(wc -w < "$p" | tr -d ' ')
  [ "$n" -gt "$PROJECT_MAX" ] && out+=("$(slug "$p"): $n words, imported by every '${r#project:}' session (budget $PROJECT_MAX)")
done
report "${#out[@]}" "OVER BUDGET — context loaded automatically" "${out[@]+"${out[@]}"}"

# ---------------------------------------------------------------- 15. open loops left open
out=()
if [ -f "$BRAIN/open-loops.md" ]; then
  while IFS= read -r l; do
    d="$(printf '%s' "$l" | grep -o '^- \[[0-9-]\{10\}\]' | grep -o '[0-9-]\{10\}')"
    [ -n "$d" ] || continue
    age=$(days_since "$d") || { out+=("not a real date: $(printf '%s' "$l" | cut -c1-100)"); continue; }
    [ "$age" -gt "$LOOP_DAYS" ] && out+=("$age days: $(printf '%s' "$l" | cut -c1-110)")
  done < <(sed -n '/^## Open items$/,$p' "$BRAIN/open-loops.md")
else out+=("open-loops.md is missing — /wrap-up has nowhere to record platform-level loops"); fi
report "${#out[@]}" "Open loops older than $LOOP_DAYS days (open-loops.md)" "${out[@]+"${out[@]}"}"

[ "$SUMMARY" = 1 ] || printf '\nDone. This is a report (AGENTS.md §5.3): nothing was changed. Pick items; the agent fixes only those.\n'
