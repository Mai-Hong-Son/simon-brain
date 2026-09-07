---
title: Default stack
type: concept
status: stable
updated: 2026-09-07
tags: [stack, backend, frontend, mobile]
sources: [ai-company/CLAUDE.md (standard tech stack), ~/Documents/products/native-skline-chart/docs/decisions/001-jest-over-vitest.md]
---

# Default stack

Stack choice for new projects: the table below is the default. **Deviating → an ADR in the
product repo BEFORE any code** (AGENTS.md §3). Project init always ASKS Sơn — never auto-pick;
procedure lives in the `project-init` skill.

| Tier | Default | Notes |
|---|---|---|
| Backend | Python 3.11+ / FastAPI / Pydantic v2 | NestJS only for pure-TS projects with no AI/data. Pydantic models for everything crossing a boundary |
| Web | React 18 + Vite + Tailwind | **No router/state library until genuinely needed** — useState/useReducer first |
| Mobile | React Native + TypeScript | Test runner is **Jest**, not vitest (RN preset, ecosystem — ADR 001 of [[native-skline-chart]]) |
| Tests | pytest (BE) / vitest (web) | Every feature ships with tests on serious projects |
| Packaging / CI | Docker + docker-compose (local) + CI lint+test per PR | No secrets in images/CI |

## Repo layout

- Single tier (backend-only OR frontend-only) → flat at the repo root.
- ≥2 tiers (full-stack) → one subdirectory per tier: `backend/`, `frontend/`.

## Gotchas paid for

- **Password hashing: `pwdlib[argon2]`, NOT passlib** — passlib is stuck on a bcrypt 4.x bug.
- Token hashing deliberately differs from password hashing: argon2id for passwords
  (intentionally slow), SHA-256 for tokens (fast, frequent lookups) — see [[ok2ship-ai]].
