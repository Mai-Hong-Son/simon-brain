---
name: git-workflow
description: Shared git conventions for every project — commit format, branching, PR flow. Use when committing, branching, or preparing a PR.
---

# Git workflow

- Commit: `type(scope): message` — types: feat, fix, refactor, test, docs, chore. Imperative, <72 chars, English.
- Branch: `feature/<slug>`, `fix/<slug>`. Never commit straight to main on serious projects.
- Before committing: run the test suite; commit only on green.
- PR: one concern per PR; description = what + why + how tested.
  Significant diffs → run an adversarial review with a fresh context before Sơn's review
  (wiki: `concepts/approval-gates`).
- Never: force-push shared branches, commit `.env`/secrets, rewrite main's history.
