---
title: native-skline-chart
type: project
status: active
updated: 2026-09-07
tags: [react-native, library, charts, mobile]
sources: [native-skline-chart/CLAUDE.md, docs/decisions/001-005]
---

# native-skline-chart — thư viện K-line native

Thư viện chart nến (candlestick) cho app crypto, API là React Native nhưng phần vẽ nặng nằm
ở native iOS/Android. Sản phẩm độc lập, không thuộc [[ok2ship]]. **Performance là mục tiêu #1**:
không bao giờ đẩy draw loop nặng qua JS bridge mỗi frame. Đang ở giai đoạn thiết kế/ADR, chưa code.

## Quyết định kiến trúc (5 ADR trong `docs/decisions/` của repo — đây là tóm tắt + lý do)

1. **Jest thay vitest** cho tầng JS/TS — RN ship Jest preset riêng, cả hệ sinh thái RN xây quanh Jest;
   vitest nghẹn với source Flow-typed chưa transpile của RN. (Nguồn của ngoại lệ trong [[default-stack]].)
2. **Fabric-only, không Paper fallback** — thư viện tham khảo `native-kline-view` quảng cáo
   "Fabric support" nhưng soi code là Paper thuần chạy qua interop layer (không codegenConfig,
   không spec file). Sản phẩm này cần command API thật của Fabric cho fast path.
3. **Typed props + command-based realtime fast path** — mô hình cũ serialize CẢ mảng nến +
   indicator thành JSON string qua bridge mỗi tick: O(n) cho thay đổi O(1), trên JS thread,
   ở tần suất tick. Tick đi qua command imperative, không re-send props.
4. **Indicators (MA/BOLL/MACD/KDJ/RSI/WR) tính ở native, incremental** — JS chỉ gửi OHLCV thô +
   tham số; tính ở JS thì payload phình và block đúng thread đang xử lý touch.
5. **Port renderer + gesture từ `native-kline-view`** thay vì viết lại từ đầu — geometry pan/zoom/
   crosshair là đồ tốn công ít tính mới. ⚠️ License: root Apache-2.0 nhưng podspec khai MIT
   (mâu thuẫn), không có NOTICE, code 3 lớp tác giả (tifezh/hjm/hublot) —
   **giữ nguyên mọi dòng attribution khi port** ([[engineering-rules]]: nghĩa vụ license).

## Luật riêng sản phẩm

- Uncertainty rule siết chặt nhất ở tầng bridge (Fabric/JSI, view manager, event emitter):
  chưa hiểu trọn thì HỎI, không đổi.
- Thư viện nhận data làm input — không bao giờ tự gọi exchange API, không nhúng key/secret.
