# Skills to install on a new machine

> For the Claude agent on the new machine: Sơn will point you here. Install exactly this list,
> nothing more. Talk to Sơn in Vietnamese.

## 1. Foundation first

```bash
cd ~/Documents/simon-brain && ./setup.sh
```

Brings in `project-init`, `project-retro`, `wrap-up`, `wiki-lint`, `module-map` (symlinks) + `~/.claude/CLAUDE.md`
(global rules) + `~/Documents/{products,spikes}`. If `~/.claude/CLAUDE.md` already exists as a
real file, delete it and re-run.

## 2. Plugins (Claude Code marketplace)

Add marketplace `anthropics/skills`, then install:

| Plugin | Why |
|---|---|
| `document-skills` | xlsx / docx / pptx / pdf handling |
| `example-skills` | artifact & design toolkits |

## 3. Skill pack (install via the skills CLI — `npx skills`, from vercel-labs/skills)

React Native / iOS / TS trade-craft + working discipline.

**One command per skill.** `-s` takes a single name, and the agent is `claude-code`:

```bash
npx skills add <repo> -g -s <skill> -a claude-code -y
```

⚠️ `-s a,b` does **not** install two skills. The CLI matches nothing, prints the repo's whole
skill list, and exits having installed zero — no error, and still a closing "Done!". A wrong
`-a` is the friendlier twin: it does say `Invalid agents: …`. Count afterwards (§5), never skim.

| Source repo | Skills |
|---|---|
| `dpearson2699/swift-ios-skills` | swift-language · swift-api-design-guidelines · swiftui-gestures · swiftui-uikit-interop · ios-simulator · debugging-instruments |
| `callstackincubator/agent-skills` | react-native-best-practices · upgrading-react-native |
| `vercel-labs/agent-skills` | vercel-react-native-skills (path: skills/react-native-skills) |
| `obra/superpowers` | **only** systematic-debugging — then delete its upstream test fixtures (`CREATION-LOG.md`, `test-pressure-*.md`, `test-academic.md`); keep `SKILL.md` and the files it references |

`module-map` used to sit in that last row. It now ships with simon-brain (`skills/module-map`,
linked by §1): upstream's frontmatter is invalid YAML, so the CLI skips it — silently, one
`⚠ Skipped` line buried in a hundred. See the Provenance note inside that file.

**Doing ok2ship only?** ok2ship-ai is FastAPI + React/TS, so §3 narrows to
`systematic-debugging` — one skill, `ls ~/.claude/skills | wc -l` → 6 with §1.
The six swift-ios and three React Native ones wait until native-skline-chart starts.

## 4. Deliberately NOT installed — don't "helpfully" add them

The rest of `rohitg00/pro-workflow` and `obra/superpowers` (orchestrate, agent-teams,
session-handoff, learn-rule, smart-commit, subagent-driven-development,
dispatching-parallel-agents, token-efficiency, …) and `claude-mem`: their roles are covered by
the simon-brain wiki (AGENTS.md), the solo-agent model, or Claude Code built-ins.
Decision recorded 2026-09-07.

Removed 2026-10-01 after three weeks with zero invocations (counted in the session transcripts):
`typescript-advanced-types` (a tutorial the model already knows), `deslop` (built-in `/simplify`
covers it), `verification-before-completion` (the harness now demands evidence before completion
claims; its 5-step gate moves into the `wrap-up` skill), `plan-interrogate` (plan mode covers it;
its one-question-at-a-time method moves into `concepts/approval-gates`). A skill whose
description is generic advice ("use when you hit a bug") is never invoked — only named rituals are.
`git-workflow` went the same day for the opposite reason: ~390 commits in three weeks followed
its conventions with the skill opened once, because they are Claude Code's defaults; the rules
that are not defaults (branching, commit-on-green, review before Sơn) now live in
`concepts/approval-gates`, where every agent — not only Claude Code — is pointed.

## 5. Verify

Count, don't skim — both known CLI failure modes end on a cheerful "Done!":

```bash
ls ~/.claude/skills | wc -l   # 5 from §1 + one per §3 skill installed (all of §3 → 15)
ls ~/.claude/skills           # eyeball the names against §1 + §3
```

Then open a session in `~/Documents/products/ok2ship-ai`: it should know the project + rules
without reading files (the @import chain).
