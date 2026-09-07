---
title: Cổng duyệt & phản biện
type: concept
status: stable
updated: 2026-09-07
tags: [process, review, quality]
sources: [ai-company/CLAUDE.md (Workflow + Debate mechanism), ai-company/.claude/agents/orchestrator.md, qa-reviewer.md]
---

# Cổng duyệt & phản biện

Chưng cất từ cơ chế workflow + debate của [[ai-company]], giữ phần còn giá trị sau khi
bỏ mô hình multi-agent (nay là solo agent — xem [[simon-platform]]).

## Chọn quy mô quy trình theo KÍCH THƯỚC, không theo tham vọng

- ≤2 file, không đổi logic/data → làm nhẹ: xác nhận scope → sửa → báo cáo. Không dùng đường này
  để lách một logic change qua review.
- Đụng logic/data, một stack → có plan ngắn → duyệt plan → làm + test → duyệt merge.
- Lớn / cross-stack → plan đầy đủ → duyệt plan → **duyệt danh sách test case trước khi viết test** → làm → duyệt merge.
- Phân vân giữa hai mức → **chọn mức cao hơn** (size up).

## Cổng của con người — không bao giờ vượt

- Không bắt đầu implement khi chưa qua cổng duyệt plan.
- Plan luôn kết thúc bằng "chờ duyệt trước khi thực thi".
- Nghiên cứu công nghệ → báo cáo khuyến nghị → Sơn duyệt việc adopt; lệch stack → ADR trước code.

## Phản biện (adversarial review)

- Muốn thách thức một plan/diff thì lấy **một context CHƯA TỪNG THẤY code đó** (spawn agent mới /
  `/code-review`) — tự phản biện trong cùng context là thiên kiến xác nhận, không phải review.
- Tối đa **3 vòng** tranh luận, dừng sớm khi đồng thuận; không ngã ngũ → trình Sơn CẢ HAI lập trường.
- Mỗi luận điểm kèm bằng chứng `file:line`; điểm không đứng vững thì nhượng bộ, không cãi cùn.
- Phân biệt defect thật vs false positive trước khi báo.
