---
title: Mektec & Desoft
type: entity
status: active
updated: 2026-10-09
tags: [client, vendor, ok2ship]
sources: [~/Documents/products/ok2ship-ai/CLAUDE.md, ~/Documents/products/ok2ship-ai/docs/decisions/002, 004]
read_when: project:ok2ship-ai
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

### Their Loki is multi-tenant, one tenant per namespace

Grafana Alloy tags every log line with `tenant = namespace` (`stage.tenant` in the `alloy`
ConfigMap) and Loki runs with `auth_enabled: true`, so each namespace is a **separate tenant**.
Grafana's Loki datasources carry a fixed `X-Scope-OrgID` listing the tenants an org may read. A
namespace created after that list was written is **invisible in Grafana while its logs arrive in
Loki normally** — the tell is a Label browser where other namespaces appear and yours does not,
with the collector config showing no namespace filter at all. Adding a namespace means adding it
to that list (in the `grafana` Helm release's values, since the ConfigMap is Helm-managed) and
restarting Grafana. Requesting it beats editing by hand: one ConfigMap serves every org on the
cluster, and a hand edit is erased by the next `helm upgrade`.

### Getting at the cluster from a laptop

- **Rancher's "Download KubeConfig" embeds a stale internal CA** (`dynamiclistener-ca`, from the
  2025-10 install) while `rancher-lake.desoft.vn` now serves a Let's Encrypt certificate, so
  `kubectl` fails with `x509: certificate signed by unknown authority`. Delete the
  `certificate-authority-data` line and kubectl trusts the system store, which has Let's Encrypt —
  nothing is skipped, and CI is unaffected (it uses its own ServiceAccount kubeconfig). Every new
  developer who downloads the file will hit this (measured 2026-10-01).
- Postgres is reachable only through the cluster: `kubectl -n ok2ship port-forward
  ok2ship-postgres-0 5434:5432`, credentials in the `ok2ship-postgres` Secret — read-only in the
  client, since that account is the app's own superuser and a hand edit leaves no `audit_log`.
- **MinIO `pre-prod` is shared with `pre-nwris` and sits on one Longhorn replica.** After node2's
  fault (2026-10-03) it served 503s from a read-only, I/O-erroring mount while Longhorn said
  "healthy" — check with `ls` and `/proc/mounts` inside the pod. Fixed by a Longhorn snapshot, then
  scaling the deployment 0 → 1 (2026-10-04); a restart is Desoft's call, it touches `pre-nwris`.
- **GitLab merge requests are created by push options, and a push-option value must be ONE line**
  — git refuses a value with a newline, and a retry without the description creates the MR with no
  body; the local `glab` token is `read_api` only, so a description cannot be added afterwards.

## ⚠️ Terminology trap when talking to the BA

The BA uses RBAC terms **inverted from industry standard**: their "role" = what the industry
calls `permissions`; their "role group" = industry `roles`. The schema uses standard terms —
**before any schema meeting, consult the translation table** in ok2ship-ai's
`docs/design/user-management.md`, or the two sides will talk past each other.

Requirements channel: the BA sends SRS/Excel files via Downloads; requirements can change after
a design is locked (happened with RBAC v1→v3) — designs should keep the retreat path cheap. They
also change rules **in chat, ahead of the mockup**: on 2026-10-09 the one-Active-Rev rule and the
derived row order were withdrawn by chat while the live mockup still carried both — quote the
chat in the ADR amendment. And the live mockup moves without notice: diff the page per screen
before building (Spec Management dropped the 22 check items two days after we measured it; seen
15 days later, [[ok2ship-ai]] ADR 008).
