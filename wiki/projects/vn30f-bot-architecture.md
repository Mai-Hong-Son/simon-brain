---
title: vn30f-bot architecture
type: project
status: active
updated: 2026-10-04
tags: [trading, architecture, fastconnect, operations]
sources: [products/vn30f-bot/docs/decisions]
read_when: on-demand — how the processes, layers, storage and scheduler fit together, before changing any of them
---

How [[vn30f-bot]] is put together, and the one rule that shapes all of it: **the thing that spends
money is kept apart from the thing people look at.** Code detail lives in the product repo; this
page records the shape and why it is that shape.

## Separate processes, one wall

| Process | Does | May touch |
|---|---|---|
| **The bot** | Connects to SSI, records market data, measures and decides; the only process that may place an order | SSI credentials, the store (the only writer) |
| **The dashboard API** | Serves what the bot wrote to the React screen, read-only | the store (read only) |
| **The CLI** | Development control: open session, status, kill switch, manual orders | the control socket |
| **The operator console** | The owner's control surface on a delivered system (ADR 006) | the control socket |

The dashboard API exists because a browser cannot open a file on disk — that is its whole reason
to be. It holds no SSI credential, so a compromised screen has nothing to sign an order with. The
CLI and the console are two front-ends over one control socket; neither connects to SSI, and the
bot validates every command.

Each runs alone: the bot records with nothing else running, and the screen shows a finished day
with no bot alive. Tests fail if the dashboard imports the broker, or if the core imports anything
of ours.

## Inside the bot, four layers

1. **Transport** — our own minimal classic-SignalR client over `aiohttp`. Six steps: negotiate,
   websocket, start, invoke, read frames, close. No reconnect machinery, because a supervisor above
   it discards a quiet connection and builds a new one.
2. **Translation** — the vendor's vocabulary ends here. Nothing downstream knows what `BidPrice1`
   means, and payload shapes are confirmed against captured live messages, not the vendor's guide.
3. **Core** — the deterministic part: instrument geometry, book, flow measurements, scoring, entry
   gates, exit ladder, orders, position, risk guards. No I/O, no clock, no randomness, so a
   recorded day replays to the same numbers.
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

## How it starts

The recorder is meant to start from `launchd` (a wrapper script supplies PATH and environment;
`uv run` supplies the interpreter) and stop itself at a set clock time. **On macOS it cannot**: a
`launchd` agent is denied `~/Documents` by TCC, so it is started by hand each morning — see
[[simon-platform]] for the platform-wide trap and its fixes. A run started by hand holds the
single-writer lock and a scheduled run then refuses loudly: two writers would corrupt the day's
ordering.

## Invariants worth keeping

- The recorder is given the **Data** credentials only. It cannot sign an order because the secret
  that would do it is not in the process, not because a flag says no.
- No measurement is computed across a recorded gap in the feed; it is reported as unmeasurable.
- A trading day is one file, append-only. Replaying it produces a new file and never touches it.

## Lessons

- **A watchdog measures the thing, it does not ask the component.** "Are messages still arriving"
  cannot be answered wrongly; "are you connected" can: a transport can sit on a dead socket at
  full CPU, reporting nothing and starving everything else on the same event loop, while the
  process looks healthy.
- **A gap check is only as good as the ordering beneath it.** This feed delivers trades out of
  order within a second; comparing each message with the one before it reported hundreds of gaps on
  a session that was complete to the contract. Count what is unaccounted for instead.
- **The feed has a sequence number it claims not to have**: cumulative traded volume orders the
  prints exactly, whatever order they arrive in. Only for trades — quotes have nothing.
- **An unmaintained transport announces itself in private-API workarounds.** Each one is a pin or an
  override that a future upgrade breaks; their count is the decision signal. Writing the protocol
  yourself is smaller than it looks once a supervisor owns recovery.
- **A schedule that has never fired has not been shown to work**: a job installed and listed by
  `launchctl` can still never run. Check the recording's own start time, not the scheduler's list.
