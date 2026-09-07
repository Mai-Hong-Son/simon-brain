---
title: Simon Platform
type: entity
status: active
updated: 2026-09-07
tags: [platform, architecture, meta]
sources: [simon-brain-migration-brief.md (2026-09-07)]
---

# Simon Platform — the foundation model

The operating model in force since 09/2026, replacing the [[ai-company]] model.

## Architecture

```
SIMON-BRAIN = FOUNDATION (this repo — under every session, every machine, git-synced)
├── wiki/      distilled memory & knowledge
├── agents/    capability pool (not a "team"; solo agent by default)
├── skills/    packaged procedures (symlinked into ~/.claude/skills via setup.sh)
├── AGENTS.md  wiki operating rules
└── setup.sh   rebuilds the foundation on a new machine

PRODUCT REPOS (ok2ship-ai, native-skline-chart, ...)
└── stand on the foundation; hold only their own code + technical config

~/exp/ = experiment zone — does NOT write to the wiki by default; dead experiments get deleted
```

## The single-source-of-truth test

| Kind of information | Its one home |
|---|---|
| Agent behavior rules + pointer to the wiki | `~/.claude/CLAUDE.md` (kept thin) |
| Decisions + rationale, lessons, cross-project synthesis | `wiki/` |
| Current code state, build/test commands, technical conventions | the product repo |
| Work-in-progress narrative | the session (evaporates) / the repo's HANDOFF.md |

Anti-drift: the wiki records **shape**, never instantaneous values (AGENTS.md §2).
Wiki↔repo contradiction: repo wins on current state, wiki wins on decision history.

## Agent principle

Default is a **solo agent** — one context does the whole job. Spawn a subagent only for genuine
**context isolation** (adversarial review needs eyes that haven't seen the code — see
[[approval-gates]]), never for role-play.
