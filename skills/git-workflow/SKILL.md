---
name: git-workflow
description: Quy ước git chung mọi dự án — commit format, branching, PR flow. Use when committing, branching, or preparing a PR.
---

# Git workflow

- Commit: `type(scope): message` — types: feat, fix, refactor, test, docs, chore. Imperative, <72 ký tự, tiếng Anh.
- Branch: `feature/<slug>`, `fix/<slug>`. Không commit thẳng main ở dự án serious.
- Trước khi commit: chạy test suite, chỉ commit khi xanh.
- PR: một mối quan tâm một PR; description = what + why + how tested.
  Diff đáng kể → chạy phản biện bằng context mới trước khi đưa Sơn review
  (wiki: `concepts/approval-gates`).
- Không bao giờ: force-push branch chung, commit `.env`/secret, viết lại lịch sử main.
