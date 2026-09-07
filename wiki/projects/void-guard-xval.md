---
title: void-guard-xval
type: project
status: active
updated: 2026-09-07
tags: [ok2ship, spike, cv, x-ray]
sources: [~/Documents/void-guard-xval/HANDOFF.md, docs/rui-ro-so-lieu.md]
---

# void-guard-xval — X-ray void% measurement spike

🧪 spike of [[ok2ship]], the "X-ray Solder Void" strand: image processing on AXI X-ray images to
measure void% (air pockets in solder joints) accurately. **Sơn is actively working on it —
current state: `HANDOFF.md` in the spike repo.** Not yet PROMOTED.

## Locked objective (redefined by Sơn, 07/2026)

The focus is **image processing for accurate output** — detecting (1) each pin's frame = the
denominator, (2) void area = the numerator. The % formula is trivial and not the thing under test.
The machine-printed numbers are **ground truth for scoring** ([[engineering-rules]] #1), not a
separate goal.

## Decisions & technical conclusions

- **Denominator = the machine-drawn ROI frame area**, not the real solder pad (locked in the
  2026-07-15 meeting) — machine and measurement share the denominator, so it matches by
  construction; a consistent one-sided bias implicates the void threshold, not the denominator.
- **Measure by following the machine-drawn cyan outlines** (approach B), not independent
  density-based measurement — production images always carry annotations, and void cores have
  too little contrast. Known trade-off: only works on annotated images; raw images would need
  the density-segmentation approach.
- Fill **per contour, never flood-fill the whole image** (flood fill inverts at corner frames →
  the 100%-measurement bug); correct for outline thickness via perimeter.
- **OCR ground truth**: RapidOCR offline + a human reviewing a montage and fixing by hand;
  OCR the whole image in one pass (small crops blind the detector); parse a strict format.
- **Hybrid scoring criterion**: absolute error for small values, relative error for large ones —
  upgraded from the "<1 point" spec on metrology principles.
- Evaluation result (10-image / 160-joint set, 07/2026): MAE ~0.25 points, no bias — well past target.
- **Never graft per-object rules from a pipeline with a different context** — tried, failed badly;
  to use another pipeline's rules, bring its whole context along.

## Backend learning track

The spike doubles as Sơn's backend course: the demo API grew into a backend covering all four
production-readiness groups (foundation/DB Postgres+Alembic · hardened API · security
rate-limit/refresh-token/CORS · operations logging/health/Docker/CI). The pwdlib-not-passlib
gotcha went to [[default-stack]]. Sơn is re-walking each part sequentially to fully understand it.

*(Three feedback lessons from this spike were distilled into shared working standards in [[son]].)*
