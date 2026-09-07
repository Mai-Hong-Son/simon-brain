---
title: Mektec & Desoft
type: entity
status: active
updated: 2026-09-07
tags: [client, vendor, ok2ship]
sources: [~/Documents/ok2ship-ai/CLAUDE.md, ~/Documents/ok2ship-ai/docs/decisions/002, 004]
---

# Mektec & Desoft

Client and partner of the [[ok2ship]] program.

## Mektec Vietnam — the client

- FPC factory, runs a QA-report system (Excel + X-ray/cross-section images).
- **Factory data is customer data**: never leaves approved environments, never touches free-tier
  AI, never gets committed ([[engineering-rules]] #3).

## Desoft — the partner vendor

- Vendor co-delivering the product; issues the SRS/WBS that [[ok2ship-ai]] follows.
- Their infrastructure: **GitLab** (deliverable repos under `gitlab.com/mektec/`) + a **Rancher
  cluster** `rancher-lake.desoft.vn` (namespace `ok2ship`) that already runs **Loki + Grafana**
  for centralized logging — the reason monitoring chose Loki over Sentry (ok2ship-ai ADR 004).
- GitLab CI/CD builds + deploys automatically on pushes to `main` (set up by Le Bui).

## ⚠️ Terminology trap when talking to the BA

The BA uses RBAC terms **inverted from industry standard**: their "role" = what the industry
calls `permissions`; their "role group" = industry `roles`. The schema uses standard terms —
**before any schema meeting, consult the translation table** in ok2ship-ai's
`docs/design/user-management.md`, or the two sides will talk past each other.

Requirements channel: the BA sends SRS/Excel files via Downloads; requirements can change after
a design is locked (happened with RBAC v1→v3) — designs should keep the retreat path cheap.
