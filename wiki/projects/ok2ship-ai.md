---
title: ok2ship-ai
type: project
status: active
updated: 2026-11-03
tags: [ok2ship, product, fastapi, react]
sources: [~/Documents/products/ok2ship-ai]
read_when: project:ok2ship-ai
---

# ok2ship-ai — the OK2SHIP AI product

Backend + web dashboard of the [[ok2ship]] program — open that hub before starting an AI or data
module, to see which spike already proved the requirement. 🚀 Serious product. Stack matches
[[default-stack]]. The client's cluster, GitLab and how the BA's requirements move are in
[[mektec-desoft]], loaded with this page.

**Everything else is in the repo, `~/Documents/products/ok2ship-ai`:** topology and rules in
`CLAUDE.md`, open work in `HANDOFF.md`, every doc from `docs/index.md`, and in `docs/lessons/` what
this product taught, including the measured cases behind [[engineering-rules]].

## Decisions

The output of `scripts/compile-project.sh ok2ship-ai`, from the repo's ADRs; never composed by hand.

<!-- adr-list:start -->
- **ADR 001** (accepted): Full RBAC with `permissions`, `roles` and two junction tables, several roles per user, in industry-standard terms; rejected: a flat `role` column on `users`.
- **ADR 002** (accepted): Three independent repos in one directory: planning docs on personal GitHub, backend and frontend on mektec's GitLab, each pushed separately; rejected: one repo with the tiers as subdirectories.
- **ADR 003** (superseded): Sentry SaaS for errors only, with no raw customer data leaving the process; superseded the same day by ADR 004.
- **ADR 004** (accepted): Monitoring is the cluster's Loki, already inside the customer-data boundary; rejected: Sentry (ADR 003).
- **ADR 005** (accepted): A field hangs off the revision's sheet, with real columns for the frame and JSONB per type validated by Pydantic, editable on any Rev with every change audited; rejected: fully normalised, fields on the Template.
- **ADR 006** (accepted): A run row plus a row per field, the configuration snapshotted on the run; `pass`, `fail`, `error`, `manual` (never a pass) and `na` for an optional Spec field that reads nothing, a configuration fault staying `error`; a sheet the file lacks is not checked; rejected: a Rev id with no snapshot.
- **ADR 007** (accepted): RapidOCR on our own machines; a picture's numbers answer the cells by the numbers printed beside them, and with none printed top to bottom for one or two on a pin and in the lab's order for four on each of two pins; a partial numbering or any other shape is Manual, and a swap is a Fail; rejected: any hosted OCR or VLM.
- **ADR 008** (accepted): One library of criteria, each snapshotted when a run starts; a parameter names the sheet it applies to, NULL meaning every sheet; rejected: resolving on display.
- **ADR 009** (accepted): A report chooses its Template, and any number of Revs of a Mã tài liệu may be Active; rejected: keeping a scope and adding a manual override.
- **ADR 010** (accepted): A run covers one field, one hạng mục or the whole report, per field the newest run covering it answers, and a stopped run keeps the verdicts it reached; rejected: latest run only.
- **ADR 011** (accepted): Biểu đồ lực: chart i against force cell i, U-max is the machine's blue dot, the scale is read per chart by OCR, a printed peak is told by the curve meeting the top line; rejected: the curve's own top, a fixed scale, a chart-to-table or local vision model.
- **ADR 012** (accepted): Void X-ray: pins from the machine's frames, each label cut out and read alone by PP-OCRv6, a pass only when every reading agrees; "Đo bọt khí" holds every pin to its print within ±2 points, an unmeasurable pin Manual; rejected: whole-picture OCR.
- **ADR 013** (accepted): Biểu đồ histogram: each native chart is judged on the cells it is drawn from, a bar being outside the curve where the curve over its width is under 1 % of its peak, fixed in code; rejected: reading the picture.
- **ADR 014** (accepted): A Spec zone may hold rules instead of one criterion, the first rule whose conditions hold deciding a position, applied once or per row or column; rejected: fixed column lists per index, a fifth status for "Bỏ qua".
- **ADR 015** (accepted): The report list loads every report and the grid filters, sorts and pages in the browser; rejected: server paging with a query parameter per filter.
- **ADR 016** (accepted): A catalog node is soft-deleted with its subtree only once no live report is under it, its name locked while one is, every refusal linking the blockers; deleting a row also removes the parents it empties, up to the Project; rejected: hard delete, renaming under a report.
- **ADR 017** (accepted): A Boxplot template is its own thing, pointing at no Rev or catalog node, and an export runs outside the request; within one column and Config every pair of boxes is compared, 20.0 % as printed being Bất thường; rejected: building the file inside the request, a dedicated worker, one Average per Build over its Lots.
- **ADR 018** (accepted): Ảnh với % Black: % Black counted on each raw SEM photo at the threshold the sheet states (SEM 200 inside the pad, SEM 500 the whole photo), judged against the cell and a library limit; rejected: a mode of "Ảnh với Data".
- **ADR 019** (accepted): Ảnh rõ nét, as reinstated: variance of the Laplacian, each photo against the median of the field's others, `manual` below a share of it set on the form, never `fail`; it replaces the first design, withdrawn, whose limits were fixed in code.
- **ADR 020** (accepted): One way to create a Mẫu báo cáo, copying configuration by sheet pairs, with only Active and Inactive; rejected: keeping Draft, a server-side `needs_review` gate.
- **ADR 021** (accepted): A Spec pair may be judged "Theo tỉ lệ": per range, the share of filled cells holding a value, against a limit in percent; rejected: a new check type, one share over every range, a fixed denominator of 100.
- **ADR 022** (accepted): Read the account's status on every request and revoke its refresh tokens when it is deactivated, deleted, locked by wrong passwords or returned to Create; roles and permissions stay in the token; rejected: a shorter access token alone, Redis, a new "signed out" error code.
<!-- adr-list:end -->
