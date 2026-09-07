# New-machine setup — Mac Studio migration

> **For the Claude agent on the new machine:** Sơn will point you at this file. Execute it
> top-to-bottom, report after each numbered section, and ask before deleting anything not
> explicitly listed here. Talk to Sơn in Vietnamese; keep everything you write to disk in English.

Context: Sơn is migrating from a MacBook to a Mac Studio. simon-brain is the foundation
(see `README.md` and `wiki/entities/simon-platform.md`). Some material cannot travel through
git (customer data, secrets, machine-local memory) and arrives via AirDrop instead.

---

## 0. What must arrive via AirDrop (verify before anything else)

Check each item exists; if anything is missing, STOP and tell Sơn before proceeding:

| Item | Target path on this machine | Why not git |
|---|---|---|
| `simon-brain/` | `~/Documents/simon-brain` | Can also be cloned later, but AirDrop avoids the SSH chicken-and-egg |
| `products/` (ok2ship-ai + nested backend/frontend, native-skline-chart) | `~/Documents/products` | native-skline-chart has NO remote; ok2ship data/.env ride along |
| `spikes/` (ok2ship-anomaly, ok2ship-report-parser, void-guard-xval) | `~/Documents/spikes` | Spikes have NO remotes (deliberate); `data/`, `datasets/`, `output/` are customer data — never push them anywhere |
| `~/.claude/` (whole folder) | `~/.claude` | Machine-local memory (`projects/*/memory`), session history, `settings.json`, keybindings |
| `~/.agents/` (whole folder) | `~/.agents` | The RN/Swift/iOS skill pack — `~/.claude/skills` symlinks point here by absolute path |
| `~/.ssh/` (or Sơn creates new keys) | `~/.ssh` | GitHub + GitLab access; without it no push/pull works |
| Factory data folders from `~/Downloads` (`report-data-example`, `Ảnh mẫu bất thường`, `AI ok2ship`…) | `~/Downloads/` (same names) | Spike HANDOFFs reference these exact paths; customer data |
| `native-kline-view/` | `~/Documents/native-kline-view` | Reference library that native-skline-chart's ADR 005 ports from |

## 1. Base tooling

```bash
xcode-select --install                     # git, clang
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install gh uv node
brew install --cask obsidian
git config --global user.name  "Mai Hong Son"
git config --global user.email "mhongson95@gmail.com"
gh auth login                              # if ~/.ssh didn't arrive, create keys here and add to GitHub + GitLab
```

Verify remotes are reachable: `ssh -T git@github.com` and `ssh -T git@gitlab.com`.

## 2. Plug in the foundation

```bash
cd ~/Documents/simon-brain && git pull --rebase && ./setup.sh
```

Expected: symlinks for the 3 simon-brain skills, `~/.claude/CLAUDE.md -> config/global-rules.md`,
and `~/Documents/{products,spikes}` present. Note: setup.sh will find `~/.claude/CLAUDE.md`
already exists as a REAL file from the AirDropped `~/.claude` — delete that file
(`rm ~/.claude/CLAUDE.md`) and re-run `./setup.sh` so the symlink wins.

Verify: `readlink ~/.claude/CLAUDE.md` prints the config/global-rules.md path, and
`head -3 ~/.claude/CLAUDE.md` shows content.

## 3. Curate the global skills (deletion — confirm the list with Sơn once, then apply)

Decision already made with Sơn (2026-09-07): keep the trade-craft skills, drop the ones whose
role simon-brain or Claude Code now covers.

**KEEP — do not touch:**
- simon-brain symlinks: `git-workflow`, `project-init`, `project-retro`
- RN/iOS/Swift/TS pack (symlinks into `~/.agents/skills`): `react-native-best-practices`,
  `upgrading-react-native`, `vercel-react-native-skills`, `ios-simulator`,
  `debugging-instruments`, `swift-language`, `swift-api-design-guidelines`,
  `swiftui-gestures`, `swiftui-uikit-interop`, `typescript-advanced-types`
- Working discipline: `systematic-debugging`, `verification-before-completion`, `deslop`,
  `module-map`, `plan-interrogate`
- Plugins in settings.json: `document-skills`, `example-skills` (they re-download themselves)

**DELETE from `~/.claude/skills/`** (redundant with the wiki/AGENTS.md, the dissolved
multi-agent model, or Claude Code built-ins):

```
learn-rule replay-learnings insights session-handoff wrap-up smart-commit
orchestrate agent-teams batch-orchestration subagent-driven-development
dispatching-parallel-agents pro-workflow parallel-worktrees permission-tuner
compact-guard context-optimizer context-engineering token-efficiency
thoroughness-scoring sprint-status cost-tracker auto-setup safe-mode
llm-gate file-watcher mcp-audit bug-capture
```

Also delete the loose agent files and their configs in `~/.claude/skills/`:
`context-engineer.md cost-analyst.md debugger.md orchestrator.md permission-analyst.md
planner.md reviewer.md scout.md` and every `.*.skillkit.json`.

## 4. Verify the whole platform

- [ ] `ls ~/.claude/skills` shows only the KEEP list (plus plugin-managed entries).
- [ ] Open a session in `~/Documents/products/ok2ship-ai` and ask "dự án này là gì, luật nào áp dụng?"
      — the answer must come from the auto-loaded wiki page + engineering rules WITHOUT reading
      files first (proves the @import chain works).
- [ ] `git -C ~/Documents/products/ok2ship-ai pull` works (SSH OK).
- [ ] Spike data intact: `du -sh ~/Documents/spikes/ok2ship-anomaly/data` (~330MB expected).
- [ ] Obsidian: follow README "Đọc wiki bằng Obsidian" — vault opens, graph shows the ok2ship cluster.
- [ ] `.env` files present where expected (e.g. `spikes/void-guard-xval/.env`).

## 5. Only after §4 is fully green

Tell Sơn the platform is verified. **Sơn wipes the MacBook himself — never suggest or perform
remote-wiping anything from here.** If any check failed, the MacBook is still the only copy of
that item; say so loudly.
