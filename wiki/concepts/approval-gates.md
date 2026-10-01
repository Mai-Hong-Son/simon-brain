---
title: Approval gates & adversarial review
type: concept
status: stable
updated: 2026-10-01
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
- **Open design questions are resolved one at a time**, each with a recommended answer and one
  sentence of reasoning — a question without a stance offloads the design onto Sơn. Read the
  codebase and prior decisions before asking; never roll past an unresolved dependency.

## Git and PR conventions (every project)

- Branch per concern on serious projects: `feature/<slug>`, `fix/<slug>`, `perf/`, `chore/`,
  `docs/` — never straight to `main`. Spikes may commit straight.
- Commit only on green: run the suite first. Message `type(scope): message`, imperative, English,
  under 72 characters. Never force-push a shared branch, never commit `.env` or a secret, never
  rewrite `main`'s history ([[engineering-rules]] #2).
- One concern per PR; the description says what, why, and how it was tested.

## Every PR gets a review before Sơn sees it — from a context that has not seen the code

Not optional and not sized away: a ≤2-file PR gets `/code-review` at low effort, a logic or data
PR at high. The cycle: open the PR → run `/code-review` (or a fresh agent given the PR's stated
scope; never self-review in the same session) → fix confirmed defects and push → write the outcome
into the PR description (`Review: N findings · M fixed · K dismissed (why)`) → only then report
to Sơn. Sơn reviews what survived a review, never a first draft. "No findings" with no review run
is a skipped gate; a review that found nothing says so explicitly.

## Adversarial review

- To challenge a plan/diff, use **a context that has NEVER seen the code** (spawn a fresh agent /
  `/code-review`) — self-review inside the same context is confirmation bias, not review.
- At most **3 rounds** of debate; stop early on consensus; unresolved → present BOTH positions to Sơn.
- Every claim carries `file:line` evidence; concede points that don't hold.
- Separate real defects from false positives before reporting.

## The gate has an outcome — check that the work LANDED, by content

A merge request can end merged **or closed**, and a batch cleanup closes both kinds. Verify the
code is in the target branch; never infer it from the MR list or from branches left on the remote.

- **"No open MRs" is not "everything merged."** Measured 2026-09-28: a consolidation closed the
  superseded MRs and took one that was not superseded with them. Six fixes were missing from `main`
  for half a day and nobody noticed — the checks being used were "are there open MRs?" (zero) and
  "does the branch still exist?" (yes), and neither one answers the question.
- **Ask by content:** `git cherry origin/main origin/<branch>` marks each commit `-` when its
  PATCH is already in the target and `+` when it is not. It survives cherry-picks and rebases,
  which `git merge-base --is-ancestor` does not — consolidate a branch by cherry-picking and the
  ancestor test reports "unmerged" for work that is fully present. Confirm a headline file exists
  in the target (`git cat-file -e origin/main:path`) before calling anything lost or landed.
- **Read the forge, not its leftovers.** Branch on the remote ≠ MR open. With `glab`/`gh`
  available, `glab mr list` answers directly; without it, say the state is unverified rather than
  inferring it — a wrong "you still have to close these" is how the one MR that mattered got closed.
