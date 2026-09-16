---
title: vn30f-bot
type: project
status: seed
updated: 2026-09-16
tags: [trading, derivatives, python, ssi]
sources: [~/Documents/products/vn30f-bot, https://guide.ssi.com.vn/ssi-products]
---

# vn30f-bot

Automated trading bot for **VN30 index futures** on HNX's derivatives market, running against
Sơn's own SSI account through the **SSI FastConnect API**. Type: backend (a long-lived process,
no web tier). Stack: Python 3.12 + Pydantic v2 + pytest, no web framework — see [[default-stack]]
for what that deviates from. Initialized: 2026-09-16. Current state: the project repo.

## Decisions & rationale

- **No web framework** (ADR 001). The bot is event-driven and single-instance: work arrives on
  push streams, and the process holds live positions. A web framework would serve no caller and
  would invite multi-worker deployment, which for one trading account means duplicate orders.
  Pydantic v2 and pytest are kept from the default stack unchanged. FastAPI is the anticipated
  choice if a monitoring surface is later wanted, as a separate process reading the state store.

## Constraints that shape the build

- **SSI FastConnect has no sandbox — PROD only.** Confirmed 2026-09-16 from SSI's published
  integration environments: FastConnect Data lists one host, FastConnect Trading lists one host,
  both production. Consequence: the project must own a simulated broker, because there is no
  vendor-provided place to test an order path. This is the single biggest driver of the
  architecture (ports/adapters so one strategy runs against backtest, paper, or live).
- **2FA must be PIN, not OTP.** FastConnect supports both; OTP cannot be automated.
- **Credentials are shown once** at creation on SSI iBoard, and are ConsumerID + ConsumerSecret +
  PrivateKey, with requests signed RSA-SHA256.
- **SSI's Python SDK cannot share a process with asyncio.** Its streaming sample monkey-patches
  gevent at import. The SDK stays a reference for payload shapes, not a dependency.

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
