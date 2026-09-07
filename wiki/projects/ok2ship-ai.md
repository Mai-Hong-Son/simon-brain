---
title: ok2ship-ai
type: project
status: active
updated: 2026-09-07
tags: [ok2ship, product, fastapi, react]
sources: [ok2ship-ai/CLAUDE.md, HANDOFF.md, docs/PROGRESS.md, docs/decisions/001-004]
---

# ok2ship-ai — sản phẩm OK2SHIP AI

Backend + web dashboard cho chương trình [[ok2ship]]. Sản phẩm 🚀 serious: test bắt buộc,
branch per feature, review trước merge. Stack đúng [[default-stack]] mặc định (không ADR lệch).
**Hiện trạng chi tiết + việc đang mở: đọc `HANDOFF.md` trong repo — wiki không chép.**

## ⚠️ Topology 3 repo — đọc trước khi đụng git

Một thư mục nhưng **ba repo git độc lập** (ADR 002, lý do: backend/frontend là deliverable
cho khách nằm trên GitLab của [[mektec-desoft]]; docs planning là đồ nội bộ nằm GitHub cá nhân):
1. Gốc — planning/design docs (GitHub cá nhân); gitignore trọn `backend/` `frontend/`.
2. `backend/` — FastAPI (GitLab mektec).
3. `frontend/` — React (GitLab mektec).

Không repo nào auto-sync với repo nào; push từng cái, chỉ khi được yêu cầu.

## Quyết định đã khóa (tóm tắt — full ở `docs/design/user-management.md` trong repo)

- **Full RBAC**, 1 user nhiều role; naming theo chuẩn ngành, KHÔNG theo từ của BA
  (bẫy thuật ngữ — xem [[mektec-desoft]]). Đã đi 3 vòng v1→v2→v3 vì BA đổi yêu cầu.
- Không tách vai trò duyệt riêng (người upload = người duyệt) — `audit_log` là lưới an toàn chính.
- Visibility báo cáo theo role, không theo Line; Line cần lại → thêm role (rẻ), không dựng scope table sớm.
- 4 trạng thái account (Create→Active→Locked→Inactive), **không bao giờ hard delete** (audit trail).
- Force-logout gần-tức-thời là yêu cầu SRS → access token ngắn hạn hoặc Redis check,
  không được mặc định JWT dài hạn.
- argon2id cho password, SHA-256 cho token (khác nhau có chủ đích); refresh token trong httpOnly cookie.
- Monitoring: **Loki của cluster, không Sentry** (ADR 004 supersede 003 cùng ngày —
  cluster đã có Loki+Grafana bên trong ranh giới data khách, đổi hẳn bài toán PII).

## Mốc & bài học

- Module 1 (User Management, WBS #5) **ký nhận hoàn thành 2026-08-29**, chạy production
  trên hạ tầng Desoft, deploy tự động qua GitLab CI/CD.
- **Bài học mockup-fidelity** (nguồn của [[engineering-rules]] #8): 5 vòng sửa UI liên tiếp
  đều do đọc source mockup thay vì render+đo — filter dài-dòng nuốt mất logo, CSS khai báo
  `width:46%` nhưng render thật shrink-to-fit vì div lồng trùng, xấp xỉ màu bằng
  indigo-600 thay vì đọc đúng `--ant-colorPrimary`.
- **Gotcha TS** *(ứng viên thăng hạng concept khi dự án TS khác đụng phải)*:
  root `tsconfig.json` dạng `files:[] + references` làm `tsc --noEmit` thành no-op im lặng —
  phải dùng `tsc -b` mới bắt lỗi thật.
- Email nên rời request path (BackgroundTasks) — SMTP sync từng làm mỗi create/edit user chậm hàng giây.
