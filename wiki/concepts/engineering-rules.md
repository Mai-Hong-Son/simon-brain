---
title: Non-negotiable engineering rules
type: concept
status: stable
updated: 2026-09-07
tags: [engineering, rules, security]
sources: [ai-company/CLAUDE.md (constitution v1, "Non-negotiable engineering principles")]
---

# Non-negotiable engineering rules

Apply to **every** project, every session. Distilled from the ai-company constitution
(see [[ai-company]]).

1. **Never trust AI output without independent verification** — check against ground truth,
   cross-checks, system metadata. This is rule #1; everything else ranks below it.
2. **Secrets via env vars** — never hardcoded, never in images/CI files; `.env` is never committed.
3. **Customer data never leaves approved environments** — and never touches a free-tier AI service.
4. **Float comparisons use a tolerance, never `==`** — every comparison site carries a one-line
   comment naming the concrete source of imprecision (accumulated sums, float32 vs float64,
   coordinate round-trips, unit conversion) and why that epsilon. A tolerance without a stated
   reason is an unreviewable magic number.
5. **Every production LLM/VLM call**: temperature 0 (unless an ADR says otherwise), strip markdown
   fences before parsing, validate the schema with Pydantic/Zod.
6. **Significant architecture decisions → write an ADR** in the product repo (`docs/decisions/`) —
   context, decision, rationale, consequences. The wiki keeps only the summary + rationale +
   rejected alternatives (AGENTS.md §3).
7. **Uncertainty rule**: when logic is unclear — especially external integrations (auth, payments,
   third-party SDKs, webhooks, native modules, LLM prompt behavior) — STOP and ask Sơn before
   changing it. Never silently rewrite code you don't fully understand.
8. **UI built against a mockup: verify the RENDER, don't just read the source** — render it with
   Playwright and extract real computed values (`getComputedStyle`, `getBoundingClientRect`);
   never approximate with framework defaults. A lesson paid for with 5 correction rounds —
   full story at [[ok2ship-ai]].

Language: **everything committed to a repo is English** (code, comments, commit messages,
technical docs); **everything addressed to Sơn is Vietnamese**. See [[son]].
