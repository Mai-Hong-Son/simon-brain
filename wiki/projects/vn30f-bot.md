---
title: vn30f-bot
type: project
status: active
updated: 2026-09-28
tags: [trading, derivatives, python, ssi, dashboard]
sources: [~/Documents/products/vn30f-bot, https://guide.ssi.com.vn/ssi-products, https://github.com/SSI-Securities-Corporation/python-fctrading, https://github.com/SSI-Securities-Corporation/python-fcdata]
---

# vn30f-bot

Automated trading bot for **VN30 index futures** on HNX's derivatives market, through the **SSI
FastConnect API**. **Built for a client who owns and operates it:** the client's account, keys, daily
OTP and rented server; Sơn builds the software, sets the server up, then hands root back and keeps no
access. Support works on exported data — the owner sends a bundle, Sơn replays it locally — and
releases are pulled by the client's host and installed only after the owner approves them. Sơn
develops on his own SSI account and never on a client's. On a delivered system the account data is
customer data ([[engineering-rules]] #3). Three surfaces: the bot — a long-lived process with no web
framework — a **read-only dashboard** for watching, and a small **operator console** for the nine
things an owner may do. Stack: Python 3.12 + Pydantic v2 + pytest, plus the default web tier — see
[[default-stack]]. Initialized: 2026-09-16.

How the pieces fit together, where each kind of file lives, and how it starts itself: [[vn30f-bot-architecture]].

## Decisions & rationale

- **No web framework for the bot** (ADR 001). The bot is event-driven and single-instance: work
  arrives on push streams, and the process holds live positions. A web framework would serve no
  caller and would invite multi-worker deployment, which for one trading account means duplicate
  orders. Pydantic v2 and pytest are kept from the default stack unchanged. FastAPI now serves the
  dashboard exactly as this ADR anticipated: a separate process that reads the state store.
- **The dashboard is read-only and blind to the credentials.** Its API has no endpoint that changes
  trading state, its process holds no SSI key and never imports a broker adapter, so a compromised
  dashboard still cannot place an order. Two roles: a viewer sees market data only, the operator also
  sees orders, positions and logs — enforced by the API, since hiding a panel in the UI is not access
  control. Rejected: an order ticket in the viewing screen, convenient while watching the ladder but a
  write path in the web tier for the one action that spends money.
- **The write surface is a separate operator console** (ADR 006), because the owner does not use a
  terminal and the dashboard's read-only proof is worth keeping. It is its own process on its own
  origin, speaks to the bot over the same control socket the development CLI uses, and exposes a
  fixed list of nine commands — enter the OTP, start, stop, halt, flatten, set parameters, set
  limits, approve an update, set credentials. **The guards are asymmetric on purpose:** halting needs
  no confirmation and limits can be lowered at any time, while raising a limit waits for the market to
  close and asks for the password again. The bot validates every command and answers accepted or
  refused with a reason, so a console bug cannot become a trading bug. There is no manual order entry:
  the bot trades, and an owner who wants to trade by hand uses SSI's own app. Login is password plus a
  one-time code from a phone, with a device remembered for thirty days. Rejected: write routes bolted
  onto the dashboard; a Telegram bot as the control surface, since the OTP and the keys would pass
  through a third-party chat service and a hijacked account would control the bot — Telegram stays
  acceptable for outbound alerts carrying no secrets.
- **2FA is OTP on any delivered system, entered once per trading day.** FastConnect keeps the code
  for the life of the write token (8 hours), which outlasts a trading session, so one human entry each
  morning covers the day. **PIN is allowed only while developing on Sơn's own account**, and only with
  the small self-imposed limits in force and on a host with a login password and an encrypted disk: it
  buys unattended restarts during development, and SSI has announced PIN support is ending. The code
  source is a port with two adapters, so the switch is one line of configuration. Rejected: PIN on a
  delivered system — it sits in the environment, so a compromised host can trade.
- **Accountability by construction: a request log.** Every order event carries the config version it
  ran under, every config version references the request that authorized it, and a request record
  holds who asked, through which channel, the evidence (screenshot file name + SHA-256), any risk
  warning sent back, and the lifecycle. It is append-only, and the live runner refuses a config
  version with no request record. It binds from the first automated strategy; manual orders are
  traced through the operational log. Rejected: screenshots inside the repo behind `.gitignore` —
  git is not the only way out of a repo, a Docker build context or a deploy rsync takes the folder
  along. They stay outside the repo, on Sơn's machine, referenced by name and hash.
- **Self-imposed trading limits enforced by the bot:** contracts per order, open position, loss per
  day, orders per day; hitting the loss or order-count limit halts trading for the rest of the day.
  They are separate from SSI's own limits, which are read at runtime, and their numbers live in
  config rather than in code.
- **The entry is a score plus a confirmation, not a set of conditions** (ADR 008). The client's
  document reads as a list of things that are either true or false, and built that way it entered 93%
  of its own signals — a condition cannot rank two moments that both meet it, so it can only be
  loosened or tightened. Each of their ideas is now a **0–1 component of a score out of 100**, and
  nothing is bought on the score alone: the price must first move a tick in our favour, and at that
  moment the matched column is read again. The second step is taken wholesale from the previous
  implementation of this product, whose own screen worked that way and which entered 7–17% of its
  signals; measured against a recorded day, the confirmation is what earns the improvement, not the
  waiting — moments whose price moved our way but whose aggressor had gone quiet were
  indistinguishable from no filter at all. Weights start equal on purpose, since fitting them on one
  session's hundred-odd trades would fit the session. Rejected: hard conditions, for the reason
  above; and deeper climb thresholds, which measurement showed select **worse**-than-average moments
  because by then the move has already been paid for.
- **The simulated broker fills pessimistically and states its assumptions** (ADR 007). Since there is
  no sandbox, every number about this strategy comes out of that simulator, so its errors are pointed
  in one direction: later and worse than reality. A resting order joins **behind** the volume already
  displayed at its price, and that queue shrinks only when trades print there — cancellations ahead of
  us are invisible in an aggregated feed, so they are not credited. Marketable orders are matched
  against the book as it stands after a configurable latency, and the exchange's own refusals are
  modelled so rejection handling is exercised before production. Every result is reported with the
  assumptions that produced it, and gross sits next to net, because at a 0.6-point target the fee
  schedule decides the sign. Rejected: filling on touch, which turns a passive exit into fiction;
  probabilistic fills, which hide the assumption inside a coin flip.

## Constraints that shape the build

- **SSI FastConnect has no sandbox — PROD only.** Confirmed 2026-09-16 from SSI's published
  integration environments: FastConnect Data lists one host, FastConnect Trading lists one host,
  both production. Consequence: the project must own a simulated broker, because there is no
  vendor-provided place to test an order path. This is the single biggest driver of the
  architecture (ports/adapters so one strategy runs against backtest, paper, or live).
- **PIN authentication is being retired.** SSI's guide recommends SMS OTP or SmartOTP and states
  PIN support will end. An OTP cannot be minted by a program, but the "save code" option makes one
  human entry cover the token's 8 hours. Consequence: nothing may assume unattended startup — a bot
  that restarts mid-session needs a person.
- **The derivative's instrument code is the KRX-style one**, not the dated `VN30Fyymm` of SSI's own
  contract sheet: the October 2026 contract trades as `41I1GA000`, while `VN30F1M` is a rolling alias
  meaning "nearest month" and shifts to the next contract after expiry. Verified 2026-09-21 on Sơn's
  own iBoard order ticket, which also prints the expiry 15/10/2026 — the third Thursday, confirming
  the contract sheet's expiry rule. Consequence: orders carry the dated code, recordings are keyed by
  it, and a bot must ask which contract is the front month rather than hard-code one.
- **A recording cannot be recreated**, since nobody sells VN30F order-book history. The data
  directory is therefore resolved from the project itself rather than from whichever directory a
  command was run in, and never lives in `/tmp`, which the machine empties on reboot. The client's own
  documents stay in a separate folder outside the repository.
- **Credentials are shown once** at creation on SSI iBoard: ConsumerID, ConsumerSecret, PrivateKey.
  The PrivateKey is a base64-encoded XML `<RSAKeyValue>`, not PEM. Money-moving requests carry an
  `X-Signature` header holding the RSA-SHA256 signature of the exact JSON body, hex-encoded.
- **The market-data stream cannot be replayed:** whole-second timestamps, no sequence number, no
  resume point. A disconnect loses that data permanently, and `TotalVol` continuity is the only gap
  check available. The trading stream is the opposite — `NotifyID` resumes from any point of the day.
- **An HTTP 200 on an order is not an exchange acknowledgement**, only SSI accepting the request.
  The exchange's answer arrives later on the trading stream, so "sent", "accepted by SSI" and
  "acknowledged by the exchange" are three distinct states.
- **SSI's Python SDKs leak secrets and block.** Their signer prints the payload — 2FA code included
  — to stdout, HTTP calls carry no timeout, and one mutable headers dict leaks the signature into
  later requests. These facts, not the old gevent objection, are what the FastConnect-client ADR
  weighs. The SDKs remain the only source for protocol details the guide omits.

## Lessons

- **On a feed this fast, never count updates — count seconds, or count episodes.** VN30F sends
  about forty book snapshots a second, so anything measured in "updates" is out by two orders of
  magnitude: a lull detector found 17,468 lulls in one session, a stall condition called half a
  second a stall, and an opportunity counter reported 1,042 chances where there were 122. The same
  mistake three times in one day, each time because the unit looked harmless.
- **A fixed target plus a time limit and no stop always produces the same shape:** winners spread
  across the clock, losers stacked at the cap. Moving the cap moves the pile — the previous team's
  sat at 300 seconds, ours at 120. It is arithmetic, not misfortune, and it is why a stop-loss is
  the one parameter that can change the outcome.
- **A stop tighter than the round-trip friction is not a stop.** Spread plus the impact of one's own
  size is 0.3–0.5 point at 19 contracts here, so a 0.3-point stop fires on entry rather than on a
  move: the win rate collapsed to 2% while the trade count rose tenfold. The other half of the same
  finding: swept at one contract, where a stop gets its fairest hearing, **every level tighter than
  the target was monotonically worse than no stop at all** — at a 0.6-point target anything close
  enough to protect the trade sits inside the noise. Only a stop wide enough to catch collapses
  rather than noise paid for itself, and that turned out to be 2.5–3× the target, which is nothing
  like the number that seems natural.
- **Below the cost, winning trades still lose.** A take-profit ladder stepping down to +0.2 filled
  every time and returned less than the round trip cost. Both teams' data show the same line.
- **Win rate is the wrong instrument, and it points the wrong way.** It mixes the entry with the exit
  ladder, the queue model and the fee, so a better filter and a better ladder are indistinguishable
  in it. Judge a filter by **separation** instead — the forward price move of the moments it keeps
  against the moments it rejects, measured from what the size actually costs to buy and sell — and
  print *both* columns, because a filter that keeps only good moments by keeping almost none looks
  identical to a good one when you see only what it kept. **Build that instrument before the thing it
  measures.** The demonstration: the configuration that improved the session sixfold had a win rate
  of 53% where the one it replaced had 68%.
- **A unit-free formula fed unit-carrying input saturates silently.** A continuity accumulator
  designed to compare against the displayed book was handed raw contract counts; its total reached
  88,669 against a depth of 12–138, so its score component read 1.00 at 100% of signal moments, its
  mirror on the other side never fired once, and the giveback rule that was supposed to break the run
  could never reach 35% of a peak that grew all day. **A component that never varies is a broken
  measurement, not a weak signal** — and because it shifts every result by the same amount, nothing
  downstream looks wrong. Print the distribution of every input before fitting anything to it.
- **An instrument that reads "healthy" while blind is worse than one that reads broken.** Subscribing
  to this feed replays each channel's last message, which on the first subscribe of a morning is the
  *previous* session's closing print. Taken as the volume baseline it made the whole day's trades
  read as out of order, and — the part that mattered — left gap detection unable to fire for the
  entire session while reporting zero gaps. Any counter that resets on a boundary the vendor does not
  announce has to be scoped to that boundary explicitly. The recording itself was never at risk,
  because the raw log is written before anything is computed from it.

- **A plausible summary of the right document is still not the document.** A web-search summary of
  the VN30 futures contract specification reported the last trading day as the third *Tuesday*;
  SSI's own published contract sheet says the third *Thursday*. Every expiry date, rollover and
  settlement in this product turns on that one field. Verified 2026-09-16 against the primary
  source, which is now mirrored with its provenance in the repo at
  `docs/reference/vn30f-contract-spec.md`. This is [[engineering-rules]] #1 in its cheapest form:
  the cost of opening the source document was one fetch.
- **Some numbers in a spec sheet are not constants.** The same sheet prints a 10% initial margin
  ratio, but that ratio is set by VSD and revised over time. Margin, buying power, fees and
  position limits are read from the account API at runtime; only the contract's own geometry
  (multiplier, tick, expiry rule) is treated as fixed.
- **A reason for rejecting a dependency expires quietly.** The decision to write a thin FastConnect
  client rather than use SSI's SDK was recorded on the grounds that the SDK monkey-patches gevent
  and so cannot share a process with asyncio. Both SDKs dropped gevent in 2023, years before that
  was written down. The decision survives on other grounds; the reason did not. Read the vendor's
  changelog and current source before recording why a dependency is out — a stale reason is worse
  than none, because it stops anyone from re-examining the choice.
- **A test that has never failed has not been shown to work.** Every safety rule here — the tick
  tolerance, the money-per-tick constant, FIFO position accounting, the queue model, the daily
  limits, the read-only web tier — was broken on purpose once, to watch a test go red, then restored.
  Four of those breaks were caught by exactly one test, which is also how you learn which rule is
  thinly covered. One trap when doing this in Python: clear `__pycache__` first, because a patch of
  the same byte length applied within the same second leaves the old bytecode in place and the suite
  passes on code that is no longer there.
- **An under-documented vendor API is documented by its SDK — and that SDK has to be audited before
  it is trusted.** SSI's guide omits the signing header, the private key's format and the SignalR
  hub names; all three are plain in the official SDK source. That same source shows the signer
  printing a payload containing the 2FA code. Read the SDK to learn the protocol, then read it again
  for what not to copy. The guide also contradicts itself — two base URLs, `ContractMultiplier`
  typed as a date, `requestID` "exactly 8 digits" beside 7-digit examples — so payload models are
  confirmed against captured live messages rather than against the guide. What has been verified,
  with its provenance, lives in the repo: `docs/reference/fastconnect-data.md` and
  `docs/reference/fastconnect-trading.md`.
