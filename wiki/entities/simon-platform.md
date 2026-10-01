---
title: Simon Platform
type: entity
status: active
updated: 2026-10-01
tags: [platform, architecture, meta]
sources: [simon-brain-migration-brief.md (2026-09-07)]
read_when: skill:project-init
---

# Simon Platform — the foundation model

The operating model in force since 09/2026.

It replaced `ai-company` (07–09/2026): a central repo playing "company", with a constitution, six
role-named agents (orchestrator, backend, frontend, mobile, devops, QA) and three skills. Dropped
because the coordination outweighed what it coordinated — an orchestrator larger than the four
dev agents it directed; because a subagent is for context isolation, not role-play — a model does
not need to be told it is the Backend Engineer; because several rules existed only to patch
problems the splitting created; and because once wiki + skills + rules existed, the "company" was
a redundant middle layer. What survived moved here: the rules ([[engineering-rules]]), the stack
([[default-stack]]), the gates ([[approval-gates]]), the skills. The six agents did not. The repo
is archived with its history.

## Architecture

```
SIMON-BRAIN = FOUNDATION (this repo — under every session, every machine, git-synced)
├── wiki/      distilled memory & knowledge
├── agents/    capability pool (not a "team"; solo agent by default)
├── skills/    packaged procedures (symlinked into ~/.claude/skills via setup.sh)
├── AGENTS.md  wiki operating rules
└── setup.sh   rebuilds the foundation on a new machine

~/Documents/products/<name>  = serious products (ok2ship-ai, native-skline-chart, ...)
~/Documents/spikes/<name>    = feasibility spikes — no wiki writes by default;
                               end in PROMOTE (→ products/) or DELETE
Both stand on the foundation and hold only their own code + technical config.
```

**`~/Documents` is a TCC-protected folder, so scheduled automation in any product hits this.** A
macOS `launchd` agent cannot read inside it — no window to ask permission with, so it is denied
rather than prompted — and the job exits 126 on its own script without ever having run. It bit
[[vn30f-bot]], whose recorder had been installed, listed by `launchctl`, and never once worked.
Moving the launcher out does not help, because the interpreter still has to read the source. Decide
it up front for anything that must run unattended: either grant Full Disk Access to what the agent
executes, or keep that project outside `~/Documents`.

## The single-source-of-truth test

| Kind of information | Its one home |
|---|---|
| Agent behavior rules + pointer to the wiki | `~/.claude/CLAUDE.md` (kept thin) |
| Decisions + rationale, lessons, cross-project synthesis | `wiki/` |
| Current code state, build/test commands, technical conventions | the product repo |
| Work-in-progress narrative | the session (evaporates) / the repo's HANDOFF.md |

Anti-drift: the wiki records **shape**, never instantaneous values (AGENTS.md §2).
Wiki↔repo contradiction: repo wins on current state, wiki wins on decision history.

## Context loading — a page is read only if something loads it

Prose pointers load nothing — only `@<path>` lines in a CLAUDE.md inject file content at session
start. Measured twice. 2026-09-07: a product session worked a full day under a dissolved
constitution because nothing auto-loaded the wiki. 2026-10-01: of the 16 product sessions before
that day, the pages that were merely named ([[son]], [[approval-gates]], [[mektec-desoft]]) had
each been opened in 2. Count sessions, not transcript files — a sub-agent leaves a file of its
own.

So every page declares its reader in frontmatter (`read_when`, AGENTS.md §0), and
`scripts/wiki-lint.sh` checks the declaration against the thing that would do the loading:

- `always` — imported by the global rules: [[engineering-rules]], [[son]], [[approval-gates]].
  Rules plus one line of why; every word here is paid by every session, and lint prints the total.
- `project:<name>` — imported by that project's CLAUDE.md: its own project page (`project-init`
  scaffolds the line), plus whatever every session of that project needs ([[mektec-desoft]] for
  ok2ship-ai).
- `skill:<name>` — read at a step of that skill ([[default-stack]] and this page at project-init).
- `on-demand — <question>` — reached through a link from a page that IS loaded, and that link
  states the question. The weakest channel: use it for depth a loaded page already summarises,
  never for a rule.

`AGENTS.md` stays prose-referenced, because the skills that write to the wiki name it at the step
that needs it. A page with no reader is merged into one that has, or deleted.

After changing an import, prove it loads: start a fresh non-interactive session (`claude -p`) in
the directory concerned and have it quote a line of the imported page. The session that made the
change cannot see it — imports are read at session start.

Rejected: "thin pointers, read on demand" for rules — it relies on the session remembering to
read, and both measurements say it does not. Rejected: splitting a page into a rule file and a
detail file — the detail file has no reader. Absolute imports are safe because setup.sh fixes the
repo path at `~/Documents/simon-brain`.

## Agent principle

Default is a **solo agent** — one context does the whole job. Spawn a subagent only for genuine
**context isolation** (adversarial review needs eyes that haven't seen the code — see
[[approval-gates]]), never for role-play.
