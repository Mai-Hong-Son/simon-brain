---
title: vn30f-bot
type: project
status: active
updated: 2026-10-14
tags: [trading, derivatives, python, ssi, dashboard]
sources: [~/Documents/products/vn30f-bot, https://guide.ssi.com.vn/ssi-products, https://github.com/SSI-Securities-Corporation/python-fctrading, https://github.com/SSI-Securities-Corporation/python-fcdata]
read_when: project:vn30f-bot
---

# vn30f-bot

VN30 index futures bot on SSI FastConnect, built for a client who owns and operates it (what it
is and its rules: the repo's `CLAUDE.md`; open work: its `HANDOFF.md`). This page keeps **why**
each decision was taken and what was rejected; how the pieces fit: [[vn30f-bot-architecture]].

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
- **Read-only dashboard** (ADR 005): a compromised screen has nothing to sign an order with.
  Rejected: an order ticket in the viewing screen.
- **Separate operator console** (ADR 006): the owner uses no terminal, and the dashboard's
  read-only proof is worth keeping; the bot validates every command, so a console bug cannot
  become a trading bug. Rejected: write routes on the dashboard; a Telegram bot as control surface
  (OTP and keys through a third-party chat; fine for outbound alerts only).
- **OTP on a delivered system, PIN only in development**: PIN sits in the environment and SSI is
  retiring it.
- **Client material outside the repo**, referenced by name and hash. Rejected: inside the repo
  behind `.gitignore` — a Docker context or deploy rsync takes the folder along.
- **The instrument code is the KRX-style one** (`41I1GA000` for October 2026; `VN30F1M` is a
  rolling alias). The recorder's `--symbol` default is hard-coded and changes at each expiry.

## Lessons

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
