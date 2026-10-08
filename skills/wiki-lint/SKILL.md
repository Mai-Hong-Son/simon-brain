---
name: wiki-lint
description: Health-check the simon-brain wiki (AGENTS.md §5.3) — run scripts/wiki-lint.sh for the mechanical counts, read for what a script cannot see (contradictions, duplicate topics, lessons repeated across projects), report, and STOP for Sơn's pick. Use when the user says "lint", "lint wiki", "khám wiki", "dọn wiki", or after every ~10 ingests.
---

# Wiki lint — the health check

Governed by `AGENTS.md` §5.3 (lint: report, no self-applied fixes). Talk to Sơn in Vietnamese;
anything written to the repo afterwards is English.

## Step 1 — Numbers from the script, never from memory

```bash
cd ~/Documents/simon-brain && git pull --rebase && ./scripts/wiki-lint.sh
```

The script is the ground truth for: frontmatter, broken wikilinks, orphans, pages missing from
`index.md`, hubs over 100 lines, content pages over 100 lines (context cost when @imported),
bullets over 10 lines, §2 narrative wording, stale pages, contradiction markers, promotion
candidates, ingests since the last lint, malformed log lines, declared readers (including
whether this machine ever approved a repo's external @imports — unapproved, the page is silently
skipped), context budgets (always tier ≤ 2,500 words, each project-imported page ≤ 5,000), and
`open-loops.md` lines older than 14 days. Quote its counts; do not recount. An OVER BUDGET line
is a finding, always.

## Step 2 — What the script cannot see

Read `wiki/index.md`, then every page the script flagged, then skim the rest, looking for:

- **Contradictions between pages** without a marker (a date, a rule, a path stated two ways).
- **Wiki vs repo drift**: a claim about a product's current state that the repo no longer backs
  (the repo wins on current state; the wiki wins on decision history — AGENTS.md §2).
- **Lessons repeated across ≥2 project pages** under different wording → one `concepts/` page
  (§3 promotion rule). Name the pages and the shared rule.
- **Duplicate-topic pages** that should merge; **data gaps**: a concept mentioned on several pages
  that has no page of its own.
- **Demotion**: a `concepts/` page used by one project only, with no sign of reuse.

## Step 3 — Report and STOP

One table, severity first, each row one fix:

```
| # | Finding | Evidence (page:line or script section) | Proposed action |
```

Then: questions worth digging into, sources worth finding. Stop. Sơn picks rows by number;
fix only those, append one `lint` line to `wiki/log.md`, commit `wiki(lint): ...`, push.

## Rules

- Never fix anything before Sơn picks — not even a typo.
- Long pages are reported, not judged: a long page that is **not** @imported costs nothing per
  session; one that is costs every session. Say which case applies.
- The script's "narrative wording" hits include quotations; check each by hand before listing it.
