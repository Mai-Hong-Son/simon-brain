---
title: Luật kỹ thuật bất di bất dịch
type: concept
status: stable
updated: 2026-09-07
tags: [engineering, rules, security]
sources: [ai-company/CLAUDE.md (Hiến pháp v1, mục Non-negotiable engineering principles)]
---

# Luật kỹ thuật bất di bất dịch

Áp cho **mọi** dự án, mọi session. Chưng cất từ Hiến pháp ai-company (xem [[ai-company]]).

1. **Không tin output AI mà không kiểm chứng độc lập** — đối chiếu ground truth, cross-check,
   metadata hệ thống. Đây là luật số 1, mọi luật khác xếp sau.
2. **Secrets qua env var** — không hardcode, không đưa vào image/CI file, `.env` không bao giờ commit.
3. **Data khách hàng không rời môi trường được duyệt** — và không bao giờ đụng AI service free-tier.
4. **So sánh float dùng tolerance, không dùng `==`** — mỗi chỗ so sánh phải có comment 1 dòng nói
   RÕ nguồn sai số cụ thể (tổng tích lũy, float32 vs float64, round-trip tọa độ, đổi đơn vị) và
   lý do chọn epsilon đó. Tolerance không lý do = con số ma không review được.
5. **Mọi LLM/VLM call trong production**: temperature 0 (trừ khi có ADR nói khác), strip markdown
   fences trước khi parse, validate schema bằng Pydantic/Zod.
6. **Quyết định kiến trúc đáng kể → viết ADR** trong repo sản phẩm (`docs/decisions/`) —
   context, decision, rationale, consequences. Wiki chỉ giữ tóm tắt + lý do + phương án đã loại (AGENTS.md §3).
7. **Uncertainty rule**: logic không rõ — nhất là tích hợp ngoài (auth, payment, SDK bên thứ ba,
   webhook, native module, hành vi prompt LLM) — DỪNG và hỏi Sơn trước khi đổi.
   Không bao giờ âm thầm viết lại code mình chưa hiểu trọn.
8. **UI theo mockup: verify bản RENDER, đừng chỉ đọc source** — render bằng Playwright, lấy giá trị
   computed thật (`getComputedStyle`, `getBoundingClientRect`), không xấp xỉ bằng default của framework.
   Bài học trả giá 5 vòng sửa — diễn biến đầy đủ ở [[ok2ship-ai]].

Ngôn ngữ: **mọi thứ commit vào repo là tiếng Anh** (code, comment, commit message, docs kỹ thuật);
**mọi thứ nói với Sơn là tiếng Việt**. Xem [[son]].
