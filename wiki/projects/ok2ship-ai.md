---
title: ok2ship-ai
type: project
status: active
updated: 2026-10-04
tags: [ok2ship, product, fastapi, react]
sources: [~/Documents/products/ok2ship-ai/CLAUDE.md, HANDOFF.md, docs/PROGRESS.md, docs/decisions/001-011]
read_when: project:ok2ship-ai
---

# ok2ship-ai — the OK2SHIP AI product

Backend + web dashboard of the [[ok2ship]] program — open that hub before starting an AI or data
module, to see which spike already proved the requirement. 🚀 Serious product: tests mandatory,
branch per feature, review before merge. Stack matches [[default-stack]] (no deviation ADR). The
client's cluster, GitLab and the BA's terminology trap are in [[mektec-desoft]], loaded with this
page. **Current state + open work: `HANDOFF.md` in the repo — the wiki doesn't copy it.**

This page is loaded into every session of the product, so each entry is the rule and its one
measured case; the full story is in the ADR or the commit history of the repo it names.

## ⚠️ Three-repo topology — read before touching git

One directory but **three independent git repos** (ADR 002; rationale: backend/frontend are
client deliverables on [[mektec-desoft]]'s GitLab; planning docs are internal, on personal GitHub):
1. Root — planning/design docs (personal GitHub); gitignores `backend/` and `frontend/` entirely.
2. `backend/` — FastAPI (mektec GitLab).
3. `frontend/` — React (mektec GitLab).

Nothing auto-syncs between them; each is pushed separately, only when asked, and each tier deploys
through its own pipeline — so the two are never guaranteed to be on the same version (see
"Deploy skew" below). MR state is read with `glab mr list` (a `read_api` token is in the macOS
keyring), never from branches left on the remote ([[approval-gates]]).

## Locked decisions (detail: the repo's `docs/design/` and `docs/decisions/`)

### Users and auth

The User Management design (RBAC, account statuses, force-logout, hashing) is in the product's
`CLAUDE.md`, loaded beside this page. Three decisions it does not carry:
- No separate approver role: the uploader also reviews, and `audit_log` is the safety net.
- Refresh tokens live in an httpOnly cookie.
- Monitoring is **the cluster's Loki, not Sentry** (ADR 004): it already runs inside the
  customer-data boundary, which removes the ordinary-PII problem a hosted service would bring (passwords, tokens and
  cookies are still never logged).

### Configuration and checking

Each line is the decision; the ADR (`docs/decisions/`) holds its measurements and full reasoning.
- **ADR 005 — Data Mapping storage**: fields hang off the revision's sheet; real columns for the
  frame, JSONB per type validated by Pydantic; fields stay editable on any Rev, every change
  audited. Rejected: fully normalised (every BA change a migration); fields on the Template
  instead of the revision.
- **ADR 006 — check results**: a run row + a row per field, the field's configuration snapshotted
  on the run. `pass` / `fail` / `error` (data not there) / `manual` (not automated — never a pass).
  Rejected: a Rev id with no snapshot (fields stay editable, so it cannot say what ran).
- **ADR 007 — photo against data**: RapidOCR on our own machines only (customer images); which
  number answers which row is derived from the whole field, never configured. Rejected: any hosted
  OCR/VLM. A dedicated worker is shelved (`docs/design/report-check-worker.md`).
- **ADR 008 — Spec Management**: one library of criteria; a run snapshots each criterion at its
  start, so editing one never re-captions a finished verdict. Rejected: resolve on display.
- **ADR 009 — a Template has no scope**: a report chooses its Template; one Active Rev per Mã tài
  liệu (deactivate the old BEFORE activating the new). Accepted cost: a wrong Template runs to
  completion with wrong verdicts. Rejected: keep the scope and add a manual override (two
  mechanisms for one answer).
- **ADR 010 — a run has a scope**: one hạng mục or the whole report; per sheet, the newest run
  covering it answers. Rejected: latest run only (checking sheet B wiped sheet A).
- **ADR 011 — Biểu đồ lực** *(proposed; on an unmerged branch as of 2026-10-04)*: chart i against force cell i; U-max is the machine's blue dot, never
  the curve's top (the dot hides it); scale read per chart by OCR, never assumed; a shoulder on the
  falling slope is not a second peak (Sơn). A single-cell image anchor means "the picture starting
  here", for every image check. Rejected: the curve's own top, a fixed 0–10 N scale, a hosted
  chart-reading model (DePlot/MatCha).

## Milestones

- 2026-08-29 — User Management signed off; in production on Desoft's cluster, deployed by GitLab CI.
- Data Mapping — gated until the customer's QA checking guide could be configured against the
  mockup; lifted by adding operators to existing check types (text and set spec values), not new
  types. Every sheet is configurable by hand (open ≠ known to the suggestion engine).
- 2026-09-17 — photo-against-data check in production (V73: 480/480 numbers; a whole report is
  ~89 min of pictures at the pod's CPU limit).
- 2026-09-22..30 — Spec Management, the 2026-09-24 delivery, per-hạng-mục runs.
- 2026-10-04 — Peel test configured and checked end to end against the V69 template (on
  unmerged branches).

## Lessons

### Reading the BA's deliverables

- **The checklist decides WHAT is checked; the mockup decides only how it looks.** The mockup
  ships a whole check type, `rowLookup`, that the governing SOP checklist marks "Không" on every
  row it would answer. When the two disagree about scope the mockup is the one that is wrong, and
  the ask back to the BA is to remove the drawing.
- **Two markers in one requirements document that disagree: ask which governs before building.**
  The checklist has red text and a "Hệ thống check?" column; following the red dropped three
  requirements, of which one was really out. Disagreement between two signals in the same
  document IS the signal.
- **The mockup is live, and ahead of any copy**: `ba-ok2ship.desoft.vn/data-mapping.html` already
  drew the force-chart check while a design of our own was built from a stale copy in Downloads,
  and replaced the same day. Read the live page before designing a screen for a new requirement.
- **A re-packaged mockup reads as a new one.** A delivery that looked redesigned was the previous
  one re-hosted (1.5 MB inlined → 66 KB + external files). Diff the `id="..."` sets before reading
  a delivery as changed requirements.
- **What a tool can do is read off its real UI, not its tables or tags** ([[engineering-rules]]
  #8), and the error runs both ways. A check-type definition table produced four "this is
  impossible" verdicts that filling in the real form disproved — each would have been a change
  request for something that already ships. The BA's drawer rendered `<input>`s for Mã tài liệu /
  Rev / ECO#, all `disabled`; reading the tags relaxed an immutability rule for a day (2026-09-26). Pin a refusal with a test that SENDS the field — an
  absent Pydantic field still lets an unknown key through unnoticed.
- **Mockup fidelity** (origin of [[engineering-rules]] #8): five UI correction rounds all traced
  to reading the mockup's source instead of its render — a `width:46%` that renders
  shrink-to-fit, indigo-600 in place of the real `--ant-colorPrimary`. And its own bugs are
  matched in intent, not copied: one mockup's column minWidths sum to 1232px inside a 1158px area
  and clip its own row actions (2026-09-08).
- **One model difference wears a hundred faces** ([[engineering-rules]] #8). Ant sizes
  line-height by a single 22/14 ratio while Tailwind hard-codes one per step, so every line sat
  1–3px off; fixed once, at the token layer (`--text-*--line-height`). And when the reference
  dropped its webfont for a system stack — its CSS comment says why: the factory network may
  block the font CDN — every control of ours was a different amount too wide; one button went
  125.3px → 121.4px from a one-line change (2026-09-28).
- **A claim about a library is measured, not read off its config.** "`googleFont: 'Inter'` makes
  the grid fetch a second copy" went into a commit message; driving the page showed no request at
  all — the setting only declared a family nothing loads.

### Verification

- **Render-measure our own screens without a real account**: a second Vite port, Playwright routing
  `http://localhost:<port>/api/**` to fakes (`**/api/**` also swallows the `src/api/*.ts` modules
  and the page renders blank) and an unsigned JWT — the shared-account trap below never arises.
- **A tolerance-boundary test needs values a double holds exactly** *(promotion candidate)*:
  8.38969 − 8.36969 is 0.0199…, so a test meant to sit on 0.02 never touched it — found only
  because breaking `>` into `>=` left it green; 8.5 − 8.0 is exactly 0.5.
- **A build-time guard has to be watched PASSING** ([[engineering-rules]] #1): a Dockerfile check
  ran `python -c "import cv2"` with the system interpreter, so it failed every build and had never
  once succeeded (2026-09-17).
- **Tests arranged to AVOID a code path do not protect it** ([[engineering-rules]] #1): every
  test injected a DB session factory, so a missing `import SessionLocal` sat green through 564
  tests and failed on the first real run. The default branch is the one production takes.
- **A warning comment is not a control** ([[engineering-rules]] #1): `alembic/env.py` imports
  each module's models by hand, and a module missing from that list makes autogenerate write
  `drop_table` for its tables. Missed twice (2026-09-02, 2026-09-22), the second time with the
  warning already in the file; a test now compares the list with the directory, and a second
  test proves the first can fail.
- **Deriving a mapping from the data itself is a CHECK when the winner is unanimous and the
  runner-up is zero.** Which number on a photo answers which sheet row is scored over all of a
  field's photos: the winning order matched every photo of all seven fields, the runner-up none,
  and injected faults were still caught. Record the margin, and name what it cannot see (a swap
  repeated on every sample and both pins).
- **A status line is written when a module STARTS and nobody returns to it when the module
  ships** *(promotion candidate)*: five design docs said "planned, not built" over code weeks in
  production, and the handoff and a progress log that had stopped a month earlier said the same.
  Fix with a dated "Status as of …" note; leave the design text as the record of why.
- **Two readers of one workbook must agree on screen.** The run said "không tìm thấy ảnh" while
  the viewer beside it showed the photo: the two used different rules for which picture an anchor
  means (the run reads the declared range strictly, the viewer and previews take the nearest
  picture). Where the two can still differ, the verdict names the real reason — "spills out of the
  declared range" — never a generic "not found".

### Backend

- **A body that takes minutes to arrive is authenticated when it FINISHES arriving**
  *(promotion candidate)*: FastAPI reads a whole form/file body before resolving dependencies, so
  a 496 MB upload at 3 MB/s (158 s) outlived a 120 s token that was valid at Save, and the client
  re-sent the file. Judge the token when the request ARRIVES (request middleware) and let the dependency
  honour that verdict; raising the TTL only moves the threshold.
- **Refresh-token reuse detection revokes EVERY session of the account** — the right answer to a
  stolen token, so never share an account between automation and a person: Playwright driving
  `admin` logged Sơn out twice in one day.
- **An immutable-snapshot row is editable only while it is a draft** *(promotion candidate)*:
  editing a published Rev in place rewrites what it claims to have been, with no new row to show
  it, and bypasses checks that run only on the publish path. To change a published Rev, create a
  new one; enforced server-side. Field configuration is the deliberate exception (ADR 005).
- **"Reads as a number" means a plain decimal, never `float()` / `Number()`** — both accept
  scientific notation (a "7E" product code becomes the threshold 7e-12) and `nan`/`inf`. One
  regex, `^[+-]?(\d+(\.\d+)?|\.\d+)$`, shared by the API and the form.
- **Two distributions that install the SAME files cannot be fixed by uninstalling one**
  *(promotion candidate)*: RapidOCR requires `opencv-python` (needs libxcb, dies on a slim
  image); the headless build ships the same `cv2`, and uninstalling the desktop one left
  `import cv2` broken (2026-09-17). Exclude it at RESOLUTION time — `[tool.uv]
  override-dependencies` with a marker that is never true.

### Frontend

- **Deploy skew: a field the API may not send yet is `undefined`, not `null`, and an absent
  number is not a zero** *(promotion candidate)*. A field added together with the UI that reads
  it is missing for as long as the two deploys are apart: `run === null` let `undefined` through
  and one cell took down the whole report list (2026-09-16); an old run's missing `failed_total`
  printed "20/0 cặp lệch" (2026-09-18). Use `== null` / `?.`, never let one row take the others
  with it, and shape a response so an older frontend still shows the right thing (ADR 010's
  `summary`). To tell skew from bad data in one step, read what is actually deployed:
  `/api/openapi.json` on the dev site listed 48 paths that day against the repo's 50. A new
  **enum value** is worse: a frontend that indexes a table by `check_type` throws on one it does
  not know, so a new check type ships frontend first, and display code falls back to the raw name.
- **React crashes when something else edits the DOM** *(promotion candidate)*: a browser
  translator or an extension moves a text node, React then removes it from a parent it no longer
  has, and the ErrorBoundary takes the page — the BA hit it on every Template create
  (2026-09-16), then twice in 16 s (2026-09-22). Opt the document out of translation
  (`translate="no"` + the notranslate meta), make `removeChild`/`insertBefore` skip a node that
  is no longer a child (facebook/react#11538), and report the first suppression instead of
  swallowing it.
- **TS gotcha** *(promotion candidate)*: a root `tsconfig.json` of the `files:[] + references`
  shape makes `tsc --noEmit` a silent no-op — only `tsc -b` actually catches errors.
- **An element animated with `transform` becomes the containing block for every `fixed`
  descendant**: a `fixed inset-0` dialog inside a zoom-in modal rendered at the panel's 448×242
  instead of the 1440×1000 viewport (2026-09-14). An overlay opened over an overlay must be its
  SIBLING, not its child.
- **Reversing one direction of an optimisation creates the symmetric bug**
  *(promotion candidate)*: one request per zone re-downloaded every picture on any change; one request per
  anchor fired 80 for a single field (~8 s of pure overhead). Cache per anchor AND coalesce a
  burst into one call; before flipping a batching decision, state what the other direction costs.
- **Unmounting a wizard step throws away uncontrolled state, and a list fetched once at open is
  stale by the step that reads it** *(promotion candidate)*: "Quay lại" wiped the chosen scope,
  and a Template activated in another tab could only be picked up by re-uploading 473 MB. Hide
  the step instead of unmounting it; refetch on entering the step that consumes the list.

### Running it

- **Judge "is this still alive" where the clock is SHARED, not in the browser tab**
  (promoted to [[engineering-rules]] #1): the tab counted three minutes itself, so when a deploy
  killed a run mid-way
  (2026-09-17) every reload restarted the countdown and the rescue button stayed locked. The
  server decides `stalled`; two thresholds in two places always drift.
- **A merged fix is not an applied fix when CI does not touch that manifest.** The Postgres probe
  fix merged 2026-09-16 was still writing its FATAL line on 2026-10-01, because
  `deploy/01-postgres.yaml` is applied by hand. Seen through `mcp-grafana` against the cluster's
  Loki — the token sees every namespace; query `ok2ship` only.
- **VLM reading modes stay stored-but-not-honoured, by decision (2026-09-29).** `hybrid`/`ai`
  are valid to save and the engine answers `manual`. Before any ADR: measure whether a local
  vision model reads what OCR cannot — in 14 days of Loki `low_confidence` fired 0 times against
  125 `count_mismatch` — and Desoft must answer whether the cluster has a GPU.

### Reading reports (Excel and photos)

- **A chart in a sheet may be a native chart, not a picture**: the V73 FAI/SPC family holds 300
  native charts and zero images. A native chart is drawn from the cells, so only the range its
  series points at needs checking. Look for `xl/charts/` before assuming image analysis.
- **A picture's position does not tell you which samples it describes.** Two photos anchored over
  the same two columns printed two samples and one. Read the numbers off the pictures before
  trusting a layout, and where that cannot be done report a gap instead of guessing.
- **Group generated proposals the way the source document groups them, not the way the algorithm
  does**: keying photo fields by the shape of the pairing merged two unrelated blocks that both
  mapped 12 cells per photo; keying by the sheet's own group heading keeps them apart and names
  them the way QA reads the report.
- **Measure customer photos with the backend's own RapidOCR** (`backend/.venv`): it reads on the
  machine ([[engineering-rules]] #3) and sees what production sees. Delete extracted images once read.
