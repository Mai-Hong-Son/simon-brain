---
title: ok2ship-ai
type: project
status: active
updated: 2026-09-15
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
- **Data Mapping (WBS #5.3) was gated, then built** — the gate is what made building it safe, so
  both halves are worth keeping. The gate (2026-09): all 8 item groups of the customer's QA
  checking guide were configured against the running mockup first, and the mockup's six check types
  covered well under half of what the guide asks, so building the screen would have let users save
  configurations that could never execute. It was lifted by closing that gap rather than by
  ignoring it — each missing capability was added as an operator on an existing check type, not as
  a new one (a spec value may be text, "Judgement = Pass"; or a set, "Fail mode ∈ {2, 5}"), which
  is why the picker still has the same handful of check types.
  **Sheets are opened one at a time, and only against evidence**: a sheet is configurable when the
  checklist asks something of it that the screen can express AND the checklist's own "Hệ thống
  check?" column says to check it — 33 of the V73 report's 47 sheets. Being open means it can be
  CONFIGURED, not that the suggestion engine knows it; rules exist for the force-test and
  cross-section families only, and the rest are configured by hand.
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
- **A delivered requirements document can carry two markers that disagree — ask which one governs
  before building against either.** The BA's checklist spreadsheet has both red text and a
  "Hệ thống check?" (Có/Không) column. Reading the red matched what had been asked verbally, so
  three requirements were dropped on that basis; the column was the real marker, and only one of
  the three was actually out. Cost: an implemented change, reverted. The tell was there beforehand
  — the two markers disagreed on 2 of 3 rows, and on a neighbouring sheet the red marked a
  different pair of requirements for identical wording. **Disagreement between two signals in the
  same document is the signal**: stop and ask, rather than picking the one that confirms what you
  already believe.
- **Refresh-token reuse detection revokes EVERY session of that account, not just the one that
  tripped it** — so a script logging in as a human's account will eventually log that human out,
  from a different machine, with no visible cause. Hit twice in one day (audit log:
  `auth.refresh_token_reuse_detected`) while driving the app with Playwright as `admin`, which is
  also the account Sơn was using. The blast radius is correct — it is the right answer to a stolen
  token — so the fix is never sharing an account between automation and a person, not softening the
  rule.
- **A chart in an Excel sheet may be a native chart, not a picture — and that changes what has to
  be checked.** The V73 report's FAI/SPC family holds 300 native charts (50 per sheet across 6
  sheets) and ZERO images; the drawing-XML image reader returns nothing for them. A native chart is
  drawn from the cells, so "the chart must match the data" holds by construction — what is left to
  verify is which range the series points at, readable from the chart XML. Six sheets that looked
  like they needed image analysis need none. Check for `xl/charts/` before assuming a picture.
- **An element with an animation that applies `transform` becomes the containing block for every
  `fixed` descendant.** A dialog written as `fixed inset-0` inside a modal panel rendered 448×242 at
  (496,379) — the panel's own box — instead of covering the 1440×1000 viewport (measured
  2026-09-14). Any overlay opened over another overlay has to be its SIBLING, not its child. The
  trap is that the transform comes from a zoom-in animation nobody thinks of as layout.
- **"Reads as a number" must mean a plain decimal, never `float()` / `Number()`.** Both accept
  scientific notation, so a "7E" product code (`7E-0012`) silently becomes the threshold 7e-12, and
  both accept `nan`/`inf`. One regex, `^[+-]?(\d+(\.\d+)?|\.\d+)$`, shared by the API and the
  form, keeps a typed value's meaning identical on both sides of the wire.
