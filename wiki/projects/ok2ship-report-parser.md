---
title: ok2ship-report-parser
type: project
status: active
updated: 2026-09-07
tags: [ok2ship, spike, excel, parsing]
sources: [~/Documents/ok2ship-report-parser/HANDOFF.md, ai-company hub memory]
---

# ok2ship-report-parser — spike for reqs #1/#2/#4/#5

🧪 spike of [[ok2ship]]: reliably read structured data (numbers, row labels, spec thresholds) out
of real factory QA Excel reports — the foundation for OCR-vs-cell (#1), spec checks (#2),
cross-report deviation (#4), boxplots (#5). **Current state: `HANDOFF.md` in the spike repo.**
Not yet PROMOTED.

## Decisions locked with Sơn

- Fully separate from [[ok2ship-anomaly]] — different substance (numbers vs images), never merge scope.
- **Parse by row LABEL, never by hardcoded cell coordinates** (see findings below).
- **Never silently drop a sheet** — sheets without a parser pass through raw;
  Sơn decides what gets dropped, not the tool.
- Output ordered by real workbook tab order; `snake_case` keys; a sheet's output contains only
  what that sheet itself holds (no cross-sheet checks, no verdicts — the check layer is a later
  step, not part of a reader).

## Findings about the real report format (the reasons behind the rules above)

- **Merged cells wrap only LABELS, never values** — inferring value positions from merges is wrong.
- **Structure drifts between reports**: sheet count is not fixed (some models carry a parallel
  "Shell B2B..." set), pin count changes per report — nothing can be hardcoded.
- **Header label cells can be corrupted** (overwritten with a value instead of text, likely manual
  edits) → the parser needs a self-check step; never trust input blindly.
- **Streaming reads** (`openpyxl read_only=True`) skip embedded images → files of hundreds of MB
  open in a blink; images live in a separate zip layer, extracted via the drawing XML and mapped
  by anchor.

*(This Excel-parsing lesson set is a promotion candidate once [[ok2ship-ai]]'s data modules
use it for real — AGENTS.md §3.)*
