---
title: Stack mặc định
type: concept
status: stable
updated: 2026-09-07
tags: [stack, backend, frontend, mobile]
sources: [ai-company/CLAUDE.md (Standard tech stack), native-skline-chart/docs/decisions/001-jest-over-vitest.md]
---

# Stack mặc định

Chọn stack cho dự án mới: mặc định là bảng dưới. **Lệch mặc định → ADR trong repo sản phẩm
TRƯỚC khi code** (AGENTS.md §3). Khởi tạo dự án luôn HỎI Sơn chọn, không tự quyết — quy trình ở skill `project-init`.

| Tầng | Mặc định | Ghi chú |
|---|---|---|
| Backend | Python 3.11+ / FastAPI / Pydantic v2 | NestJS chỉ cho dự án thuần TS, không AI/data. Pydantic model cho mọi thứ qua boundary |
| Web | React 18 + Vite + Tailwind | **Không router/state library cho tới khi thật cần** — useState/useReducer trước |
| Mobile | React Native + TypeScript | Test runner là **Jest**, không vitest (RN preset, hệ sinh thái — ADR 001 của [[native-skline-chart]]) |
| Tests | pytest (BE) / vitest (web) | Mọi feature kèm test ở dự án serious |
| Đóng gói / CI | Docker + docker-compose (local) + CI lint+test mỗi PR | Không secret trong image/CI |

## Layout repo

- 1 tầng (chỉ backend HOẶC chỉ frontend) → code phẳng ở gốc repo.
- ≥2 tầng (full-stack) → mỗi tầng một thư mục con `backend/`, `frontend/`.

## Gotcha đã trả giá

- **Hash mật khẩu: `pwdlib[argon2]`, KHÔNG dùng passlib** — passlib kẹt lỗi với bcrypt 4.x.
- Token hash khác mật khẩu hash có chủ đích: argon2id cho password (chậm cố ý),
  SHA-256 cho token (cần tra cứu nhanh, thường xuyên) — xem [[ok2ship-ai]].
