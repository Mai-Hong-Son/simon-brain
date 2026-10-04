---
title: vn30f-bot
type: project
status: active
updated: 2026-10-04
tags: [trading, derivatives, python, ssi, dashboard]
sources: [~/Documents/products/vn30f-bot, https://guide.ssi.com.vn/ssi-products, https://github.com/SSI-Securities-Corporation/python-fctrading, https://github.com/SSI-Securities-Corporation/python-fcdata]
read_when: project:vn30f-bot
---

# vn30f-bot

Automated trading bot for **VN30 index futures** on HNX's derivatives market, through the **SSI
FastConnect API**. Built for a client who owns and operates it: their account, keys, daily OTP and
server; Sơn builds, sets the server up, hands root back, and supports on exported data only. Sơn
develops on his own SSI account, never a client's. Three surfaces: the bot (a long-lived process),
a read-only dashboard, and a nine-command operator console. Stack: Python 3.12 + Pydantic v2 +
pytest plus the default web tier ([[default-stack]]). Initialized 2026-09-16.

The operative rules (money safety, 2FA, secrets, limits, roles) live in the repo's `CLAUDE.md`,
which every session loads, and open work in its `HANDOFF.md`; this page keeps only **why** each
decision was taken and what was rejected. How the pieces fit together: [[vn30f-bot-architecture]].

## Decisions & rationale

- **No web framework for the bot** (ADR 001). Work arrives on push streams and the process holds
  live positions; a framework would serve no caller and invite multi-worker deployment, which for
  one account means duplicate orders.
- **Separate processes, one writer, a deterministic core behind ports** (ADR 002, amended by
  006): bot, dashboard API, CLI, console; the core reads no wall clock, so a recorded day
  replays to the same decisions. Rejected: one process serving the dashboard too — an
  HTTP surface beside the credentials.
- **Our own FastConnect client** (ADR 003): the money path (tokens, OTP, signing, order payloads,
  reconciliation) and, since 2026-09-25, the SignalR transport over `aiohttp`. Rejected: SSI's
  SDKs — blocking calls, no timeouts, a signer that prints the 2FA code; they remain the source for
  protocol details the guide omits.
- **SQLite WAL for the log and state, a Unix socket for control** (ADR 004). One writer on one
  machine. Rejected: PostgreSQL — a daemon to secure and patch on the host holding the keys.
- **The dashboard is read-only and blind to the credentials** (ADR 005). A compromised screen has
  nothing to sign an order with. Rejected: an order ticket in the viewing screen — a write path in
  the web tier for the one action that spends money.
- **The write surface is a separate operator console** (ADR 006), because the owner uses no
  terminal and the dashboard's read-only proof is worth keeping. The bot validates every command,
  so a console bug cannot become a trading bug; reducing risk is instant, raising it waits.
  Rejected: write routes on the dashboard; a Telegram bot as control surface (OTP and keys through
  a third-party chat; fine for outbound alerts only).
- **2FA is OTP on a delivered system, once per trading day**; PIN only in development, because it
  sits in the environment and SSI is retiring it. An OTP cannot be minted, so a bot that restarts
  mid-session needs a person.
- **Accountability by construction**: every order event carries its config version, every version
  the request that authorized it. Rejected: client screenshots in the repo behind `.gitignore` — a
  Docker context or deploy rsync takes the folder along.
- **The simulated broker fills pessimistically and states its assumptions** (ADR 007, proposed).
  With no sandbox every number comes from it, so its errors must point one way: later and worse.
  Rejected: filling on touch; probabilistic fills (the assumption hidden in a coin flip).
- **The entry is a score, not a set of conditions** (ADR 008). Hard conditions entered 93% of their
  own signals: a condition cannot rank two moments that both meet it. Weights start equal — fitted
  on one session they fit the session. ADR 009 (proposed) replaces ADR 008's tick-wait
  confirmation with the client's own two entry moments, measured before the push.
- **The instrument code is the KRX-style one** (`41I1GA000` for October 2026; `VN30F1M` is a
  rolling alias). The recorder's `--symbol` default is hard-coded and changes at each expiry.

## Lessons

- **On this feed, count seconds or episodes, never updates.** ~40 book snapshots a second put any
  "updates" measure out by two orders of magnitude (17,468 lulls found where there were ~300).
- **Exits decide the sign before entries do.** A fixed target plus a time cap and no stop stacks
  the losers at the cap, wherever it is set (300 s for the previous team; ours is a parameter). Swept at one
  contract, every stop tighter than about 1.0 point was worse than none; target 1.0 with a 1.5 stop
  was six times better than the baseline at 19 contracts while the win rate fell from 68% to 53%.
  Below the round-trip cost, winning trades still lose.
- **Judge a filter by separation, not win rate.** Win rate mixes entry, exit ladder, queue model and
  fee; separation (forward move of kept vs rejected, both printed) does not. Build that instrument
  before the filter it judges.
- **A component that never varies is a broken measurement, not a weak signal.** A unit-free formula
  fed raw contract counts read 1.00 at 100% of moments. Print every input's distribution first.
- **A gap detector that cannot fire still reports zero gaps** — the morning's first subscribe
  replays the previous session's close; case for [[engineering-rules]] #1, "a monitor must tell silence from
  health".
- **Safety rules were each broken on purpose to find the test that catches them** — the case for
  [[engineering-rules]] #1. Clear `__pycache__` first: a same-length patch in the same second
  leaves stale bytecode in place.
- **A plausible summary of the right document is still not the document**: a web summary said the
  last trading day is the third Tuesday; SSI's sheet says Thursday. **Some spec-sheet numbers are
  not constants** — the printed margin ratio is set by VSD and revised.
- **A reason for rejecting a dependency expires quietly**: the gevent objection to SSI's SDK had
  been false for years when it was written down. Read the changelog before recording why.
