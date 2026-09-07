---
title: native-skline-chart
type: project
status: active
updated: 2026-09-07
tags: [react-native, library, charts, mobile]
sources: [~/Documents/native-skline-chart/CLAUDE.md, docs/decisions/001-005]
---

# native-skline-chart — native K-line chart library

A candlestick (K-line) chart library for crypto apps: the API surface is React Native, the heavy
drawing lives in native iOS/Android. Independent product, not part of [[ok2ship]].
**Performance is goal #1**: never push a heavy draw loop across the JS bridge every frame.
Still in the design/ADR stage — no code yet.

## Architecture decisions (5 ADRs in the repo's `docs/decisions/` — this is the summary + rationale)

1. **Jest over vitest** for the JS/TS layer — RN ships its own Jest preset and the whole RN
   ecosystem is built around Jest; vitest chokes on RN's untranspiled Flow-typed source.
   (Source of the exception noted in [[default-stack]].)
2. **Fabric-only, no Paper fallback** — the reference library `native-kline-view` advertises
   "Fabric support" but inspection shows a pure Paper component running through the interop layer
   (no codegenConfig, no spec file). This product needs Fabric's real command API for the fast path.
3. **Typed props + a command-based realtime fast path** — the old model serialized the ENTIRE
   candle array + indicators into a JSON string across the bridge on every tick: O(n) work for an
   O(1) change, on the JS thread, at tick frequency. Ticks go through an imperative command
   instead of re-sending props.
4. **Indicators (MA/BOLL/MACD/KDJ/RSI/WR) computed natively, incrementally** — JS sends raw OHLCV
   + parameters only; computing in JS bloats the payload and blocks the same thread handling touch.
5. **Port the renderer + gesture layer from `native-kline-view`** instead of rewriting — the
   pan/zoom/crosshair geometry is expensive, low-novelty work. ⚠️ Licensing: root Apache-2.0 but
   podspecs claim MIT (inconsistent), no NOTICE file, three authorship layers (tifezh/hjm/hublot) —
   **preserve every attribution line when porting** ([[engineering-rules]]: license obligations).

## Product-specific rules

- The uncertainty rule bites hardest at the bridge layer (Fabric/JSI, view manager, event
  emitter): not fully understood → ASK, don't change.
- The library takes data as input — it never calls an exchange API and embeds no keys/secrets.
