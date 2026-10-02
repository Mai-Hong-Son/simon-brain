---
title: Non-negotiable engineering rules
type: concept
status: stable
updated: 2026-10-02
tags: [engineering, rules, security]
sources: [ai-company/CLAUDE.md (constitution v1, "Non-negotiable engineering principles")]
read_when: always
---

# Non-negotiable engineering rules

Apply to **every** project, every session. This page is loaded into all of them, so it holds the
rule and one line of why; the measured case behind each rule is on the page or log entry it names.

1. **Never trust AI output without independent verification** — check against ground truth,
   cross-checks, system metadata. This is rule #1; everything else ranks below it.
   **A check counts only once it has been seen to FAIL and to PASS.** A test that has never gone
   red, a build guard that has never gone green, a monitor that has never fired — none of them is
   evidence yet. Fixing a bug: revert the fix, watch the test fail, restore it. Adding a guard:
   watch it pass on a good build. A warning comment is not a control — the second time one is
   missed, replace it with a test. (Cases: [[ok2ship-ai]] — a guard that failed every build, a
   green suite around the one path production takes; [[vn30f-bot]] — safety rules broken on
   purpose to find the test that catches each, a gap detector reporting zero while unable to fire.)
   **The claims you check least are the ones that support what you are proposing — check those
   first.** An anecdote that makes your own case arrives already believed. (Case: `wiki/log.md`,
   2026-10-01 — the "2 of 16" correction.)
   **A monitor must tell silence from health** — measure the thing (messages arriving, a clock on
   the server), never the component's word or the viewer's own count. (Cases:
   [[vn30f-bot-architecture]], [[ok2ship-ai]].)
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
8. **UI built against a reference: verify the RENDER, not the source** — render it with
   Playwright and extract real computed values (`getComputedStyle`, `getBoundingClientRect`);
   never approximate with framework defaults. Each line below was paid for in [[ok2ship-ai]],
   which keeps the measurements.
   - **Measuring shows where you differ; it does not tell you to copy.** A mockup is a prototype
     and carries its own bugs — match its intent, not its defects, and say in the code which is
     which.
   - **A control's presence is not its state — read the attribute, not the tag.** What a screen
     *offers* is a computed property (`el.disabled`, `readonly`, `aria-disabled`,
     `pointer-events`, the computed cursor, a handler that returns early). Inferring it from the
     markup errs in the dangerous direction: it invents a capability the reference does not
     have, and the product loosens a rule to match.
   - **Many small, similar mismatches are one MODEL difference.** Fixing instances never
     converges, because each is off by a different amount; find the rule that generates them. It
     often lives in the reference's shared stylesheet — diff its tokens between deliveries, and
     read its comments for the why that pixels cannot give.
   - **Rendering does not reveal what a LIBRARY's config declares or fetches.** Drive the page and
     watch the network before writing a claim about third-party behaviour down: a library's docs
     and its behaviour in your build are two different sources.
