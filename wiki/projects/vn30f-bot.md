---
title: vn30f-bot
type: project
status: active
updated: 2026-10-02
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
which every session loads; this page keeps only **why** each was decided and what was rejected.
How the pieces fit together: [[vn30f-bot-architecture]].

## Decisions & rationale

- **No web framework for the bot** (ADR 001). Work arrives on push streams and the process holds
  live positions; a framework would serve no caller and invite multi-worker deployment, which for one
  account means duplicate orders.
- **The dashboard is read-only and blind to the credentials** (ADR 005). A compromised screen then
  has nothing to sign an order with. Access is enforced by the API per role, since hiding a panel is
  not access control. Rejected: an order ticket in the viewing screen — a write path in the web tier
  for the one action that spends money.
- **The write surface is a separate operator console** (ADR 006), because the owner uses no
  terminal and the dashboard's read-only proof is worth keeping. Fixed list of nine commands over the
  same control socket as the CLI; the bot validates each, so a console bug cannot become a trading
  bug. Guards are asymmetric: reducing risk is instant, raising it waits for the close and asks for
  the password again. Rejected: write routes on the dashboard; a Telegram bot as control surface
  (OTP and keys through a third-party chat; fine for outbound alerts only).
- **2FA is OTP on a delivered system, once per trading day.** The write token keeps the code for
  8 hours, which outlasts a session. PIN only in development on Sơn's account, with small limits and
  an encrypted disk, because it sits in the environment and SSI is retiring it. The code source is a
  port, so the switch is one line of config.
- **Accountability by construction.** Every order event carries its config version; every config
  version references the request that authorized it (who, channel, evidence file name + SHA-256,
  risk warning sent); the live runner refuses a version with no request record. Rejected:
  screenshots inside the repo behind `.gitignore` — a Docker build context or a deploy rsync takes
  the folder along, so client material stays outside the repo, referenced by name and hash.
- **Self-imposed daily limits in config, separate from SSI's**, which are read at runtime; the
  loss or order-count limit halts trading for the rest of the day.
- **The entry is a score plus a confirmation, not a set of conditions** (ADR 008). Hard conditions
  entered 93% of their own signals, because a condition cannot rank two moments that both meet it.
  Each client idea is a 0–1 component of a score out of 100; the confirmation (price moves a tick our
  way, then the matched column is read again) is what earns the improvement, measured on a recorded
  day. Weights start equal: fitting them on one session's trades fits the session. Rejected: deeper
  climb thresholds — by then the move has been paid for.
- **The simulated broker fills pessimistically and states its assumptions** (ADR 007). With no
  sandbox every number comes from it, so its errors point one way: later and worse. A resting order
  joins behind the displayed volume and only prints shrink the queue; marketable orders meet the book
  after a latency; gross is reported beside net because at a 0.6-point target the fee decides the
  sign. Rejected: filling on touch (fiction); probabilistic fills (the assumption hidden in a coin
  flip).

## Constraints that shape the build

- **SSI FastConnect has no sandbox — PROD only** (confirmed 2026-09-16, one host per product).
  Hence the project's own simulated broker and the ports/adapters shape.
- **PIN authentication is being retired**; an OTP cannot be minted, so nothing may assume an
  unattended start — a bot that restarts mid-session needs a person.
- **The instrument code is the KRX-style one** (`41I1GA000` for October 2026, verified 2026-09-21
  on Sơn's own order ticket), `VN30F1M` is a rolling alias; the bot asks which contract is front
  month rather than hard-coding it.
- **A recording cannot be recreated** — nobody sells VN30F book history — so the data directory is
  resolved from the project itself and never `/tmp`.
- **Credentials are shown once** on iBoard; the PrivateKey is base64 XML `<RSAKeyValue>`, not PEM;
  money-moving requests carry an `X-Signature` RSA-SHA256 of the exact body.
- **The market-data stream cannot be replayed** (whole-second stamps, no sequence number);
  `TotalVol` continuity is the only gap check. The trading stream resumes from `NotifyID`.
- **HTTP 200 on an order is not an exchange acknowledgement**: sent, accepted by SSI, and
  acknowledged by the exchange are three states.
- **SSI's Python SDKs leak secrets and block** (signer prints the 2FA code, no HTTP timeouts, a
  shared headers dict) — the reason for our own client; they remain the source for protocol details
  the guide omits.

## Lessons

- **On this feed, count seconds or episodes, never updates.** ~40 book snapshots a second put any
  "updates" measure out by two orders of magnitude (17,468 lulls found where there were ~300).
- **A fixed target plus a time cap and no stop always stacks the losers at the cap**; moving the
  cap moves the pile (300 s for the previous team, 120 s for us). A stop is the one parameter that
  changes the shape.
- **A stop tighter than the round-trip friction is not a stop.** At 19 contracts friction is
  0.3–0.5 point, so a 0.3 stop fires on entry (win rate 2%); swept at one contract, every stop
  tighter than the target was worse than none, and only 2.5–3× the target paid.
- **Below the cost, winning trades still lose**: a ladder stepping down to +0.2 filled every time
  and returned less than the round trip.
- **Judge a filter by separation, not win rate.** Win rate mixes entry, exit ladder, queue model and
  fee; separation (forward move of kept vs rejected, both columns printed) does not. Build that
  instrument first — the sixfold improvement had 53% win rate where the old gate had 68%.
- **A component that never varies is a broken measurement, not a weak signal.** A unit-free formula
  fed raw contract counts read 1.00 at 100% of moments and shifted every result equally, so nothing
  downstream looked wrong. Print every input's distribution before fitting anything.
- **An instrument that reads "healthy" while blind is worse than one that reads broken.** The first
  subscribe of a morning replays the previous session's close; taken as the volume baseline it left
  gap detection unable to fire all day while reporting zero gaps. Scope every counter to the
  boundary the vendor does not announce.
- **A plausible summary of the right document is still not the document.** A web summary said the
  last trading day is the third Tuesday; SSI's sheet says Thursday (verified 2026-09-16, mirrored
  in `docs/reference/vn30f-contract-spec.md`).
- **Some numbers in a spec sheet are not constants**: the printed 10% margin ratio is set by VSD and
  revised, so margin, fees and limits are read at runtime; only multiplier, tick and expiry rule are
  fixed.
- **A reason for rejecting a dependency expires quietly.** The gevent objection to SSI's SDK had
  been false for years when it was written down; the decision stands on other grounds. Read the
  vendor's changelog before recording why a dependency is out.
- **A test that has never failed has not been shown to work** ([[engineering-rules]] #1). Every
  safety rule was broken on purpose once; four were caught by exactly one test. In Python clear
  `__pycache__` first — a same-length patch in the same second leaves stale bytecode in place.
- **An under-documented vendor API is documented by its SDK, which must be audited before it is
  trusted.** The guide omits the signing header, key format and hub names; the SDK has them and also
  prints the 2FA code. Payload models are confirmed against captured live messages, kept with
  provenance in `docs/reference/fastconnect-data.md` and `fastconnect-trading.md`.
