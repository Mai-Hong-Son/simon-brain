---
title: OK2SHIP
type: hub
status: active
updated: 2026-09-07
tags: [ok2ship, program, qa]
sources: [~/Documents/ok2ship-ai/CLAUDE.md, memory hub ai-company 08/2026]
---

# OK2SHIP — hub chương trình

Hệ AI kiểm tra QA report cho [[mektec-desoft]] (Mektec Vietnam, vendor Desoft): kiểm tra
data/ảnh báo cáo QA với spec, golden sample và lịch sử xuyên báo cáo trước khi duyệt xuất hàng.
Đây là trang toàn cảnh — chi tiết ở trang con.

## 5 yêu cầu gốc của BA (file "Ok2ship AI check", 08/2026)

| Req | Nội dung | Ai chứng minh khả thi |
|---|---|---|
| #1 | So OCR với giá trị ô trong report | [[ok2ship-report-parser]] |
| #2 | Check spec/statistics | [[ok2ship-report-parser]] |
| #3 | So ảnh với mẫu chuẩn, phát hiện bất thường per-pin | [[ok2ship-anomaly]] |
| #4 | Deviation xuyên báo cáo | [[ok2ship-report-parser]] |
| #5 | So sánh boxplot | [[ok2ship-report-parser]] |

## Các mảnh

- [[ok2ship-ai]] — sản phẩm thật 🚀, build từng module theo WBS của Desoft.
  Module 1 (User Management) xong; các module AI/data tương lai sẽ **tái dùng kết quả spike,
  không derive lại**.
- [[ok2ship-anomaly]] — spike 🧪 cho req #3 (ảnh vs golden, one-class AI).
- [[ok2ship-report-parser]] — spike 🧪 cho req #1/#2/#4/#5 (đọc data Excel report thật).
  Tách khỏi anomaly có chủ đích: khác chất hoàn toàn (bảng số vs ảnh).
- [[void-guard-xval]] — spike 🧪 mảng "X-ray Solder Void": đo void% từ ảnh X-ray AXI,
  chấm bằng khớp số máy. Sơn đang làm tiếp.
