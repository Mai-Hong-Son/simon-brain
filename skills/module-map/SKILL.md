---
name: module-map
description: "Produce a one-screen map of an unfamiliar area of the codebase: entry points, modules, data flow, callers. Designed to be read in fifteen seconds. Use when the user says 'I do not know this area', 'give me the map', 'zoom out', 'orient me'."
---

# module-map

Orient fast in unfamiliar code. The deliverable is a map, not a tour.

## Deliverable

A single response containing, in this order:

1. **One-line summary** of what the area does from a caller's point of view.
2. **Entry points** — every function, route, CLI command, event handler,
   or cron that starts a call chain in this area. File path + symbol.
3. **Core modules** — the two to five modules that contain the real
   logic. One line each describing their role.
4. **Data flow** — ASCII arrows showing the dominant path for the most
   common input. Skip error paths unless they matter architecturally.
5. **External callers** — who outside this area calls in, and through
   which entry points.
6. **Hidden coupling** — anything that looks independent but is not
   (shared singletons, global state, implicit ordering, undocumented
   contracts between files).

## Rules

- Fifteen-second read target. If the map exceeds one screen, cut it.
- Every claim must be backed by a file path. No remembered or inferred
  structure without a grep behind it.
- Do not list every file. Curate. A good map omits deliberately.
- Do not propose changes. Mapping is orientation; refactoring is a
  different skill.
- If the area is too large to map in one screen, segment it and ask the
  user which segment to expand. Do not silently drop half the code.

## Format

```
AREA: <one-line summary>

ENTRY POINTS
- <path>:<symbol>  — <role>

CORE MODULES
- <path>  — <role>

FLOW
<entry> -> <module> -> <module> -> <sink>

CALLERS
- <path>  — uses <entry>

HIDDEN COUPLING
- <description>  (<path>)
```

Use the exact headers. Consistency lets the user scan.

## Provenance

Vendored from [`rohitg00/pro-workflow`](https://github.com/rohitg00/pro-workflow)
(`skills/module-map/`) on 2026-09-07, not installed through the `skills` CLI.

Upstream's `SKILL.md` has an unquoted `:` inside its `description:`, which makes the YAML
frontmatter invalid (`Nested mappings are not allowed in compact mappings`). The CLI skips
such a skill silently — it prints one `⚠ Skipped` line among a hundred, then still reports
"Done!". The only local change is wrapping that description in double quotes.

Living here means `setup.sh` symlinks it like any other simon-brain skill, so every machine
gets it from git instead of re-hitting the broken upstream file. If upstream ever fixes the
frontmatter, this copy can go back to a plain `skills add`.
