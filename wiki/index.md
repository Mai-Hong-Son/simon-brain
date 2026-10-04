---
title: Index
type: hub
status: active
updated: 2026-10-01
---

# Index — simon-brain wiki

> Catalog of the whole wiki (AGENTS.md §4). One line per page: `- [[slug]] — one-sentence summary`.
> Updated on **every** ingest.

## Concepts

- [[engineering-rules]] — 8 non-negotiable engineering rules for every project; #1 includes "a check counts only once seen to fail and to pass".
- [[default-stack]] — default stack per tier, repo layout, deviation → ADR before code.
- [[approval-gates]] — size the process by size, human gates, git/PR conventions, review before Sơn from a fresh context, check that work landed by content.

## Entities

- [[son]] — expertise, preferred working style, 4 standards expected of agents (survey tools, cross-signals, model the object, add nothing that was not asked).
- [[mektec-desoft]] — OK2SHIP's client & vendor; GitLab/Rancher/Loki infra; the BA's RBAC terminology trap.
- [[simon-platform]] — the current foundation model: simon-brain + products/ + spikes/; the single-source-of-truth test; how a page gets read (`read_when`); why the ai-company model was dropped.

## Projects

- [[ok2ship]] — program hub: the BA's 5 requirements → which spike proved what → what the product consumes.
- [[ok2ship-ai]] — 🚀 product: three-repo topology; locked decisions through ADR 010 (results snapshot, Spec library, a Template without scope, a run with a scope); lessons grouped by BA deliverables, verification, backend, frontend, running it, reading reports.
- [[ok2ship-anomaly]] — 🧪 spike, req #3: golden/PatchCore; curation, seeding, calibrated-threshold lessons.
- [[ok2ship-report-parser]] — 🧪 spike, reqs #1/2/4/5: label-keyed parsing, drifting report format, never drop sheets.
- [[void-guard-xval]] — 🧪 spike, X-ray void%: ROI-box denominator, cyan-outline approach, hybrid criterion; doubles as backend course.
- [[native-skline-chart]] — native K-line RN library: 5 ADRs (Fabric-only, command fast path, native indicators, licensed port).
- [[vn30f-bot]] — 🚀 product a client owns and operates: VN30 futures bot on SSI FastConnect; PROD-only so the simulator fills pessimistically, read-only dashboard plus a nine-command operator console, one OTP per trading day, handover with root returned; entry is a scored setup plus a confirmation, judged by separation rather than win rate.
- [[vn30f-bot-architecture]] — how that bot is built: separate processes with a wall between money and screen, four layers inside the bot, what lives outside the repo and why, and why its recorder starts by hand.
