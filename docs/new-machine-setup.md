# Skills to install on a new machine

> For the Claude agent on the new machine: Sơn will point you here. Install exactly this list,
> nothing more. Talk to Sơn in Vietnamese.

## 1. Foundation first

```bash
cd ~/Documents/simon-brain && ./setup.sh
```

Brings in `git-workflow`, `module-map`, `project-init`, `project-retro` (symlinks) + `~/.claude/CLAUDE.md`
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
| `wshobson/agents` | typescript-advanced-types |
| `obra/superpowers` | systematic-debugging · verification-before-completion |
| `rohitg00/pro-workflow` | **only** deslop · plan-interrogate |

`module-map` used to sit in that last row. It now ships with simon-brain (`skills/module-map`,
linked by §1): upstream's frontmatter is invalid YAML, so the CLI skips it — silently, one
`⚠ Skipped` line buried in a hundred. See the Provenance note inside that file.

**Doing ok2ship only?** ok2ship-ai is FastAPI + React/TS, so §3 narrows to
`typescript-advanced-types`, `systematic-debugging`, `verification-before-completion`,
`deslop`, `plan-interrogate` — five skills, `ls ~/.claude/skills | wc -l` → 9 with §1.
The six swift-ios and three React Native ones wait until native-skline-chart starts.

## 4. Deliberately NOT installed — don't "helpfully" add them

The rest of `rohitg00/pro-workflow` and `obra/superpowers` (orchestrate, agent-teams,
session-handoff, learn-rule, smart-commit, subagent-driven-development,
dispatching-parallel-agents, token-efficiency, …) and `claude-mem`: their roles are covered by
the simon-brain wiki (AGENTS.md), the solo-agent model, or Claude Code built-ins.
Decision recorded 2026-09-07.

## 5. Verify

Count, don't skim — both known CLI failure modes end on a cheerful "Done!":

```bash
ls ~/.claude/skills | wc -l   # 4 from §1 + one per §3 skill installed (all of §3 → 18)
ls ~/.claude/skills           # eyeball the names against §1 + §3
```

Then open a session in `~/Documents/products/ok2ship-ai`: it should know the project + rules
without reading files (the @import chain).
