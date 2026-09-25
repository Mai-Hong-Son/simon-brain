---
title: vn30f-bot architecture
type: project
status: active
updated: 2026-09-25
tags: [trading, architecture, fastconnect, operations]
sources: [products/vn30f-bot/docs/decisions]
---

How [[vn30f-bot]] is put together, and the one rule that shapes all of it: **the thing that spends
money is kept apart from the thing people look at.** Code detail lives in the product repo; this
page records the shape and why it is that shape.

## Three processes, one wall

| Process | Does | May touch |
|---|---|---|
| **The bot** | Connects to SSI, receives market data, writes it to the day's file. Later: signals, orders, exits, reconciliation | SSI credentials, the store (write) |
| **The dashboard API** | Serves what the bot wrote, over HTTP, so a browser can read it | the store (read only) |
| **The web UI** | Draws the ladder, the tape, the price line | the API |

The API exists because a browser cannot open a file on disk — that is its whole reason to be. It
holds no SSI credential, so a compromised screen has nothing to sign an order with.

Each runs alone: the bot records with nothing else running, and the screen shows a finished day
with no bot alive. Tests fail if the dashboard imports the broker, or if the core imports anything
of ours.

## Inside the bot, four layers

1. **Transport** — our own minimal classic-SignalR client over `aiohttp`. Six steps: negotiate,
   websocket, start, invoke, read frames, close. No reconnect machinery, because a supervisor above
   it discards a quiet connection and builds a new one.
2. **Translation** — the vendor's vocabulary ends here. Nothing downstream knows what `BidPrice1`
   means, and payload shapes are confirmed against captured live messages, not the vendor's guide.
3. **Core** — the deterministic part: instrument geometry, book, orders, position, risk guards,
   market state, the signal measurements. No I/O, no clock, no randomness, so a recorded day
   replays to the same numbers.
4. **Session and loop** — one queue, one consumer, in arrival order. Market messages and operator
   commands meet here and nowhere else, and **every inbound message is written to the log before it
   is handled**.

## Where things live, and why

| | Location | Why there |
|---|---|---|
| Code, ADRs, verified vendor facts, the signal spec | product repo | travels with the code |
| Market recordings, one file per day | repo, git-ignored | belongs to the project, is not source |
| **SSI credentials** | **outside the repo**, user config dir, owner-only | a project directory has more exits than git: a deploy rsync or a Docker build context takes ignored files along |
| **The client's own documents** | **outside the repo** | customer data, deleted when the work ends |

A day of recording runs to hundreds of megabytes, and **cannot be recreated** — nobody sells VN30F
order-book history. That single fact drives the data directory being resolved from the project
rather than from wherever a command was run, and never `/tmp`.

## How it starts itself

`launchd` (always running, holds the schedule) → a wrapper script → the CLI's record command, which
stops itself at a set clock time.

A scheduled process starts with **no environment**: no shell PATH, no exported variables, no
activated virtualenv. The wrapper supplies the first two from a file and the path; `uv run` supplies
the interpreter and dependencies by itself. That is why the schedule needs no terminal and no
person.

One operational trap: a run started by hand holds the single-writer lock, and a scheduled run then
refuses to start. The lock is correct — two writers would corrupt the day's ordering — so the
refusal is made loud rather than removed.

## Invariants worth keeping

- The recorder is given the **Data** credentials only. It cannot sign an order because the secret
  that would do it is not in the process, not because a flag says no.
- No measurement is computed across a recorded gap in the feed; it is reported as unmeasurable.
- A trading day is one file, append-only. Replaying it produces a new file and never touches it.

## Lessons

- **A watchdog measures the thing, it does not ask the component.** "Are messages still arriving"
  cannot be answered wrongly; "are you connected" can, and was — a transport once sat on a dead
  socket at full CPU, reporting nothing, starving everything else on the same event loop while the
  process looked healthy. Silence is the only honest signal.
- **A gap check is only as good as the ordering beneath it.** This feed delivers trades out of
  order within a second; comparing each message with the one before it reported hundreds of gaps on
  a session that was complete to the contract. Count what is unaccounted for instead — reordering
  then resolves itself and a real break stays visible.
- **The feed has a sequence number it claims not to have**: cumulative traded volume orders the
  prints exactly, whatever order they arrive in. Only for trades — quotes have nothing.
- **An unmaintained transport announces itself in private-API workarounds.** Each one is a pin or an
  override that a future upgrade breaks; the count of them is the decision signal, not any single
  defect. Writing the protocol yourself is smaller than it looks once a supervisor owns recovery.
- **A client's own figures are checks on our detectors, not parameters to set.** Their "the market
  goes quiet for five to ten seconds" caught a lull detector that was counting book updates rather
  than seconds and was wrong by three orders of magnitude.
