---
name: project-init
description: Khởi tạo dự án mới trên nền simon-platform. Hỏi serious hay thí nghiệm, hỏi stack (mặc định theo wiki default-stack), lệch → ADR, dựng khung + tạo trang wiki dự án. Use when user starts a new product/project, says "tạo dự án mới", "new project", "khởi tạo", "spike", "thử khả thi".
---

# Project init — nghi thức khởi tạo dự án

Không tự chọn thay Sơn — mọi bước HỎI đều bắt buộc. Mô hình nền: `wiki/entities/simon-platform`.

## Bước 0 — HỎI: serious hay thí nghiệm?

- **🚀 Serious (mặc định)** — dự án thật, theo đủ luật.
- **🧪 Thí nghiệm** — thử khả thi. Sống trong `~/exp/<tên>` hoặc repo prefix `exp-`.
  Nới: test không bắt buộc, commit thẳng, lệch stack không cần ADR, **không tạo trang wiki**
  (AGENTS.md §0 — Vùng thí nghiệm). KHÔNG nới an toàn: secrets qua env, không data khách,
  không commit `.env`. Kết thúc bằng phán quyết: PROMOTE (→ dời ra `~/Documents/<tên>`,
  làm lại init như serious, lúc đó mới có trang wiki + ADR + test) hoặc XOÁ (không lưu vết).

## Bước 1 — HỎI STACK (chỉ hỏi tầng dự án thực dùng)

Mặc định theo `wiki/concepts/default-stack` — nêu rõ để Sơn bấm Enter là chốt:
Backend Python 3.11+/FastAPI/Pydantic v2 · Web React 18+Vite+Tailwind ·
Mobile React Native+TypeScript · Tests pytest/vitest (RN → Jest).

## Bước 2 — Lệch mặc định → ADR trước khi code *(bỏ qua nếu 🧪)*

Mỗi lựa chọn khác mặc định: tạo `docs/decisions/NNN-<slug>.md` trong repo dự án
(Context · Decision · Rationale · Consequences — tiếng Anh). Chưa có ADR chưa code phần lệch.

## Bước 3 — Dựng khung

1. Repo mới tại `~/Documents/<tên>` (🧪 thì `~/exp/<tên>`), git init.
2. Viết `CLAUDE.md` của dự án: **chỉ chứa thuần kỹ thuật riêng** (stack đã chốt, layout,
   lệnh build/test, luật riêng — chỉ được siết chặt hơn luật chung, không nới).
   Không chép luật hành vi/bối cảnh vào đây — global `~/.claude/CLAUDE.md` + wiki đã lo.
3. Layout: 1 tầng → phẳng ở gốc; ≥2 tầng → `backend/`, `frontend/` (xem default-stack).
4. Khung code chi tiết dựng SAU khi cd vào dự án — không thuộc bước init.

## Bước 4 — Tạo trang wiki dự án *(bỏ qua nếu 🧪)*

Tạo `~/Documents/simon-brain/wiki/projects/<tên>.md` theo template:

```markdown
---
title: <tên>
type: project
status: seed
updated: <ngày>
tags: []
sources: [<repo path>]
---

# <tên>

<Mục tiêu 1-2 câu>. Loại: <backend/frontend/fullstack/mobile>. Stack: <đã chốt, link [[default-stack]] nếu mặc định>.
Khởi tạo: <ngày>. Hiện trạng chi tiết: repo của dự án.

## Quyết định & lý do

*(chưa có)*
```

Cập nhật `wiki/index.md`, append 1 dòng `wiki/log.md`, commit simon-brain theo AGENTS.md §6.

## Bước 5 — Bàn giao

Tóm tắt: loại, stack đã chốt, ADR (nếu có), đường dẫn repo + trang wiki. Chờ Sơn duyệt
trước khi lên plan feature đầu tiên.
