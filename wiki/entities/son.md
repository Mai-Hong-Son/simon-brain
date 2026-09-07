---
title: Sơn
type: entity
status: stable
updated: 2026-09-07
tags: [user, preferences, standards]
sources: [ai-company/.claude/agents/dev-frontend.md, dev-mobile.md, memory feedback 07-08/2026]
---

# Sơn (Mai Hồng Sơn)

Chủ của hệ thống này. Mọi agent làm việc với Sơn cần biết các sự thật sau.

## Chuyên môn

- Senior React dev, **~10 năm kinh nghiệm React Native** — code JS/TS/RN sẽ bị review kỹ:
  viết idiomatic, rõ ràng hơn khôn lỏi, **không over-engineer**.
- Mọi hệ quả native-bridge / performance phải được flag rõ, không giấu trong diff.
- Đang chủ động học sâu backend (FastAPI, DB, auth, hạ tầng) — xem cách làm việc bên dưới.

## Cách làm việc ưa thích

- **Giải thích tư duy/khái niệm TRƯỚC khi code** — Sơn muốn hiểu luồng, không chỉ nhận kết quả.
- Đọc **tiếng Việt** nhanh hơn: mọi trao đổi, báo cáo, plan → tiếng Việt.
  Mọi thứ commit vào repo → tiếng Anh (xem [[engineering-rules]]).
- Làm tuần tự bước nhỏ → dừng báo cáo → duyệt → bước tiếp.

## Chuẩn làm việc kỳ vọng ở agent

Ba chuẩn này là feedback trực tiếp của Sơn sau các lần agent làm chưa tới (07/2026):

1. **Khảo sát công cụ trước khi chốt** — tài liệu chỉ định sẵn thư viện KHÔNG miễn việc tự khảo sát;
   trước khi chốt tool cho bước quan trọng, liệt kê 2–3 phương án hiện đại + đánh đổi
   (đủ họ: nặng/nhẹ/offline/online). Chủ động đề xuất, đừng để Sơn phải là người nhắc ra công cụ đúng.
2. **Xác minh bằng tín hiệu chéo** — soi tay "ground truth" vẫn phải đối chiếu mọi tín hiệu độc lập
   sẵn có; số lệch bất thường giữa 2 nguồn → soi lại CẢ HAI, kể cả nguồn "người".
   Coi chừng priming: vừa đọc nhiều ca giống nhau dễ đọc nhầm ca khác thành giống.
3. **Mô hình hóa vật thể, đừng chỉ tối ưu metric** — sau khi "đủ tốt" vẫn làm một lượt
   "chuyên gia sẽ thêm gì?": liệt kê bất biến của đối tượng (hình dạng, vị trí, kích thước hợp lệ);
   mỗi ca lỗi → hỏi "đây có phải một LUẬT per-đối-tượng?" trước khi vặn tham số toàn cục;
   nâng cấp spec được giao từ nguyên lý, đừng thực thi nguyên văn.
