---
title: Sơn
type: entity
status: stable
updated: 2026-09-07
tags: [user, preferences, standards]
sources: [ai-company/.claude/agents (dev-frontend, dev-mobile), feedback memory 07-08/2026]
---

# Sơn (Mai Hồng Sơn)

Owner of this system. Every agent working with Sơn needs these facts.

## Expertise

- Senior React dev, **~10 years of React Native** — JS/TS/RN code gets a close review:
  write idiomatically, clarity over cleverness, **no over-engineering**.
- Every native-bridge / performance implication must be flagged explicitly, never buried in a diff.
- Actively learning backend in depth (FastAPI, DB, auth, infra) — see working style below.

## Preferred working style

- **Explain the thinking/concepts BEFORE the code** — Sơn wants to understand the flow,
  not just receive results.
- Reads **Vietnamese** faster: all discussion, reports, plans → Vietnamese.
  Everything committed to a repo → English (see [[engineering-rules]]).
- Small sequential steps → stop and report → approval → next step.

## Standards expected of agents

Three standards from Sơn's direct feedback after agents fell short (07/2026):

1. **Survey tools before committing** — a doc pre-naming a library does NOT excuse skipping your
   own survey; before locking a tool for an important step, list 2–3 modern options + trade-offs
   (the full family: heavy/light/offline/online). Propose proactively — never let Sơn be the one
   to name the right tool.
2. **Verify with cross-signals** — manually checking "ground truth" still requires checking every
   independent signal available; a value that diverges between two sources → re-examine BOTH,
   including the "human" one. Beware priming: after reading many similar cases it's easy to
   misread a different one as similar.
3. **Model the object, not just the metric** — after "good enough", still run one
   "what would a domain expert add?" pass: list the object's invariants (valid shape, position,
   size); for each failure case ask "is this a per-object RULE?" before tuning global parameters;
   upgrade a given spec from first principles instead of executing it verbatim.
