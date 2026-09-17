---
title: ok2ship-ai
type: project
status: active
updated: 2026-09-17
tags: [ok2ship, product, fastapi, react]
sources: [~/Documents/products/ok2ship-ai/CLAUDE.md, HANDOFF.md, docs/PROGRESS.md, docs/decisions/001-007]
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
  **Every sheet of the report is now configurable.** Opening them was staged — first the two Peel
  test sheets, then those the checklist's own "Hệ thống check?" column marks, then all of them —
  because each stage needed evidence that the screen could express what the checklist asks. Being
  open means a sheet can be CONFIGURED, not that the suggestion engine knows it; rules exist for
  the force-test and cross-section families only, and the rest are configured by hand.
- **Checking a photo against the data beside it runs in production (WBS #5.4 part B, ADR 007,
  2026-09-17).** A cross-section photo carries its measurements printed on it; the cells beside it
  hold the same numbers typed by the lab, and the check is whether they agree. RapidOCR, entirely
  on our own machines — customer images may never reach a hosted service. Measured end to end on
  the real V73 report: **4 of 4 image fields pass, 480 numbers, zero mismatches.** Two pieces are
  deliberately shelved with their reasons written down: a screen for looking at the photo behind a
  verdict, and a worker of its own (`docs/design/report-check-worker.md` — measured: 2,665 pictures
  in the whole report, ~89 minutes at the pod's CPU limit, and memory is *not* the constraint).
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
- **Ant sizes line-height by one ratio, Tailwind hard-codes one per step — so rebuilding an Ant
  mockup in Tailwind puts EVERY line of text 1-3px off** while family, size and colour all match.
  Ant applies a single 22/14 multiplier at every size (11px → 17.29, 13px → 20.43, 20px → 31.43);
  Tailwind's `text-sm` carries a fixed 20px, `text-xl` a fixed 28px. Nothing looks wrong enough to
  name, which is why it came back as "nhiều chỗ font chưa chuẩn" with no specific example, and
  chasing it element by element never converges because each step is off by a different amount.
  The fix belongs at the token layer — override `--text-*--line-height` to the one ratio (127 uses
  corrected at once, explicit `leading-*` still wins) and set font-size + line-height on `body` so
  anything that declares no size stops falling back to the browser's 16px/`normal`. See
  [[engineering-rules]] #8 on measuring for the model difference rather than the values.
- **A body that takes minutes to arrive is authenticated when it FINISHES arriving, not when it
  starts** *(promotion candidate once a second project hits it)*: FastAPI reads a whole form/file
  body before it resolves dependencies, so `Depends(get_current_user)` runs against the clock at
  the END of the upload. With a deliberately short access token, every upload slower than the TTL
  fails with a token that was valid when the user pressed Save — and a client that retries then
  sends the entire file a second time (measured: 496 MB at 3 MB/s = 158 s against a 120 s TTL; the
  same file at full speed passes). The fix is to judge the token when the request ARRIVES — the
  request-context middleware already decodes it there for logging — and let the dependency honour
  that verdict for the same token string. Nothing is relaxed: a token dead or forged on arrival is
  still rejected, and force-logout keeps its bound because no NEW request opens with a dead token.
  Raising the TTL only moves the threshold; it does not remove it.
- **Reversing one direction of an optimisation creates the symmetric bug** *(promotion candidate
  once a second project hits it)*: a preview that fetched a whole zone in one request re-downloaded
  every picture whenever one anchor changed, so it was changed to one request per anchor — which
  made opening a field of 80 anchors fire 80 requests, ~8 s of pure per-request overhead against a
  server that has the file open and cached either way. Neither shape is right alone. The answer
  keeps both: cache per anchor, and coalesce whatever is requested in one burst into a single call.
  Before flipping a batching decision, state what the OTHER direction then costs.
- **A picture's position in a spreadsheet does not tell you which samples it describes.** On the
  V73 cross-section sheets, `D53:E53` and `D43:E43` are anchored over the same two columns, yet the
  first prints the numbers of two samples and the second only of one — the second sample's photo
  is the one on the row below, anchored over the same pair. Pairing by geometry alone mis-assigns
  every photo of such a row to its neighbour's data. Read the numbers off the pictures before
  trusting a layout, and when a layout cannot be read that way, report a gap instead of guessing:
  a configuration saved on a wrong pairing is worse than one a human has to type.
- **OCR on a Mac needs no install**: Apple's Vision framework via a ~20-line `swiftc` program reads
  text off an image entirely on the machine. That satisfies [[engineering-rules]] #3 for customer
  images (nothing leaves the approved environment) without a PaddleOCR/Tesseract install, and it is
  the practical way to check what a report's own photos actually print. Delete the extracted images
  as soon as they have been read.
- **Group generated proposals the way the source document groups things, not the way the algorithm
  does.** Cross-section photo fields keyed purely by the shape of the pairing merged two unrelated
  groups — the sheet's "Vertical" blocks and its "female and male" ones — into one field, because
  both happened to map 12 cells per photo. Keying by the sheet's own group heading (column B of a
  Barcode row) both names each proposal the way QA reads the report and keeps unrelated blocks
  apart. Shape still subdivides a group, since one group can hold two kinds of photo.
- **"Reads as a number" must mean a plain decimal, never `float()` / `Number()`.** Both accept
  scientific notation, so a "7E" product code (`7E-0012`) silently becomes the threshold 7e-12, and
  both accept `nan`/`inf`. One regex, `^[+-]?(\d+(\.\d+)?|\.\d+)$`, shared by the API and the
  form, keeps a typed value's meaning identical on both sides of the wire.
- **Two distributions that install the SAME files cannot be sorted out by uninstalling one
  afterwards** *(promotion candidate once another Python project hits it)*: RapidOCR requires
  `opencv-python`, the desktop build, which needs libxcb and dies on a slim image; the headless
  build ships the same `cv2`. The Dockerfile installed both and removed the desktop one — and
  measured 2026-09-17, `uv pip uninstall opencv-python` left `import cv2` broken with headless
  still "installed", because whichever landed second owns the shared files. The fix belongs at
  RESOLUTION time (`[tool.uv] override-dependencies` with a marker that is never true), so the
  wrong one is never written at all and there is nothing to undo.
  **The same commit carried the second half of the lesson: a build-time guard has to be watched
  PASSING, not merely written.** Its check, `RUN uv pip uninstall … && python -c "import cv2"`,
  used the bare `python` — the system interpreter, which has no cv2 whatever the venv holds — so it
  failed *every* build and had never once succeeded. Written as "fail at build rather than in
  production", it blocked precisely what it was meant to protect, and nobody noticed because it
  landed in the same commit as the dependency it guarded.
- **Tests arranged to AVOID a code path do not protect it** *(promotion candidate once a second
  project hits it)*: a background task opens its own DB session, so every test injected a session
  factory — deliberately, so a test could never write into the dev database. A missing
  `import SessionLocal` therefore sat green through 564 tests and failed on the first real run:
  the default branch, the only one production takes, was the one arrangement no test exercised.
  The fixture that makes a test safe can be the thing that makes it blind. Pinned by pointing the
  module's own `SessionLocal` at the test database and taking the default branch on purpose.
- **Judge "is this still alive" where the clock is SHARED, not in the browser tab** *(promotion
  candidate once a second project hits it)*: a check moved to a background task, and the screen
  decided a run had stopped by counting three minutes itself. Measured on dev 2026-09-17 — a deploy
  replaced the pod mid-run, the row still said `running`, and the button that would have rescued it
  was disabled *because* the run still looked live; every reload restarted the countdown, so the
  more the user tried, the further away the rescue got. Moving the verdict to the server made
  "the screen says it stopped" and "the API will let me start another" the same question. Two
  thresholds in two places always drift, and the user is the one told to press a button that then
  refuses.
- **Deriving a mapping from the data itself is a CHECK, not a circular argument — when the winner
  is unanimous and the runner-up is zero.** Which number on a photo answers which spreadsheet row
  cannot be read off the picture: the arrows are drawn where the feature physically sits, so one
  block's sheet order was 3-2-1-4 down the image. Rather than adding a config field nobody would
  know how to fill in, the engine scores every possible order against ALL the field's photos and
  adopts one only if it wins outright. Measured on the real report: the winner matched **every**
  photo of **every** one of seven fields, the runner-up matched **none**; injected faults were
  still caught (one wrong digit; two rows swapped on one sample; two rows swapped on every sample
  of one pin). What it cannot see is a swap repeated identically on every sample AND both pins —
  indistinguishable from the block simply being laid out that way — so the derived order is logged
  on every run and shown on screen when it is unusual. **A derivation earns the word "check" from
  the margin it wins by; record the margin, and name what it still cannot see.**

