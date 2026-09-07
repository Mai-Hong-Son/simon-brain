# AGENTS.md — Schema vận hành wiki `simon-brain`

Repo này là **bộ nhớ dài hạn** của Sơn + **institutional knowledge** của hệ ai-company.
Nhiều agent cùng đọc/ghi, sync qua git giữa nhiều máy.

Mọi agent làm việc trong repo này PHẢI đọc file này trước khi ghi bất cứ thứ gì vào `wiki/`.

---

## 0. Ba tầng

| Tầng | Đường dẫn | Ai sở hữu | Quy tắc |
|---|---|---|---|
| Raw sources | `raw/sources/` | Sơn | **Bất biến.** Agent chỉ đọc, không bao giờ sửa/xoá/đổi tên. |
| Wiki | `wiki/` | Agent (Sơn duyệt) | Agent viết toàn bộ. Sơn đọc, hỏi, duyệt. |
| Schema | `AGENTS.md` (file này) | Sơn + agent cùng tiến hoá | Sửa file này chỉ khi Sơn duyệt rõ ràng. |

`agents/` và `skills/` là **config của hệ ai-company**, không phải wiki. Đừng ingest nội dung wiki vào đó và ngược lại.

### Cấu trúc `wiki/`

```
wiki/
  index.md        # hub gốc — catalog toàn wiki, mỏng
  log.md          # nhật ký append-only, 1 dòng/việc
  concepts/       # kiến thức tái dùng: pattern, kỹ thuật, bài học chung, mental model
  entities/       # người, công ty, sản phẩm, tool, mô hình, khách hàng
  projects/       # việc đang chạy: sản phẩm, chiến dịch, hệ thống, nghiên cứu dài hạn
```

Tên file: kebab-case, một chủ đề một trang: `wiki/concepts/prompt-caching.md`.
Liên kết bằng wikilink `[[prompt-caching]]` (tương thích Obsidian). Link phóng khoáng — link tới trang chưa tồn tại là hợp lệ, nó đánh dấu trang cần viết sau.

### Frontmatter bắt buộc cho mọi trang wiki

```yaml
---
title: Prompt caching
type: concept        # concept | entity | project | hub
status: seed         # seed | active | stable
updated: 2026-09-07  # ngày sửa lần cuối, tuyệt đối, không dùng "hôm nay"/"tuần trước"
tags: [llm, cost]
sources: [raw/sources/anthropic-caching-docs.md]
---
```

---

## 1. Quality gate — luật số một

> **"Một tháng nữa điều này còn đúng và còn giúp ích không?"**

Trước MỖI dòng định ghi vào `wiki/`, tự hỏi câu trên. Không chắc **cả hai** vế → **không ghi**.

| Ghi ✅ | Không ghi ❌ |
|---|---|
| Kết luận đã chốt, kèm lý do | Ý tưởng đang cân nhắc, chưa chốt |
| Ràng buộc/quyết định còn hiệu lực | Trạng thái tạm: "đang chờ API key" |
| Bài học rút ra từ một lần sai | Diễn biến của lần sai đó |
| Con số/sự kiện kèm nguồn + ngày | Con số nhớ mang máng, không nguồn |
| Cách một hệ thống hoạt động | Log lệnh, output terminal, diff code |
| Sở thích/nguyên tắc làm việc của Sơn | Lời khen, chào hỏi, meta hội thoại |

Thà wiki mỏng mà đúng còn hơn dày mà mục. Khi phân vân → **không ghi**, nêu ra ở phần đề xuất cuối session để Sơn quyết.

---

## 2. Chỉ lưu kết luận bền vững — không lưu diễn biến session

Wiki là **trạng thái**, không phải **transcript**.

Cấm trong trang wiki (trừ `log.md`):
- Từ ngữ tường thuật: "hôm nay", "vừa nãy", "trong session này", "chúng ta đã thử", "agent đã chạy".
- Trình tự thời gian của một buổi làm việc: thử A → hỏng → thử B → được.
- Nhắc tới chính hội thoại hay chính agent nào đã viết.

Cách viết đúng: **hỏng-thử-được → viết ra cái "được" + tại sao "hỏng"** như một luật ở thì hiện tại.

> ❌ "Hôm nay agent thử dùng `pip install` trong sandbox, bị chặn, sau đó chuyển sang `uv` thì chạy được."
> ✅ "Trong sandbox này `pip install` bị chặn network. Dùng `uv pip install --offline` với cache cục bộ. — nguồn: [[dev-sandbox]], 2026-09-07"

`wiki/log.md` là **nơi duy nhất** được phép mang tính thời gian, và mỗi việc chỉ **một dòng**:

```
## [2026-09-07] ingest | Karpathy — LLM Wiki | @claude-code
## [2026-09-07] lint | 3 orphan, 1 mâu thuẫn ở [[pricing]] | @researcher
```

Format cố định `## [YYYY-MM-DD] <ingest|query|lint> | <chủ đề> | @<agent>` để grep được:
`grep "^## \[" wiki/log.md | tail -20`

---

## 3. Bài học đi đâu — project vs concept

| Loại bài học | Ghi ở đâu |
|---|---|
| Chỉ đúng trong bối cảnh **một dự án** (quirk của codebase, thoả thuận với một khách hàng, cấu hình riêng) | `wiki/projects/<duan>.md` |
| **Tái dùng được** ở dự án khác (pattern, kỹ thuật, nguyên tắc, cách một tool hành xử) | `wiki/concepts/<khai-niem>.md` **và** link từ trang dự án sang |

Trang dự án giữ **một dòng** ngữ cảnh + link, không copy nội dung concept sang:

```markdown
### Bài học
- Rate limit của vendor tính theo token/phút, không phải request/phút → xem [[api-rate-limiting]] để biết cách xử lý chung.
```

**Luật thăng hạng:** một bài học xuất hiện ở **≥ 2 dự án** → tách ra thành trang `concepts/`, hai trang dự án chỉ còn link. Lint pass phải phát hiện việc này.

**Luật giáng hạng:** một trang `concepts/` mà chỉ có đúng một dự án dùng và không có dấu hiệu tái dùng → gộp ngược về trang dự án, đề xuất xoá.

---

## 4. Hub giữ mỏng

Hub = `wiki/index.md`, và **bất kỳ trang nào có trang con** (ví dụ `projects/ai-company.md` là hub của các trang con của nó).

Luật hub:
- Hub chỉ chứa **tổng quan + link**. Mỗi mục tối đa **2 dòng** rồi link xuống trang con.
- Hub **≤ 100 dòng**. Vượt là tín hiệu phải tách.
- Một mục trong hub phình quá **~10 dòng** → tách ra trang con, để lại 1 câu tóm tắt + `[[link]]`.
- Chi tiết, số liệu, ví dụ, lịch sử → **luôn** nằm ở trang con, không nằm ở hub.
- Hub không bao giờ là nơi chứa kiến thức gốc. Nếu xoá hub mà mất thông tin → nội dung đó đã đặt sai chỗ.

`wiki/index.md` là catalog: nhóm theo `concepts / entities / projects`, mỗi trang một dòng `- [[slug]] — tóm tắt một câu`. Cập nhật ở **mọi** ingest.

---

## 5. Ba workflow

### 5.1 `ingest` — nạp nguồn mới

Kích hoạt: Sơn thả file vào `raw/sources/`, dán link, hoặc bảo "ingest cái này".

1. `git pull --rebase` trước khi đọc (xem §6).
2. Đọc **toàn bộ** nguồn. Không tóm tắt từ tiêu đề.
3. Đọc `wiki/index.md` để biết những trang nào đã tồn tại và có thể bị ảnh hưởng.
4. **Trao đổi takeaway với Sơn trước khi ghi.** Nêu 3–7 điểm chính + danh sách trang dự định tạo/sửa.
5. Sau khi Sơn duyệt: ghi/cập nhật các trang, đi qua quality gate §1 cho từng điểm.
   - Thông tin mới **mâu thuẫn** thông tin cũ → **không xoá cái cũ**. Ghi cả hai kèm ngày + nguồn, đánh dấu `> ⚠️ Mâu thuẫn:` và nêu ra ở lint.
   - Thông tin mới **bổ sung** → merge vào trang sẵn có, đừng tạo trang trùng chủ đề.
6. Cập nhật `wiki/index.md`, thêm cross-link hai chiều.
7. Append **một dòng** vào `wiki/log.md`.
8. Commit (xem §6).

Một nguồn tốt thường chạm 3–15 trang. Chạm 1 trang là dấu hiệu đọc chưa kỹ.

### 5.2 `query` — hỏi wiki

Kích hoạt: Sơn hỏi một câu về những gì đã biết.

1. Đọc `wiki/index.md` trước → chọn trang liên quan → đọc trang đó → mới trả lời.
2. Trả lời kèm **citation bằng wikilink** tới trang nguồn.
3. Nếu wiki không đủ dữ kiện: **nói thẳng là không có**, đừng suy diễn rồi ghi ngược vào wiki. Đề xuất nguồn cần tìm.
4. **Câu trả lời tốt phải được nộp ngược vào wiki.** Nếu câu trả lời là một tổng hợp/so sánh/phát hiện mới vượt qua quality gate §1 → đề xuất tạo trang mới cho nó ở cuối session. Đừng để nó chết trong chat.

### 5.3 `lint` — khám sức khoẻ wiki

Kích hoạt: Sơn bảo "lint", hoặc định kỳ sau mỗi ~10 lần ingest.

Kiểm tra, xuất ra **báo cáo — không tự sửa**:
- **Mâu thuẫn** giữa các trang, hoặc mốc `⚠️ Mâu thuẫn` còn treo.
- **Trang mục** (stale): `updated` quá 90 ngày, hoặc claim đã bị nguồn mới hơn phủ định.
- **Orphan**: trang không có link nào trỏ tới.
- **Link gãy / link tới trang chưa tồn tại** → danh sách trang cần viết.
- **Vi phạm §2**: trang chứa ngôn ngữ tường thuật session.
- **Vi phạm §4**: hub > 100 dòng, hoặc mục trong hub > 10 dòng.
- **Ứng viên thăng hạng §3**: bài học lặp ở ≥ 2 trang dự án.
- **Trang trùng chủ đề** nên gộp.
- **Lỗ hổng dữ liệu**: khái niệm được nhắc nhiều lần nhưng chưa có trang riêng.

Kết thúc bằng đề xuất: câu hỏi nên đào tiếp, nguồn nên tìm. Chờ Sơn chọn rồi mới sửa.

---

## 6. Nhiều agent, nhiều máy — luật git

Nhiều agent có thể ghi cùng lúc trên nhiều máy. Bắt buộc:

1. **`git pull --rebase` ngay đầu session** và **ngay trước khi commit**. Không có ngoại lệ.
2. **Commit nhỏ, một workflow một commit.** Message:
   `wiki(ingest): Karpathy LLM Wiki — 4 trang` / `wiki(lint): gỡ 3 orphan` / `wiki(query): thêm so-sanh-vector-db`
3. **Không bao giờ** `push --force`, `rebase -i`, `reset --hard` trên `main`, hay viết lại lịch sử. Lịch sử wiki là một phần của bộ nhớ.
4. **Không commit `raw/`** nếu nguồn nặng/có bản quyền — hỏi Sơn trước.
5. **Xử lý conflict:**
   - `wiki/log.md`: append ở cuối file → conflict luôn giải bằng **giữ cả hai dòng**, sắp theo ngày.
   - Trang nội dung: **giữ cả hai phiên bản**, đánh dấu `> ⚠️ Mâu thuẫn:` kèm nguồn + ngày của mỗi bên, để lint xử lý. **Tuyệt đối không chọn bên rồi xoá bên kia im lặng.**
6. **Ký tên agent** ở mỗi dòng log (`@claude-code`, `@researcher`, ...) để truy được nguồn gốc thay đổi.
7. Không hai agent cùng sửa một trang trong cùng một lượt. Nếu phải, chia theo trang, không chia theo đoạn.

---

## 7. Cuối session — đề xuất và chờ duyệt

**Agent không tự ghi vào `wiki/` khi chưa được duyệt.** Mặc định là đề xuất, không phải hành động.

Cuối mỗi session (hoặc khi Sơn bảo "chốt"), xuất đúng bảng này:

```
## Đề xuất cập nhật wiki

| # | Trang | Hành động | Nội dung (1 câu) | Quality gate |
|---|-------|-----------|------------------|--------------|
| 1 | concepts/prompt-caching.md | tạo | Cache TTL 1h, tiết kiệm ~90% input cost | ✅ còn đúng sau 1 tháng |
| 2 | projects/ai-company.md | sửa | Thêm bài học rate-limit + link concept | ✅ |
| 3 | index.md | sửa | Thêm 1 dòng cho trang mới | ✅ |

Không đề xuất ghi (rớt quality gate): <liệt kê ngắn + lý do>
```

Rồi **dừng lại và chờ**. Sơn trả lời bằng số (`1,3` / `all` / `không`). Chỉ ghi những mục được chọn, xong mới commit.

Ngoại lệ duy nhất: Sơn nói rõ "tự ingest, khỏi hỏi" — khi đó vẫn phải báo cáo lại danh sách trang đã chạm sau khi ghi xong.

---

## 8. Checklist rút gọn trước mỗi lần ghi

- [ ] Đã `git pull --rebase`?
- [ ] Qua quality gate: **một tháng nữa còn đúng và còn giúp ích không?**
- [ ] Là kết luận bền vững, không phải diễn biến session?
- [ ] Bài học đặt đúng chỗ: riêng dự án → trang dự án; tái dùng → trang concept + link?
- [ ] Hub còn mỏng (chỉ tổng quan + link)?
- [ ] Có frontmatter, `updated` là ngày tuyệt đối?
- [ ] Đã cross-link hai chiều? Đã cập nhật `index.md`? Đã append 1 dòng `log.md`?
- [ ] Sơn đã duyệt?
