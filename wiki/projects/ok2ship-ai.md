---
title: ok2ship-ai
type: project
status: active
updated: 2026-09-07
tags: [ok2ship, product, fastapi, react]
sources: [~/Documents/ok2ship-ai/CLAUDE.md, HANDOFF.md, docs/PROGRESS.md, docs/decisions/001-004]
---

# ok2ship-ai — the OK2SHIP AI product

Backend + web dashboard of the [[ok2ship]] program. 🚀 Serious product: tests mandatory, branch
per feature, review before merge. Stack matches the [[default-stack]] defaults (no deviation ADR).
**Current state + open work: read `HANDOFF.md` in the repo — the wiki doesn't copy it.**

## ⚠️ Three-repo topology — read before touching git

One directory but **three independent git repos** (ADR 002; rationale: backend/frontend are
client deliverables on [[mektec-desoft]]'s GitLab; planning docs are internal, on personal GitHub):
1. Root — planning/design docs (personal GitHub); gitignores `backend/` and `frontend/` entirely.
2. `backend/` — FastAPI (mektec GitLab).
3. `frontend/` — React (mektec GitLab).

Nothing auto-syncs between them; each is pushed separately, only when asked.

## Locked decisions (summary — full detail in the repo's `docs/design/user-management.md`)

- **Full RBAC**, one user holds multiple roles; naming follows industry standard, NOT the BA's
  wording (terminology trap — see [[mektec-desoft]]). Went through 3 design rounds (v1→v3)
  because the BA changed requirements.
- No separate approver role (uploader also reviews) — `audit_log` is the main safety net.
- Report visibility is role-based, not Line-scoped; if Line returns, model it as more roles
  (cheap) rather than building a scope table early.
- 4 account statuses (Create→Active→Locked→Inactive), **never hard delete** (audit trail).
- Near-instant force-logout is an SRS requirement → short-lived access tokens or a Redis check;
  never default to long-lived JWTs.
- argon2id for passwords, SHA-256 for tokens (deliberately different); refresh tokens in an
  httpOnly cookie.
- Monitoring: **the cluster's Loki, not Sentry** (ADR 004 superseding 003 the same day — the
  cluster already runs Loki+Grafana inside the customer-data boundary, which changed the whole
  PII problem).

## Milestones & lessons

- Module 1 (User Management, WBS #5) **signed off 2026-08-29**, running in production on Desoft
  infrastructure, auto-deployed via GitLab CI/CD.
- **The mockup-fidelity lesson** (origin of [[engineering-rules]] #8): 5 consecutive UI correction
  rounds all traced to reading the mockup's source instead of rendering + measuring — a long-line
  filter silently ate the logo, CSS declared `width:46%` but the real render shrink-to-fit due to
  a duplicated wrapper div, colors approximated with indigo-600 instead of reading the real
  `--ant-colorPrimary`.
- **TS gotcha** *(promotion candidate once another TS project hits it)*: a root `tsconfig.json`
  of the `files:[] + references` shape makes `tsc --noEmit` a silent no-op — only `tsc -b`
  actually catches errors.
- Email belongs off the request path (BackgroundTasks) — synchronous SMTP once added whole
  seconds to every user create/edit.
