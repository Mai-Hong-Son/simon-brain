---
title: ai-company (historical)
type: entity
status: stable
updated: 2026-09-07
tags: [history, architecture, meta]
sources: [ai-company/CLAUDE.md, ai-company/.claude/]
---

# ai-company — absorbed model (07/2026 – 09/2026)

The operating model before [[simon-platform]]. **Absorbed into simon-brain 09/2026** — this page
stays because the reasons a model was once chosen and then dropped are exactly the kind of
knowledge the wiki exists to keep.

## What it was

A central repo (`ai-company`, bootstrapped 2026-07-13) playing "company":
- **A constitution** (hub CLAUDE.md): engineering rules, task-size Group/Flow workflow, a debate
  mechanism, the 🚀 Serious vs 🧪 Spike ritual, the English-repo/Vietnamese-to-human language rule.
- **6 native agents** as a staff: orchestrator, dev-backend, dev-frontend, dev-mobile, devops, qa-reviewer.
- **3 skills**: git-workflow, project-init, project-retro.
- `products/` (gitignored) holding independent product repos.

## Why it was dropped

1. **The coordination machinery outweighed what it coordinated** — a 3.6KB orchestrator directing
   four dev agents totalling 2.3KB; each "agent" was a few bullet points about a stack, not worth
   a separate context.
2. **Subagents exist for context isolation, not role-play** — a model doesn't need to be told
   "you are the Backend Engineer" to write decent FastAPI.
3. Several rules existed only to patch problems the agent-splitting itself created
   (e.g. "two agents must never edit the same file").
4. Once the foundation layer (wiki + skills + rules) existed, the "company" frame became a
   redundant middle layer — every role had a better home.

## What was kept, and where it went

| Asset | New home |
|---|---|
| Engineering rules (9 principles) | [[engineering-rules]] |
| Standard stack + ADR discipline | [[default-stack]], AGENTS.md §3 |
| Approval gates + debate | [[approval-gates]] |
| Spike ritual | `~/exp/` (AGENTS.md §0 — experiment zone) |
| Skills git-workflow / project-retro / project-init | `simon-brain/skills/` (rewritten generic) |
| 6 native agents | Dropped — solo-agent model |
| The ai-company repo | Archived, git history intact |

Products that lived under `products/`: [[ok2ship-ai]], [[native-skline-chart]], the
[[ok2ship]] spikes — moved out to `~/Documents/` at archive time.
