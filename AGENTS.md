# AGENTS.md — Operating schema for the `simon-brain` wiki

This repo is Sơn's **long-term memory** + the **institutional knowledge** of the simon-platform.
Multiple agents read/write it, synced via git across machines.

Every agent working in this repo MUST read this file before writing anything into `wiki/`.

**Language: everything committed to this repo is English** (pages, skills, commit messages).
Everything addressed to Sơn is Vietnamese. Vietnamese may appear only when quoting original
Vietnamese material (vendor wording, BA terminology, UI copy).

---

## 0. Three layers

| Layer | Path | Owner | Rule |
|---|---|---|---|
| Raw sources | `raw/sources/` | Sơn | **Immutable.** Agents read, never modify/delete/rename. |
| Wiki | `wiki/` | Agent (Sơn approves) | Agents write all of it. Sơn reads, asks, approves. |
| Schema | `AGENTS.md` (this file) | Sơn + agent co-evolve | Change only with Sơn's explicit approval. |

`agents/` and `skills/` are **capability config of the platform** (see wiki `entities/simon-platform`),
not wiki content. Don't ingest wiki content there or vice versa.

### `wiki/` structure

```
wiki/
  index.md        # root hub — catalog of the whole wiki, thin
  log.md          # append-only journal, 1 line per event
  concepts/       # reusable knowledge: patterns, techniques, shared lessons, mental models
  entities/       # people, companies, products, tools, models, clients
  projects/       # ongoing work: products, campaigns, systems, long-running research
```

File names: kebab-case, one topic per page: `wiki/concepts/prompt-caching.md`.
Link with wikilinks `[[prompt-caching]]` (Obsidian-compatible). Link liberally — a link to a
page that doesn't exist yet is valid; it marks a page worth writing later.

### Required frontmatter on every wiki page

```yaml
---
title: Prompt caching
type: concept        # concept | entity | project | hub
status: seed         # seed | active | stable
updated: 2026-09-07  # last-edited date, absolute — never "today"/"last week"
tags: [llm, cost]
sources: [raw/sources/anthropic-caching-docs.md]
---
```

### Experiment zone

Experiments live in `~/exp/` or repos prefixed `exp-`, and **don't write to the wiki by default**.
Only when an experiment yields a lesson worth keeping → distill one line into a concept page
(still through the §7 approval gate). Dead experiment → delete, leave no trace.

### Third-party sources

This repo holds self-written or modified material + the rebuild manifest (`setup.sh`).
Don't vendor other people's work verbatim unless deliberate — then record the fork origin and version.

---

## 1. Quality gate — rule number one

> **"One month from now, is this still true and still useful?"**

Before EVERY line written into `wiki/`, ask that question. Not confident on **both** halves → **don't write**.

| Write ✅ | Don't write ❌ |
|---|---|
| Settled conclusions, with reasons | Ideas still under consideration |
| Constraints/decisions still in force | Transient state: "waiting for the API key" |
| The lesson extracted from a failure | The play-by-play of that failure |
| Numbers/facts with source + date | Half-remembered numbers, no source |
| How a system works | Command logs, terminal output, code diffs |
| Sơn's preferences and working principles | Praise, greetings, conversational meta |

A thin, correct wiki beats a thick, rotten one. When in doubt → **don't write**; raise it in the
end-of-session proposal for Sơn to decide.

---

## 2. Store durable conclusions only — never session narrative

The wiki is **state**, not a **transcript**.

Forbidden in wiki pages (except `log.md`):
- Narrative wording: "today", "just now", "in this session", "we tried", "the agent ran".
- The chronology of a working session: tried A → failed → tried B → worked.
- References to the conversation itself or to which agent wrote the page.

The right form: **failed-tried-worked → write down the "worked" + why the "failed" failed**, as a
present-tense rule.

> ❌ "Today the agent tried `pip install` in the sandbox, got blocked, then switched to `uv` and it worked."
> ✅ "In this sandbox `pip install` is network-blocked. Use `uv pip install --offline` with a local cache. — source: [[dev-sandbox]], 2026-09-07"

`wiki/log.md` is the **only** place allowed to be chronological, one line per event:

```
## [2026-09-07] ingest | Karpathy — LLM Wiki | @claude-code
## [2026-09-07] lint | 3 orphans, 1 contradiction in [[pricing]] | @researcher
```

Fixed format `## [YYYY-MM-DD] <ingest|query|lint> | <topic> | @<agent>` so it stays greppable:
`grep "^## \[" wiki/log.md | tail -20`

### Record the shape, not the current value

The wiki records the **shape** of things, never **instantaneous values**: no versions, file counts,
test counts, SHAs, or commit URLs in wiki pages — those numbers go stale on the next push.
Need current detail → link to the repo and let the repo speak.

### When wiki and repo contradict

The repo (code + docs) wins on **current state**; the wiki wins on **decision history and rationale**.
On a contradiction → never silently pick a side: report to Sơn, propose fixing the wrong one
(usually the wiki has rotted — update it and note it at lint).

---

## 3. Where lessons go — project vs concept

| Kind of lesson | Where it goes |
|---|---|
| True only in **one project's** context (codebase quirk, one client's agreement, local config) | `wiki/projects/<project>.md` |
| **Reusable** across projects (pattern, technique, principle, how a tool behaves) | `wiki/concepts/<concept>.md` **plus** a link from the project page |

The project page keeps **one line** of context + a link — never a copy of the concept:

```markdown
### Lessons
- The vendor's rate limit counts tokens/minute, not requests/minute → see [[api-rate-limiting]] for the general handling.
```

**Promotion rule:** a lesson that shows up in **≥ 2 projects** → extract into a `concepts/` page;
the project pages keep only links. Lint passes must detect this.

**Demotion rule:** a `concepts/` page used by exactly one project with no sign of reuse →
merge back into the project page, propose deletion.

### Architecture decisions (ADR)

- The project's wiki page records each architecture decision as **decision + rationale + rejected alternatives**.
- The detailed, code-attached ADR (full context/consequences) lives in the product repo
  (`docs/decisions/`); the wiki points to it — no duplication.
- Deviating from the default stack (see `concepts/default-stack`) → an ADR in the product repo
  **before any code**.

---

## 4. Hubs stay thin

A hub = `wiki/index.md`, plus **any page with child pages** (e.g. `projects/ok2ship.md` is the hub
of its children).

Hub rules:
- A hub holds **overview + links** only. Each item at most **2 lines**, then link down.
- A hub is **≤ 100 lines**. Exceeding that is the signal to split.
- An item growing past **~10 lines** → extract a child page, leave 1 summary sentence + `[[link]]`.
- Details, figures, examples, history → **always** on child pages, never on the hub.
- A hub is never the home of original knowledge. If deleting the hub loses information,
  that content was in the wrong place.

`wiki/index.md` is the catalog: grouped `concepts / entities / projects`, one line per page
`- [[slug]] — one-sentence summary`. Updated on **every** ingest.

---

## 5. Three workflows

### 5.1 `ingest` — take in a new source

Trigger: Sơn drops a file into `raw/sources/`, pastes a link, or says "ingest this".

1. `git pull --rebase` before reading (see §6).
2. Read the **whole** source. Never summarize from the title.
3. Read `wiki/index.md` to know which pages exist and might be affected.
4. **Discuss takeaways with Sơn before writing.** Present 3–7 key points + the list of pages
   to create/update.
5. After Sơn approves: write/update the pages, running §1's quality gate on every point.
   - New info **contradicts** old info → **never delete the old**. Record both with dates +
     sources, mark `> ⚠️ Contradiction:` and raise it at lint.
   - New info **extends** → merge into the existing page; don't create a duplicate topic.
6. Update `wiki/index.md`, add cross-links both ways.
7. Append **one line** to `wiki/log.md`.
8. Commit (see §6).

A good source typically touches 3–15 pages. Touching only 1 page suggests a shallow read.

### 5.2 `query` — ask the wiki

Trigger: Sơn asks a question about what's known.

1. Read `wiki/index.md` first → pick relevant pages → read them → then answer.
2. Answer with **wikilink citations** to the source pages.
3. If the wiki lacks the facts: **say so plainly**; don't speculate and write the speculation
   back into the wiki. Propose sources to find.
4. **Good answers get filed back into the wiki.** If the answer is a synthesis/comparison/new
   connection that passes §1's gate → propose a new page for it at the end of the session.
   Don't let it die in chat history.

### 5.3 `lint` — health-check the wiki

Trigger: Sơn says "lint", or periodically after every ~10 ingests.

Check and produce a **report — no self-applied fixes**:
- **Contradictions** between pages, or unresolved `⚠️ Contradiction` markers.
- **Stale pages**: `updated` older than 90 days, or claims superseded by newer sources.
- **Orphans**: pages with no inbound links.
- **Broken links / links to not-yet-written pages** → a list of pages worth writing.
- **§2 violations**: pages containing session-narrative language.
- **§4 violations**: hubs > 100 lines, or hub items > 10 lines.
- **§3 promotion candidates**: lessons repeated across ≥ 2 project pages.
- **Duplicate-topic pages** that should merge.
- **Data gaps**: concepts mentioned repeatedly that lack their own page.

End with proposals: questions worth digging into, sources worth finding. Wait for Sơn's pick
before fixing anything.

---

## 6. Many agents, many machines — git rules

Multiple agents may write concurrently from multiple machines. Mandatory:

1. **`git pull --rebase` at session start** and **again right before committing**. No exceptions.
2. **Small commits, one workflow per commit.** Messages in English:
   `wiki(ingest): Karpathy LLM Wiki — 4 pages` / `wiki(lint): fix 3 orphans` / `wiki(query): add vector-db-comparison`
3. **Never** `push --force`, `rebase -i`, `reset --hard` on `main`, or rewrite history.
   The wiki's history is part of the memory.
4. **Don't commit `raw/`** when sources are heavy/copyrighted — ask Sơn first.
5. **Conflict handling:**
   - `wiki/log.md`: appends at the end → always resolve by **keeping both lines**, sorted by date.
   - Content pages: **keep both versions**, mark `> ⚠️ Contradiction:` with each side's source +
     date, and let lint sort it out. **Never silently pick one side and delete the other.**
6. **Sign every log line** with the agent name (`@claude-code`, `@researcher`, ...) so changes
   stay traceable.
7. No two agents edit the same page in the same pass. If unavoidable, split by page,
   never by section.

---

## 7. End of session — propose and wait for approval

**Agents never write to `wiki/` without approval.** The default is proposing, not acting.

At the end of each session (or when Sơn says "wrap up"), output exactly this table:

```
## Proposed wiki updates

| # | Page | Action | Content (1 sentence) | Quality gate |
|---|------|--------|----------------------|--------------|
| 1 | concepts/prompt-caching.md | create | 1h cache TTL saves ~90% input cost | ✅ still true in a month |
| 2 | projects/ok2ship-ai.md | edit | Add rate-limit lesson + concept link | ✅ |
| 3 | index.md | edit | Add 1 line for the new page | ✅ |

Not proposed (failed the quality gate): <short list + reasons>
```

Then **stop and wait**. Sơn answers with numbers (`1,3` / `all` / `none`). Write only the
approved items, then commit.

The single exception: Sơn explicitly says "ingest on your own, don't ask" — even then, report
the list of touched pages after writing.

---

## 8. Pre-write checklist

- [ ] Ran `git pull --rebase`?
- [ ] Passed the quality gate: **still true and still useful one month from now?**
- [ ] A durable conclusion, not session narrative?
- [ ] Lesson filed at the right level: project-only → project page; reusable → concept + link?
- [ ] Hubs still thin (overview + links only)?
- [ ] Frontmatter present, `updated` an absolute date?
- [ ] Cross-linked both ways? `index.md` updated? One line appended to `log.md`?
- [ ] Approved by Sơn?
