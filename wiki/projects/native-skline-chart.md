---
title: native-skline-chart
type: project
status: active
updated: 2026-11-02
tags: [react-native, library, charts, mobile]
sources: [~/Documents/products/native-skline-chart/CLAUDE.md, docs/decisions]
read_when: project:native-skline-chart
---

# native-skline-chart — native K-line chart library

A candlestick (K-line) chart library for crypto apps: the API surface is React Native, the heavy
drawing lives in native iOS/Android. Independent product, not part of [[ok2ship]]. **Performance is
goal #1.** Still in the design stage. The repo holds everything else: `~/Documents/products/native-skline-chart`
(`CLAUDE.md`, `HANDOFF.md`, `docs/decisions/`).

## Decisions

The output of `scripts/compile-project.sh native-skline-chart`, from the repo's ADRs; never composed by hand.

<!-- adr-list:start -->
- **ADR 001** (proposed): Jest with the `react-native` preset for the JS/TS layer, XCTest and JUnit for native logic; rejected: vitest, which chokes on React Native's untranspiled Flow source.
- **ADR 002** (proposed): Fabric only, React Native 0.76 at least, with the codegen spec as the single source of props and events; rejected: a Paper fallback or an interop shim.
- **ADR 003** (proposed): Typed props for state that changes rarely, imperative Fabric commands for realtime ticks; rejected: re-sending one JSON-string prop on every tick.
- **ADR 004** (proposed): MA, BOLL, MACD, KDJ, RSI and WR computed natively and incrementally, JS sends raw OHLCV and parameters only; rejected: computing them in JS.
- **ADR 005** (proposed): Port the drawing and gesture layer from `native-kline-view`, keeping every attribution line, and write the Fabric bridge from scratch; rejected: rewriting the renderer.
<!-- adr-list:end -->
