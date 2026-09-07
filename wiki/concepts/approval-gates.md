---
title: Approval gates & adversarial review
type: concept
status: stable
updated: 2026-09-07
tags: [process, review, quality]
sources: [ai-company/CLAUDE.md (workflow + debate mechanism), ai-company/.claude/agents (orchestrator, qa-reviewer)]
---

# Approval gates & adversarial review

Distilled from [[ai-company]]'s workflow + debate mechanism, keeping what stays valuable after
dropping the multi-agent model (now solo agent — see [[simon-platform]]).

## Size the process by SIZE, not ambition

- ≤2 files, no logic/data change → lightweight: confirm scope → fix → report. Never use this
  lane to smuggle a logic change past review.
- Touches logic/data, single stack → short plan → plan approval → build + tests → merge approval.
- Large / cross-stack → full plan → plan approval → **test-case list approved before writing
  tests** → build → merge approval.
- Torn between two levels → **size up**.

## Human gates — never skipped

- Never start implementing before the plan gate.
- Every plan ends with "awaiting approval before execution".
- Tech research → report with a recommendation → Sơn approves adoption; stack deviation → ADR
  before code.

## Adversarial review

- To challenge a plan/diff, use **a context that has NEVER seen the code** (spawn a fresh agent /
  `/code-review`) — self-review inside the same context is confirmation bias, not review.
- At most **3 rounds** of debate; stop early on consensus; unresolved → present BOTH positions to Sơn.
- Every claim carries `file:line` evidence; concede points that don't hold.
- Separate real defects from false positives before reporting.
