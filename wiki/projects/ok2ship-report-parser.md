---
title: ok2ship-report-parser
type: project
status: active
updated: 2026-09-07
tags: [ok2ship, spike, excel, parsing]
sources: [_spikes/ok2ship-report-parser/HANDOFF.md, memory hub ai-company]
---

# ok2ship-report-parser — spike req #1/#2/#4/#5

Spike 🧪 của [[ok2ship]]: đọc tin cậy data có cấu trúc (số, nhãn dòng, ngưỡng spec) từ file
báo cáo QA Excel thật của nhà máy — nền cho OCR-vs-cell (#1), spec check (#2), deviation (#4),
boxplot (#5). **Hiện trạng chi tiết: `HANDOFF.md` trong repo spike.** Chưa PROMOTE.

## Quyết định đã khóa với Sơn

- Tách hẳn khỏi [[ok2ship-anomaly]] — khác chất (bảng số vs ảnh), không merge scope.
- **Parse theo NHÃN dòng, không bao giờ theo tọa độ ô cứng** (xem phát hiện bên dưới).
- **Không bao giờ drop sheet im lặng** — sheet chưa có parser thì passthrough raw;
  Sơn quyết cái gì bỏ, không phải tool.
- Output ordered theo tab order thật; key `snake_case`; sheet chỉ chứa cái của chính nó
  (không cross-sheet, không verdict — tầng check là bước sau, không nằm trong reader).

## Phát hiện về format report thật (lý do của các luật trên)

- **Merge cell chỉ bọc NHÃN, không bọc số** — suy từ merge để định vị giá trị là sai.
- **Cấu trúc trôi giữa các báo cáo**: số sheet không cố định (có model mang bộ "Shell B2B..."
  song song), pin count đổi theo báo cáo — không được hardcode.
- **Ô nhãn tiêu đề có thể bị hỏng** (bị đè giá trị thay vì chữ, nghi chỉnh tay) →
  parser phải có bước tự kiểm, không tin mù dữ liệu vào.
- Đọc **streaming** (`openpyxl read_only=True`) bỏ qua ảnh nhúng → mở file trăm MB trong tích tắc;
  ảnh nằm layer riêng trong zip, trích qua drawing XML và map theo anchor.

*(Bộ bài học Excel-parsing này là ứng viên thăng hạng concept khi module data của
[[ok2ship-ai]] dùng thật — AGENTS.md §3.)*
