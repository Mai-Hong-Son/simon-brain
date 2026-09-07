---
title: void-guard-xval
type: project
status: active
updated: 2026-09-07
tags: [ok2ship, spike, cv, x-ray]
sources: [_spikes/void-guard-xval/HANDOFF.md, docs/rui-ro-so-lieu.md]
---

# void-guard-xval — spike đo void% X-ray

Spike 🧪 của [[ok2ship]], mảng "X-ray Solder Void": xử lý ảnh X-ray AXI để đo void%
(bọt khí trong mối hàn) chuẩn xác. **Sơn đang làm tiếp — hiện trạng chi tiết: `HANDOFF.md`
trong repo spike.** Chưa PROMOTE.

## Mục tiêu đã chốt (Sơn định nghĩa lại 07/2026)

Trọng tâm là **xử lý ảnh cho đầu ra chuẩn** — detect đúng (1) khung mỗi chân = mẫu số,
(2) diện tích bọt = tử số. Công thức % là tầm thường, không phải thứ cần kiểm định.
Số máy in sẵn = **ground truth để chấm** ([[engineering-rules]] #1), không phải mục tiêu riêng.

## Quyết định & kết luận kỹ thuật

- **Mẫu số = diện tích khung ROI máy vẽ**, không phải pad hàn thật (chốt họp 2026-07-15) —
  máy và mình cùng mẫu số nên khớp theo cấu tạo; bias đều một chiều thì nghi threshold, không nghi mẫu số.
- **Đo bằng bám viền cyan máy vẽ** (hướng B), không đo độc lập từ mật độ — ảnh production luôn có
  annotation, lõi bọt tương phản quá thấp. Đánh đổi đã biết: chỉ chạy được ảnh CÓ viền;
  cần ảnh thô → phải chuyển hướng segment mật độ.
- Tô **từng vòng theo contour, không floodfill toàn ảnh** (floodfill đảo ngược ở khung góc → bug đo 100%);
  hiệu chỉnh trừ bề dày viền theo chu vi.
- **Ground truth OCR**: RapidOCR offline + người soi montage sửa tay; OCR cả ảnh một lần
  (crop nhỏ thì detector mù); parse format cứng.
- **Tiêu chí chấm hybrid**: số nhỏ dùng sai tuyệt đối, số lớn dùng sai tương đối —
  nâng cấp từ spec "<1 điểm" theo nguyên lý metrology.
- Kết quả đánh giá (bộ 10 ảnh/160 mối, 07/2026): MAE ~0.25 điểm, không bias — vượt mục tiêu.
- **Không graft luật per-đối-tượng từ pipeline khác bối cảnh** — đã thử và hỏng nặng;
  muốn dùng thì bê cả bối cảnh pipeline của nó.

## Nhánh học backend

Spike kiêm bài tập Sơn học backend: nâng API demo thành backend đủ 4 nhóm production-readiness
(nền/DB Postgres+Alembic · API cứng cáp · bảo mật rate-limit/refresh-token/CORS · vận hành
logging/health/Docker/CI). Gotcha pwdlib-không-passlib đã lên [[default-stack]].
Đang học lại từng phần tuần tự để hiểu trọn.

*(Ba bài feedback từ spike này đã chưng cất thành chuẩn làm việc chung trong [[son]].)*
