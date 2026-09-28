---
title: Non-negotiable engineering rules
type: concept
status: stable
updated: 2026-09-28
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
   full story at [[ok2ship-ai]]. **Measuring tells you where you differ; it does not tell you to
   copy.** A mockup is a prototype and carries its own bugs — match its intent, not its defects,
   and say in the code which is which. (Measured 2026-09-08: a mockup whose column minWidths sum
   to 1232px inside a 1158px area clips its own last two row actions; another whose name cell
   wraps uncapped overflows its own row. Both were matched in ratio, not in defect.)
   **A control's presence is not its state — read the attribute, not the tag.** A mockup's edit
   form rendered real `<input>` elements for three identifier fields, and all three carried
   `disabled`; reading "there are inputs here" produced the finding that the reference screen
   edits them, and on the strength of that finding an immutability rule was relaxed in the
   product (measured 2026-09-26; caught by Sơn on the render and reverted the same day). The same
   trap sits on `readonly`, `aria-disabled`, `pointer-events:none`, a click handler that returns
   early, and a control hidden behind a permission. What a screen *offers* is a computed property
   of the element, so extract it (`el.disabled`, `getComputedStyle(el).cursor`) exactly as you
   would a colour — never infer it from the markup shape. Dangerous specifically because it
   points the wrong way: it invents a capability the reference does not have, and the product
   then loosens a rule to match something nobody asked for.
   **Measure to find where the two systems differ in MODEL, not only in value.** Many small
   identical-looking mismatches are one model difference wearing a hundred faces — fixing them one
   by one never converges, because each instance is off by a different amount. When several
   elements are all slightly wrong in the same way, stop measuring instances and go find the rule
   that generates them.
   **That model difference often lives in the reference's SHARED STYLESHEET, not in the screen —
   so diff its tokens between deliveries, and read its comments for the WHY measurement cannot
   give.** Measured 2026-09-28: the reference dropped its Google Fonts import and pointed both its
   UI and its "mono" variable at one system stack, so every control in our build was a little wide,
   each by a different amount, with family, size and colour all apparently matching. One button
   went 125.3px → 121.4px — their exact number — from a one-line change and nothing else. The
   reason was in their CSS comment and nowhere in the pixels: the factory's internal network may
   block the font CDN, and a webfont that loads on one machine and falls back on the next makes one
   product look like two. A re-delivery can move the design system under every screen at once;
   comparing only the page you are working on will never show it.
   **Rendering the page does not reveal what a LIBRARY's own config declares or fetches.** The same
   build also asked a grid component for `fontFamily: {googleFont: 'Inter'}`. Writing up the fix,
   the claim "so it fetches a second copy from the CDN" was read off the config and shipped in a
   commit message — the exact mistake this rule exists to prevent, made while fixing this rule.
   Putting the setting back and driving the page showed no request and no injected `<link>`: that
   library needs an explicit opt-in to load one. What it really did was DECLARE a family nothing
   loads any more, so the grid alone would render in the browser's fallback. Measure the claim you
   are about to write down, including the ones about third-party behaviour — a library's docs and
   its behaviour in your build are two different sources.


