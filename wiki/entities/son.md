---
title: Sơn
type: entity
status: stable
updated: 2026-10-09
tags: [user, preferences, standards]
sources: [ai-company/.claude/agents (dev-frontend, dev-mobile), feedback memory 07-08/2026]
read_when: always
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
  Everything committed to a repo → English (operative rule: `config/global-rules.md`, loaded into every session).
- Small sequential steps → stop and report → approval → next step.
- **He tests on the machine's own dev server, which reads the working tree — so switching branch
  changes what he is looking at, without telling him** (2026-09-28: a whole test round of his
  spent on a branch that did not carry the change). Say which branch `localhost` is on every time
  it changes, merge what he needs to see into one branch and check it out for him, and leave the
  tree on `main` when the work is done. Work that needs another branch goes in a `git worktree`
  outside the tree he tests on, so his dev server never reloads under him.
- **One merge request per repo for a batch of work**, not a chain that has to be merged in order
  — every extra MR is manual work for him. Split by commit inside the MR; if branches must build
  on each other, rebase them into a linear chain yourself rather than handing him the conflicts.
- **Pull every repo of the product before each piece of work, and tell him what changed** —
  other developers push to `main` (Hiệp on [[ok2ship-ai]] since 2026-10-09); run the migrations
  that arrived on the local DB. Sơn: "mỗi lần làm mình sẽ pull code mới nhất về, xong report xem
  code mới nhất update phần gì cho anh biết, để tránh conflict".

## Standards expected of agents

From Sơn's direct feedback after agents fell short:

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
4. **Build what was asked, and add nothing** — when the work has a reference (a mockup, a
   checklist), what the reference does not contain is a decision, not an oversight: no extra
   control, banner, counter or screen, however useful it seems. If something looks missing, build
   the server side, leave the control out, and ask the question the absence raises. A step inside
   an approved plan is not thereby a requirement someone raised — check each one against the
   reference before building it. (2026-09, [[ok2ship-ai]]: seven additions taken back out of two
   screens after the plan itself had said not to build them, and a viewer screen written and
   closed unmerged.)
