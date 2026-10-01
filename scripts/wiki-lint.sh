#!/usr/bin/env bash
# wiki-lint.sh — mechanical health check of wiki/ (AGENTS.md §5.3). Reports, never fixes.
# Usage: ./scripts/wiki-lint.sh            full report
#        ./scripts/wiki-lint.sh --summary  one line per check
# Exit code is always 0: this is a report for Sơn to pick from, not a gate.
set -uo pipefail

BRAIN="$(cd "$(dirname "$0")/.." && pwd)"
WIKI="$BRAIN/wiki"
SUMMARY=0; [ "${1:-}" = "--summary" ] && SUMMARY=1
STALE_DAYS=90; HUB_MAX=100; BULLET_MAX=10; LINT_EVERY=10

pages() { find "$WIKI/concepts" "$WIKI/entities" "$WIKI/projects" -name '*.md' | sort; }
slug()  { basename "$1" .md; }
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
today_s=$(date +%s)
for p in $(pages); do
  u="$(fm "$p" updated)"; [[ "$u" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || continue
  age=$(( (today_s - $(date -j -f %Y-%m-%d "$u" +%s)) / 86400 ))
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
# prose had been opened in at most 3 of 20 product sessions. So `read_when` is checked against the
# thing that would do the loading, not taken on trust.
GLOBAL="$BRAIN/config/global-rules.md"
links_to() { grep -q "\[\[$2\]\]\|\[\[$2|" "$1"; }   # links_to <file> <slug>
out=(); unverified=(); loaded=()
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
        out+=("$s: '$r', but $name/CLAUDE.md has no @import of it"); fi
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
[ "$SUMMARY" = 1 ] || { [ "${#unverified[@]}" -gt 0 ] && printf 'not verifiable here: %s\n' "${unverified[@]}"; }
report "$always_words" "Words loaded into EVERY session (global rules + pages marked 'always')"

[ "$SUMMARY" = 1 ] || printf '\nDone. This is a report (AGENTS.md §5.3): nothing was changed. Pick items; the agent fixes only those.\n'
