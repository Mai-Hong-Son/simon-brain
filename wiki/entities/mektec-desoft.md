---
title: Mektec & Desoft
type: entity
status: active
updated: 2026-09-07
tags: [client, vendor, ok2ship]
sources: [ok2ship-ai/CLAUDE.md, ok2ship-ai/docs/decisions/002, 004]
---

# Mektec & Desoft

Khách hàng và đối tác của chương trình [[ok2ship]].

## Mektec Vietnam — khách hàng

- Nhà máy sản xuất FPC, dùng hệ QA report (Excel + ảnh X-ray/cross-section).
- **Data nhà máy là data khách hàng**: không rời môi trường được duyệt, không đụng AI free-tier,
  không commit vào repo ([[engineering-rules]] #3).

## Desoft — vendor đối tác

- Vendor giao sản phẩm cùng, ra SRS/WBS mà [[ok2ship-ai]] bám theo.
- Hạ tầng của họ: **GitLab** (repo deliverable nằm ở `gitlab.com/mektec/`) + **Rancher cluster**
  `rancher-lake.desoft.vn` (namespace `ok2ship`), có sẵn **Loki + Grafana** làm logging tập trung —
  lý do monitoring chọn Loki thay Sentry (ADR 004 của ok2ship-ai).
- CI/CD GitLab build + deploy tự động khi push `main` (Le Bui dựng).

## ⚠️ Bẫy thuật ngữ khi làm việc với BA

BA dùng từ RBAC **ngược chuẩn ngành**: họ nói "role" = cái ngành gọi `permissions`,
họ nói "role group" = cái ngành gọi `roles`. Schema dùng tên chuẩn ngành — **trước khi họp
về schema phải tra bảng đối chiếu** trong `docs/design/user-management.md` của repo ok2ship-ai,
kẻo hai bên nói chuyện trượt nhau.

Kênh yêu cầu: BA gửi file SRS/Excel qua Downloads; requirement có thể đổi sau khi đã chốt design
(đã xảy ra với RBAC v1→v3) — thiết kế nên để đường lùi rẻ.
