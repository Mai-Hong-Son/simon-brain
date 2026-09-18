---
title: vn30f-bot
type: project
status: active
updated: 2026-09-18
tags: [trading, derivatives, python, ssi, dashboard]
sources: [~/Documents/products/vn30f-bot, https://guide.ssi.com.vn/ssi-products, https://github.com/SSI-Securities-Corporation/python-fctrading, https://github.com/SSI-Securities-Corporation/python-fcdata]
---

# vn30f-bot

Automated trading bot for **VN30 index futures** on HNX's derivatives market, through the **SSI
FastConnect API**. **Built for a client:** the client sets the requirements, Sơn implements and runs
them. Development trades Sơn's own SSI account on Sơn's machine; whenever the account in use is the
client's, its credentials and balances are customer data ([[engineering-rules]] #3). Two tiers now:
the bot — a long-lived process with no web framework — and a **read-only web dashboard**
(FastAPI + React). Stack: Python 3.12 + Pydantic v2 + pytest, plus the default web tier — see
[[default-stack]]. Initialized: 2026-09-16.

## Decisions & rationale

- **No web framework for the bot** (ADR 001). The bot is event-driven and single-instance: work
  arrives on push streams, and the process holds live positions. A web framework would serve no
  caller and would invite multi-worker deployment, which for one trading account means duplicate
  orders. Pydantic v2 and pytest are kept from the default stack unchanged. FastAPI now serves the
  dashboard exactly as this ADR anticipated: a separate process that reads the state store.
- **The dashboard is read-only and blind to the credentials.** Its API has no endpoint that changes
  trading state, its process holds no SSI key and never imports a broker adapter, so a compromised
  dashboard still cannot place an order. Two roles: the client sees market data only, Sơn also sees
  the operational and request logs — enforced by the API, since hiding a panel in the UI is not
  access control. Rejected: an order ticket in the operator view, convenient while watching the
  ladder but a write path in the web tier for the one action that spends money. Manual orders go
  through an operator CLI that hands them to the bot, so a single process holds the credentials and
  the position.
- **2FA is OTP, entered once per trading day.** FastConnect keeps the code for the life of the write
  token (8 hours), which outlasts a trading session, so one human entry each morning covers the day.
  Rejected: PIN — SSI's guide says PIN support is ending, and a PIN sitting in a server's
  environment means a compromised host can trade.
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
- **An under-documented vendor API is documented by its SDK — and that SDK has to be audited before
  it is trusted.** SSI's guide omits the signing header, the private key's format and the SignalR
  hub names; all three are plain in the official SDK source. That same source shows the signer
  printing a payload containing the 2FA code. Read the SDK to learn the protocol, then read it again
  for what not to copy. The guide also contradicts itself — two base URLs, `ContractMultiplier`
  typed as a date, `requestID` "exactly 8 digits" beside 7-digit examples — so payload models are
  confirmed against captured live messages rather than against the guide. What has been verified,
  with its provenance, lives in the repo: `docs/reference/fastconnect-data.md` and
  `docs/reference/fastconnect-trading.md`.
