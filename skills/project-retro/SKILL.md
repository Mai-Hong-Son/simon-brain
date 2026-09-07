---
name: project-retro
description: Rút kinh nghiệm sau milestone/dự án — chưng cất bài học vào wiki simon-brain theo đúng tầng. Use when user says retro, "rút kinh nghiệm", or finishes a milestone.
---

# Project retro — nghi thức chưng cất bài học

Đích ghi là **wiki simon-brain** (`~/Documents/simon-brain/wiki/`), theo luật `AGENTS.md` của repo đó.

## Quy trình

1. Đọc: trang `wiki/projects/<dự-án>.md` (nếu có), HANDOFF/PROGRESS/`docs/decisions/` trong repo
   sản phẩm, git log của milestone vừa qua.
2. Nhận diện: (a) sai lầm tốn thời gian, (b) quy trình/pattern lặp ≥2 lần, (c) quyết định đáng ghi.
3. Phân tầng từng bài học theo AGENTS.md §3:
   - Chỉ đúng trong dự án này → đề xuất ghi `wiki/projects/<dự-án>.md`.
   - Tái dùng được VÀ đã xuất hiện ở ≥2 dự án → đề xuất trang `wiki/concepts/` + link từ trang dự án.
   - Mới 1 dự án nhưng có vẻ tổng quát → ghi trang dự án, gắn nhãn *ứng viên thăng hạng* (lint sẽ theo dõi).
   - Chuẩn làm việc Sơn kỳ vọng ở agent → đề xuất cập nhật `wiki/entities/son.md`.
4. Trình danh sách đánh số + lý do, **tối đa 5 mục** (ép ưu tiên hóa). DỪNG, chờ Sơn duyệt từng mục.
5. Chỉ sau khi duyệt: ghi các mục được chọn theo workflow ingest (AGENTS.md §5.1),
   cập nhật `index.md`, append 1 dòng `log.md`, commit theo AGENTS.md §6.

## Luật

- Mỗi bài học phải qua quality gate: *một tháng nữa còn đúng và còn giúp ích không?*
- Ghi kết luận bền vững, không tường thuật diễn biến (AGENTS.md §2).
- **Không đợi retro**: giữa chừng nhận ra bài học đủ tổng quát → đề xuất NGAY, từng mục một,
  cùng cổng duyệt như trên. Retro là lưới quét cuối, không phải cửa duy nhất.
