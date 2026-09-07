---
title: OK2SHIP
type: hub
status: active
updated: 2026-09-07
tags: [ok2ship, program, qa]
sources: [~/Documents/ok2ship-ai/CLAUDE.md, ai-company hub memory 08/2026]
---

# OK2SHIP — program hub

An AI QA-report checking system for [[mektec-desoft]] (Mektec Vietnam, vendor Desoft): checks QA
report data/images against spec, golden samples and cross-report history before a shipment is
approved. This is the overview page — details live on child pages.

## The BA's 5 original requirements ("Ok2ship AI check" file, 08/2026)

| Req | What | Feasibility proven by |
|---|---|---|
| #1 | Compare OCR against report cell values | [[ok2ship-report-parser]] |
| #2 | Spec/statistics checks | [[ok2ship-report-parser]] |
| #3 | Compare images against golden samples, per-pin anomaly | [[ok2ship-anomaly]] |
| #4 | Cross-report deviation | [[ok2ship-report-parser]] |
| #5 | Boxplot comparison | [[ok2ship-report-parser]] |

## The pieces

- [[ok2ship-ai]] — the real 🚀 product, built module by module along Desoft's WBS.
  Module 1 (User Management) done; future AI/data modules **reuse the spikes' findings,
  never re-derive them**.
- [[ok2ship-anomaly]] — 🧪 spike for req #3 (image vs golden, one-class AI).
- [[ok2ship-report-parser]] — 🧪 spike for reqs #1/#2/#4/#5 (reading real factory Excel reports).
  Deliberately separate from anomaly: entirely different substance (tables of numbers vs images).
- [[void-guard-xval]] — 🧪 spike for the "X-ray Solder Void" strand: measuring void% from AXI
  X-ray images, scored by matching the machine's numbers. Sơn is actively working on it.
