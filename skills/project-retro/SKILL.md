---
name: project-retro
description: Run a retrospective after a milestone/project — distill lessons into the simon-brain wiki at the right layer. Use when the user says retro, "rút kinh nghiệm", or finishes a milestone.
---

# Project retro — the lesson-distillation ritual

The write target is the **simon-brain wiki** (`~/Documents/simon-brain/wiki/`), governed by that
repo's `AGENTS.md`.

## Procedure

1. Read: the `wiki/projects/<project>.md` page (if any), HANDOFF/PROGRESS/`docs/decisions/` in
   the product repo, and the milestone's git log.
2. Identify: (a) mistakes that cost time, (b) procedures/patterns repeated ≥2 times,
   (c) decisions worth recording.
3. Layer each lesson per AGENTS.md §3:
   - True only for this project → propose writing to `wiki/projects/<project>.md`.
   - Reusable AND already seen in ≥2 projects → propose a `wiki/concepts/` page + a link from
     the project page.
   - Only 1 project so far but looks general → write to the project page, tag it a
     *promotion candidate* (lint will track it).
   - A working standard Sơn expects of agents → propose updating `wiki/entities/son.md`.
4. Present a numbered list with rationale, **at most 5 items** (forces prioritization).
   STOP and wait for Sơn's per-item approval.
5. Only after approval: write the chosen items via the ingest workflow (AGENTS.md §5.1),
   update `index.md`, append one line to `log.md`, commit per AGENTS.md §6.

## Rules

- Every lesson passes the quality gate: *still true and still useful one month from now?*
- Record durable conclusions, never session narrative (AGENTS.md §2).
- **Don't wait for the retro**: the moment a lesson looks general mid-work → propose it RIGHT
  AWAY, one item at a time, through the same gate. The retro is the final sweep, not the only door.
