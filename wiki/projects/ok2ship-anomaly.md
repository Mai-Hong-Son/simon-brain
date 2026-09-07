---
title: ok2ship-anomaly
type: project
status: active
updated: 2026-09-07
tags: [ok2ship, spike, anomaly-detection, ml]
sources: [~/Documents/ok2ship-anomaly/HANDOFF.md, memory hub ai-company]
---

# ok2ship-anomaly — spike req #3

Spike 🧪 của [[ok2ship]]: phát hiện bất thường ảnh QA bằng so với mẫu chuẩn (golden), per-pin.
**Hiện trạng chi tiết: `HANDOFF.md` trong repo spike.** Chưa PROMOTE.

## Hướng đã chốt với Sơn

- **Golden/one-class** (không supervised-defect): cần ít ảnh mẫu, không cần dataset lỗi.
- Công cụ: **Anomalib + PatchCore**, chạy offline (data khách không rời máy — [[engineering-rules]] #3).
- Code viết để đổ ảnh thật vào `data/golden/` chạy lại được, không sửa code.

## Kết luận kỹ thuật đã rút được

- **Chất lượng curation golden set chi phối tất cả** — một ảnh overview lạc loại trong golden
  làm overlap golden-vs-abnormal tệ đi hàng chục điểm; gỡ đúng 1 ảnh là tách hẳn.
- **Phải seed randomness trước khi kết luận** — coreset của PatchCore chọn điểm khởi đầu ngẫu nhiên,
  điểm số đầu bảng dao động >10 điểm giữa các run giống hệt nhau; mọi "gap" chưa seed chỉ là
  một mẫu của đại lượng nhiễu.
- **Ngưỡng hiển thị ≠ ngưỡng calibrated** — percentile chọn bằng mắt chỉ để vẽ contour;
  làm gate OK/NG tự động thì bắt buộc calibrate; làm tool xếp hạng cho người soi thì cutoff lỏng chấp nhận được.
- Test trung thực = ảnh bị judge phải **vắng mặt** khỏi memory bank lẫn val/test split.
- Detection đã chạy được trên cả 2 component thật; localisation mới đúng trên 1 —
  golden set nhỏ dưới ngưỡng tin cậy thì kết quả chỉ là smoke test.

*(Các bài học ML ở trên là ứng viên thăng hạng concept khi dự án ML khác dùng đến — AGENTS.md §3.)*
