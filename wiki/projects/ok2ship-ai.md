---
title: ok2ship-ai
type: project
status: active
updated: 2026-09-11
tags: [ok2ship, product, fastapi, react]
sources: [~/Documents/products/ok2ship-ai/CLAUDE.md, HANDOFF.md, docs/PROGRESS.md, docs/decisions/001-004]
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
- **Data Mapping (WBS #5.3) is surveyed but deliberately not built.** All 8 item groups of the
  customer's QA checking guide were configured against the running mockup: its six check types
  cover well under half of what the guide asks for, leaving ~15 missing check types and ~14
  questions only the BA can answer. Building the screen first would let users save configurations
  that can never execute. Full per-group findings live in the product repo's `docs/design/`;
  the wiki keeps only this gate.
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
- **An immutable-snapshot row is only editable while it is still a draft** *(promotion candidate
  once a second project hits it)*: a Template revision owns its scope and description, and the
  version-history table shows one row per Rev with that row's current values. Editing a published
  Rev in place therefore rewrites what it claims to have been, with no new row to show it happened
  — and it bypasses checks that only run on the publish path (here, the one-Active-per-node rule
  lives solely in `_set_revision_status`, so re-targeting an already-Active Rev never triggers it).
  A draft has neither problem: nothing published, nothing active, nothing to conflict with. To
  change a published Rev, create a new one. Enforced server-side, not just by hiding the control.
- **A tool's capabilities must be probed by driving its real UI, not read from its config tables**
  *(promotion candidate once a second project hits it)*: reading a mockup's check-type definition
  table produced four separate "this is impossible" verdicts, and filling in the real form
  disproved every one — the definitions constrain the default rendering, not what the form
  accepts. Distinct from [[engineering-rules]] #8, which is about visual fidelity: this one is
  about capability. The cost of getting it wrong is asymmetric — a false "impossible" becomes a
  change request to the vendor for something that already ships.
- **A re-packaged mockup reads as a new one.** The BA's 2026-09-07 delivery looked redesigned but
  was the 2026-09-02 mockup re-hosted (1.5 MB inlined → 66 KB + external CSS/JS). Comparing the
  `id="..."` sets settles it in seconds — Template Management differed by 2 ids, both template
  literals moved into the extracted JS, while Data Mapping differed by 45. Do this before
  re-reading a delivery as changed requirements.
