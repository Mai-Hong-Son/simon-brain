# simon-brain 🧠

Bộ nhớ dài hạn của Sơn + institutional knowledge của **simon-platform**, xây theo pattern
[LLM Wiki của Karpathy](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f):
thay vì RAG tra cứu lại từ đầu mỗi lần hỏi, LLM **bồi đắp và bảo trì một wiki bền vững** —
tri thức được chưng cất một lần rồi giữ cho luôn đúng, mỗi nguồn mới làm wiki giàu thêm
chứ không nằm chết trong lịch sử chat.

> File này viết tiếng Việt vì là sổ tay vận hành của Sơn. Mọi thứ còn lại trong repo
> (wiki, skills, commit) viết tiếng Anh — xem luật ngôn ngữ trong `AGENTS.md`.

## Kiến trúc

```
simon-brain (repo này — NỀN TẢNG, sync git giữa nhiều máy)
├── AGENTS.md      # luật vận hành wiki — agent PHẢI đọc trước khi ghi
├── setup.sh       # dựng lại nền trên máy mới (symlink + ~/exp)
├── raw/sources/   # nguồn gốc Sơn nạp vào — BẤT BIẾN, agent chỉ đọc
├── wiki/          # tầng tri thức — agent viết, Sơn duyệt
│   ├── index.md   #   hub gốc: catalog toàn wiki, mỗi trang một dòng
│   ├── log.md     #   nhật ký append-only: ai làm gì, ngày nào
│   ├── concepts/  #   kiến thức tái dùng: pattern, kỹ thuật, bài học chung
│   ├── entities/  #   người, khách hàng, tool, mô hình
│   └── projects/  #   dự án đang chạy: mỗi dự án một trang (+ hub chương trình)
├── skills/        # quy trình đóng gói (git-workflow, project-init, project-retro)
└── agents/        # kho năng lực — mặc định rỗng (mô hình solo agent)

REPO SẢN PHẨM (~/Documents/<tên>)     ~/exp/
└── chỉ chứa code + config kỹ thuật   └── thí nghiệm — không ghi wiki, chết thì xoá
```

Ba tầng của pattern LLM wiki:

| Tầng | Ở đâu | Ai sở hữu |
|---|---|---|
| **Raw sources** | `raw/sources/` | Sơn nạp, bất biến |
| **Wiki** | `wiki/` | Agent viết toàn bộ, Sơn đọc & duyệt |
| **Schema** | `AGENTS.md` | Sơn + agent cùng tiến hoá |

Phép thử phân nhà (mỗi loại thông tin chỉ có MỘT nhà):

| Loại thông tin | Nhà duy nhất |
|---|---|
| Luật hành vi agent + con trỏ wiki | `~/.claude/CLAUDE.md` (mỏng) |
| Quyết định + lý do, bài học, tổng hợp xuyên dự án | `wiki/` |
| Hiện trạng code, lệnh build/test, convention | repo sản phẩm |
| Diễn biến đang làm dở | session (bốc hơi) / HANDOFF.md |

## Ba workflow (chi tiết trong `AGENTS.md` §5)

- **ingest** — nạp nguồn mới: đọc trọn → bàn takeaway với Sơn → được duyệt mới ghi →
  cập nhật index + log. Một nguồn tốt chạm 3–15 trang.
- **query** — hỏi wiki: đọc index → đọc trang liên quan → trả lời kèm citation `[[wikilink]]`.
  Câu trả lời hay được nộp ngược vào wiki, không để chết trong chat.
- **lint** — khám sức khoẻ định kỳ: mâu thuẫn, trang mục, orphan, link gãy, bài học đáng
  thăng hạng concept. Chỉ báo cáo, Sơn chọn rồi mới sửa.

Luật xương sống: quality gate **"một tháng nữa còn đúng và còn giúp ích không?"** —
chỉ lưu kết luận bền vững, không lưu diễn biến session; agent luôn **đề xuất rồi chờ duyệt**,
không tự ghi.

## Dựng lại trên máy mới

```bash
git clone git@github.com:Mai-Hong-Son/simon-brain.git ~/Documents/simon-brain
cd ~/Documents/simon-brain
./setup.sh
```

`setup.sh` là idempotent (chạy lại bao nhiêu lần cũng an toàn), làm 3 việc:

1. Symlink **từng** skill trong `skills/` vào `~/.claude/skills/` — Claude Code load skill
   từ đó; symlink từng cái để sống chung với skill có sẵn của máy.
2. Symlink từng file agent trong `agents/` vào `~/.claude/agents/` (hiện rỗng có chủ đích).
3. Tạo vùng thí nghiệm `~/exp/`.

Git sync phần **nội dung**; setup.sh cắm phần **dây điện** mà git không mang theo được.
Sau này thêm skill mới vào repo → chạy lại `./setup.sh` là link mới được cắm.

Lưu ý repo phải nằm đúng `~/Documents/simon-brain` — các con trỏ trong
`~/.claude/CLAUDE.md` và skills trỏ theo path này. **Clone simon-brain + chạy setup.sh TRƯỚC
khi mở session trong các product repo** — CLAUDE.md của chúng `@import` trang wiki từ path này,
chưa có repo thì session mở lên sẽ thiếu bối cảnh.

## Đọc wiki bằng gì

- **Obsidian** (khuyên dùng): mở vault tại `wiki/` — wikilink `[[...]]` bấm được,
  graph view thấy hình dạng tri thức, trang nào là hub, trang nào orphan.
- Hoặc đọc thẳng markdown trên GitHub / editor — wiki chỉ là thư mục markdown thuần.

## Lịch sử

Nền tảng này hấp thụ mô hình **ai-company** (07–09/2026) ngày 2026-09-07 — vì sao chuyển đổi
và tài sản đi đâu: đọc `wiki/entities/ai-company.md`; mô hình hiện hành:
`wiki/entities/simon-platform.md`.
