# Skills to install on a new machine

> For the Claude agent on the new machine: Sơn will point you here. Install exactly this list,
> nothing more. Talk to Sơn in Vietnamese.

## 1. Foundation first

```bash
cd ~/Documents/simon-brain && ./setup.sh
```

Brings in `git-workflow`, `project-init`, `project-retro` (symlinks) + `~/.claude/CLAUDE.md`
(global rules) + `~/Documents/{products,spikes}`. If `~/.claude/CLAUDE.md` already exists as a
real file, delete it and re-run.

## 2. Plugins (Claude Code marketplace)

Add marketplace `anthropics/skills`, then install:

| Plugin | Why |
|---|---|
| `document-skills` | xlsx / docx / pptx / pdf handling |
| `example-skills` | artifact & design toolkits |

## 3. Skill pack (install via the skills CLI — `npx skills`, from vercel-labs/skills)

React Native / iOS / TS trade-craft + working discipline. Repo → skills:

| Source repo | Skills |
|---|---|
| `dpearson2699/swift-ios-skills` | swift-language · swift-api-design-guidelines · swiftui-gestures · swiftui-uikit-interop · ios-simulator · debugging-instruments |
| `callstackincubator/agent-skills` | react-native-best-practices · upgrading-react-native |
| `vercel-labs/agent-skills` | vercel-react-native-skills (path: skills/react-native-skills) |
| `wshobson/agents` | typescript-advanced-types |
| `obra/superpowers` | systematic-debugging · verification-before-completion |
| `rohitg00/pro-workflow` | **only** deslop · module-map · plan-interrogate |

## 4. Deliberately NOT installed — don't "helpfully" add them

The rest of `rohitg00/pro-workflow` and `obra/superpowers` (orchestrate, agent-teams,
session-handoff, learn-rule, smart-commit, subagent-driven-development,
dispatching-parallel-agents, token-efficiency, …) and `claude-mem`: their roles are covered by
the simon-brain wiki (AGENTS.md), the solo-agent model, or Claude Code built-ins.
Decision recorded 2026-09-07.

## 5. Verify

`ls ~/.claude/skills` matches §1+§3; open a session in `~/Documents/products/ok2ship-ai` and it
should know the project + rules without reading files (the @import chain).
