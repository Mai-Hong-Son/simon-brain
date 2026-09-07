---
title: Simon Platform
type: entity
status: active
updated: 2026-09-07
tags: [platform, architecture, meta]
sources: [simon-brain-migration-brief.md (2026-09-07)]
---

# Simon Platform — mô hình nền tảng

Mô hình vận hành hiện hành (từ 09/2026), thay thế mô hình [[ai-company]].

## Kiến trúc

```
SIMON-BRAIN = NỀN TẢNG (repo này — chạy ngầm dưới mọi session, mọi máy, sync git)
├── wiki/      trí nhớ & tri thức chưng cất
├── agents/    kho năng lực (capability pool — không phải "đội ngũ"; mặc định solo agent)
├── skills/    quy trình đóng gói (symlink vào ~/.claude/skills qua setup.sh)
├── AGENTS.md  luật vận hành wiki
└── setup.sh   dựng lại nền trên máy mới

REPO SẢN PHẨM (ok2ship-ai, native-skline-chart, ...)
└── đứng trên nền tảng; chỉ chứa code + config kỹ thuật riêng của nó

~/exp/ = vùng thí nghiệm — mặc định KHÔNG ghi wiki, chết thì xoá
```

## Phép thử phân nhà (single source of truth)

| Loại thông tin | Nhà duy nhất |
|---|---|
| Luật hành vi agent + con trỏ tới wiki | `~/.claude/CLAUDE.md` (giữ mỏng) |
| Quyết định + lý do, bài học, tổng hợp xuyên dự án | `wiki/` |
| Hiện trạng code, lệnh build/test, convention kỹ thuật | repo sản phẩm |
| Diễn biến đang làm dở | session (bốc hơi) / HANDOFF.md của repo |

Chống drift: wiki ghi **hình dạng**, không chép giá trị tức thời (AGENTS.md §2).
Mâu thuẫn wiki↔repo: repo thắng hiện trạng, wiki thắng lịch sử quyết định.

## Nguyên tắc agent

Mặc định **solo agent** — một context làm trọn việc. Chỉ spawn agent phụ khi cần
**cô lập context thật** (review phản biện cần mắt chưa thấy code — xem [[approval-gates]]),
không spawn để đóng vai chức danh.
