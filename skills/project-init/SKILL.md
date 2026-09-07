---
name: project-init
description: Initialize a new project on the simon-platform foundation. Asks serious vs spike, asks for the stack (defaults from the wiki's default-stack), deviation → ADR, scaffolds the repo + creates the project's wiki page. Use when the user starts a new product/project, says "tạo dự án mới", "new project", "khởi tạo", "spike", "thử khả thi".
---

# Project init — the new-project ritual

Never choose for Sơn — every ASK step is mandatory. Foundation model: `wiki/entities/simon-platform`.

## Step 0 — ASK: serious or spike?

- **🚀 Serious (default)** — a real project, full rules apply.
- **🧪 Spike** — feasibility probe. Lives in `~/Documents/spikes/<name>`.
  Relaxed: tests optional, commit straight, stack deviation needs no ADR, **no wiki page**
  (AGENTS.md §0 — spike zone). NEVER relaxed: secrets via env, no customer data,
  never commit `.env`. Must end in a verdict: PROMOTE (→ move to `~/Documents/products/<name>`,
  redo init as serious — only then wiki page + ADRs + tests) or DELETE (no trace).

## Step 1 — ASK THE STACK (only tiers the project actually uses)

Defaults come from `wiki/concepts/default-stack` — state them so Sơn can hit Enter to accept:
Backend Python 3.11+/FastAPI/Pydantic v2 · Web React 18+Vite+Tailwind ·
Mobile React Native+TypeScript · Tests pytest/vitest (RN → Jest).

## Step 2 — Deviation from a default → ADR before code *(skip if 🧪)*

For each non-default choice: create `docs/decisions/NNN-<slug>.md` in the project repo
(Context · Decision · Rationale · Consequences — English). No ADR, no code for the deviating part.

## Step 3 — Scaffold

1. New repo at `~/Documents/products/<name>` (🧪 → `~/Documents/spikes/<name>`), git init.
2. Write the project's `CLAUDE.md`: **product-specific technical content only** (chosen stack,
   layout, build/test commands, project rules — which may only be stricter than the shared
   rules, never looser). No behavior rules or backstory here — global `~/.claude/CLAUDE.md`
   + the wiki cover those. Right before the first heading, add the auto-load line
   `@~/Documents/simon-brain/wiki/projects/<name>.md` (the page itself is created in Step 4) —
   prose pointers don't inject context; only @import lines do (see `entities/simon-platform`).
3. Layout: single tier → flat at root; ≥2 tiers → `backend/`, `frontend/` (see default-stack).
4. The detailed code skeleton is built AFTER cd-ing into the project — not part of init.

## Step 4 — Create the project's wiki page *(skip if 🧪)*

Create `~/Documents/simon-brain/wiki/projects/<name>.md` from this template:

```markdown
---
title: <name>
type: project
status: seed
updated: <date>
tags: []
sources: [<repo path>]
---

# <name>

<Goal in 1-2 sentences>. Type: <backend/frontend/fullstack/mobile>. Stack: <as locked; link [[default-stack]] if default>.
Initialized: <date>. Current state: the project repo.

## Decisions & rationale

*(none yet)*
```

Update `wiki/index.md`, append one line to `wiki/log.md`, commit simon-brain per AGENTS.md §6.

## Step 5 — Handoff

Summarize: type, locked stack, ADRs (if any), repo path + wiki page. Wait for Sơn's approval
before planning the first feature.
