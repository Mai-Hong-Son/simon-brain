---
name: wrap-up
description: End-of-session ritual — verify every completion claim with fresh evidence, sweep the session and the machine-local auto-memory for durable lessons, print the AGENTS.md §7 proposal table, then STOP and wait for Sơn's pick. Use when the user says "wrap up", "wrap-up", "kết thúc session", "tổng kết", "chốt lại", "đề xuất wiki", or before closing any session that reached a conclusion.
---

# Wrap-up — the end-of-session ritual

Governed by simon-brain's `AGENTS.md`: §1 (quality gate: still true and still useful one month
from now?), §2 (durable conclusions, never session narrative), §3 (project page vs concept page),
§7 (propose, then wait for approval). This skill is the hand; `AGENTS.md` is the law.
Talk to Sơn in Vietnamese; everything written to a repo is English.

## Step 1 — Verify before claiming

For every "done", "fixed" or "passing" this session is about to report:

1. **Identify** the command that proves it (test suite, build, lint, a reproduction).
2. **Run** it now, in full. Output from earlier in the session is not evidence — code changed since.
3. **Read** the whole output and the exit code. Count failures.
4. **Confirm** it proves the exact claim, not a neighbouring one.
5. **Only then** report, citing the command and the exit code.

Forbidden in a completion claim: *should*, *probably*, *seems to*, *likely*, *I believe*.
No proving command exists → say so and ask how Sơn wants it verified; do not claim.
A bug fix is proven only when its test **fails with the fix reverted** and passes with it restored.
Clear `__pycache__` first in Python — a same-length patch within the same second can leave stale
bytecode in place (see [[vn30f-bot]]).

## Step 2 — Sweep for durable conclusions

Read, in this order:

- **This session**: decisions taken, measurements with their numbers and dates, failures and what
  they taught, corrections Sơn made.
- **The product's auto-memory**, `~/.claude/projects/<project-slug>/memory/`: machine-local and
  never git-synced, so a durable lesson sitting there is invisible on every other machine until it
  reaches the wiki. Each file is a candidate; `MEMORY.md` is the index.
- **The product's `HANDOFF.md`** (or its CLAUDE.md "Notes"), for items waiting on the outside world.

## Step 3 — Gate each candidate

- §1: still true **and** still useful one month from now? Fail either half → out.
- §2: can it be written as a present-tense rule with its reason? If it only reads as "we tried A,
  then B", extract the rule or drop it.
- §3: true only in this project → `wiki/projects/<name>.md`; already seen in ≥2 projects →
  `wiki/concepts/<slug>.md` plus a one-line link from each project page; looks general but seen
  once → project page, tagged *promotion candidate*.
- Sơn's feedback on how agents should work → `wiki/entities/son.md`.
- Something **waiting on the outside world** is not wiki material: it goes to the product's
  `HANDOFF.md`, or to simon-brain's `open-loops.md` when it is platform-level.

## Step 4 — Print the table and STOP

Output exactly this, then stop:

```
## Proposed wiki updates

| # | Page | Action | Content (1 sentence) | Quality gate |
|---|------|--------|----------------------|--------------|
| 1 | projects/<name>.md | edit | <one sentence> | ✅ / ❌ reason |
| 2 | concepts/<slug>.md | create | <one sentence> | ✅ |
| 3 | index.md | edit | one line for the new page | ✅ |

Not proposed (failed the gate): <item — reason>, ...
Open loops recorded in: <HANDOFF.md / open-loops.md — item>, or "none"
Auto-memory entries this supersedes: <file names>, or "none"
```

An empty sweep is a valid outcome: write "No proposals — <reason>" and stop. Never invent a
lesson to fill the table. Do not summarise the session as narrative; the table is the deliverable.

## Step 5 — Only after Sơn answers with numbers

1. `git pull --rebase` in simon-brain.
2. Write the approved items; cross-link both ways; frontmatter `updated` set to today's absolute date.
3. Update `wiki/index.md`; append one line to `wiki/log.md` in the fixed format.
4. Trim the auto-memory entry each approved item supersedes to a one-line pointer at the wiki page,
   so the two homes cannot drift.
5. `git pull --rebase` again, commit `wiki(ingest): <topic>`, push, report the touched pages.

## Rules

- Nothing is written to `wiki/` without a number from Sơn. The one exception: Sơn says
  "ingest on your own, don't ask" — then write, and still report the touched pages.
- One wrap-up per session; a second call in the same session only adds what changed since.
- This is the daily door; `project-retro` is the final sweep after a milestone. Do not wait for
  the retro to propose a lesson that already looks general.
