---
title: ok2ship-anomaly
type: project
status: active
updated: 2026-09-07
tags: [ok2ship, spike, anomaly-detection, ml]
sources: [~/Documents/spikes/ok2ship-anomaly/HANDOFF.md, ai-company hub memory]
---

# ok2ship-anomaly — spike for req #3

🧪 spike of [[ok2ship]]: detect anomalies in QA images by comparison against golden samples,
per-pin. **Current state: `HANDOFF.md` in the spike repo.** Not yet PROMOTED.

## Direction locked with Sơn

- **Golden/one-class** (not supervised-defect): needs few reference images, no defect dataset.
- Tooling: **Anomalib + PatchCore**, running offline (customer data stays on the machine —
  [[engineering-rules]] #3).
- Code is written so real images drop into `data/golden/` and rerun without code changes.

## Technical conclusions so far

- **Golden-set curation quality dominates everything** — one stray overview image inside golden
  degraded golden-vs-abnormal overlap by tens of points; removing that ONE file separated them.
- **Seed the randomness before drawing conclusions** — PatchCore's coreset picks a random start;
  the headline score swings >10 points between identical runs; every unseeded "gap" is one sample
  of a noisy quantity.
- **Display threshold ≠ calibrated threshold** — an eyeballed percentile is only for drawing
  contours; an automatic OK/NG gate requires calibration; a human-assist ranking tool can live
  with a loose cutoff.
- An honest test = the judged image is **absent** from both the memory bank and the val/test split.
- Detection works on both real components; localisation only on one so far — with a golden set
  below the trust threshold, results are smoke tests, not evidence.

*(The ML lessons above are promotion candidates once another ML project uses them — AGENTS.md §3.)*
