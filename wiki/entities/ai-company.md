---
title: ai-company (lịch sử)
type: entity
status: stable
updated: 2026-09-07
tags: [history, architecture, meta]
sources: [ai-company/CLAUDE.md, ai-company/.claude/]
---

# ai-company — mô hình đã hấp thụ (07/2026 – 09/2026)

Mô hình vận hành trước [[simon-platform]]. **Đã được hấp thụ vào simon-brain 09/2026** —
trang này giữ lại vì lý do từng chọn rồi từng bỏ một mô hình chính là loại tri thức wiki sinh ra để giữ.

## Nó là gì

Một repo trung tâm (`ai-company`, bootstrap 2026-07-13) đóng vai "công ty":
- **Hiến pháp** (CLAUDE.md hub): luật kỹ thuật, workflow Group/Flow theo cỡ task, cơ chế debate,
  nghi thức 🚀 Serious vs 🧪 Spike, luật ngôn ngữ Anh-repo/Việt-human.
- **6 native agents** đóng vai đội ngũ: orchestrator, dev-backend, dev-frontend, dev-mobile, devops, qa-reviewer.
- **3 skills**: git-workflow, project-init, project-retro.
- `products/` (gitignored) chứa các repo sản phẩm độc lập.

## Vì sao bỏ

1. **Bộ máy điều phối nặng hơn thứ nó điều phối** — orchestrator 3.6KB điều phối 4 agent dev
   tổng 2.3KB; mỗi "agent" thực chất là vài gạch đầu dòng về stack, không đáng một context riêng.
2. **Subagent tồn tại để cô lập context, không phải để đóng vai** — model không cần được nhắc
   "you are the Backend Engineer" mới viết được FastAPI tử tế.
3. Nhiều luật chỉ tồn tại để vá vấn đề do chính việc tách agent đẻ ra
   (vd "hai agent không sửa cùng file").
4. Khi tầng nền (wiki + skills + luật) ra đời, khung "công ty" thành tầng trung gian thừa —
   mọi vai của nó có nhà tốt hơn.

## Cái gì được giữ, đi đâu

| Tài sản | Nhà mới |
|---|---|
| Luật kỹ thuật (9 nguyên tắc) | [[engineering-rules]] |
| Stack chuẩn + luật ADR | [[default-stack]], AGENTS.md §3 |
| Cổng duyệt + debate | [[approval-gates]] |
| Nghi thức spike | `~/exp/` (AGENTS.md §0 — Vùng thí nghiệm) |
| Skills git-workflow / project-retro / project-init | `simon-brain/skills/` (viết lại generic) |
| 6 native agents | Bỏ — mô hình solo agent |
| Repo ai-company | Archive, giữ nguyên lịch sử git |

Sản phẩm từng sống trong `products/`: [[ok2ship-ai]], [[native-skline-chart]],
các spike của [[ok2ship]] — đã dời ra `~/Documents/` khi archive.
