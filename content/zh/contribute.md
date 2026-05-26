---
title: "贡献"
description: "如何通过 GitHub 提交新的 terminfo 条目到集合。"
---

## 如何贡献新的 terminfo 条目

我们欢迎为系统中 ncurses 数据库中缺失的终端提供高质量的 terminfo 源文件，或提供改进/更完整的定义。

**语言说明：** 请用英语撰写 issue 描述、pull request 和评论。这有助于维护者更高效地审查贡献。

### 快速开始（推荐）

最简单的方式是**先打开一个 issue**：

→ **[通过 GitHub Issue 提交新的 terminfo](https://github.com/ekollof/terminfo.me/issues/new?template=new-terminfo.yml)**

这让我们有机会在你打开 pull request 之前审查条目并提供反馈。

---

### 手动流程（适合有经验的贡献者）

如果你更喜欢直接打开 PR，请按照以下步骤操作：

#### 1. 创建 `.ti` 文件

在 `static/terminfo/<terminal-name>.ti` 中创建一个新文件，使用以下标题格式：

```text
# -----------------------------------------------------------------------------
# Terminal: <terminal-name>
# Source:   <官方仓库或文档的 URL>
# License:  <例如 MIT, Public Domain, GPL-2.0>
# Notes:    <任何特殊说明或注意事项>
# -----------------------------------------------------------------------------
```

示例：

```text
# -----------------------------------------------------------------------------
# Terminal: ghostty
# Source:   https://github.com/ghostty-org/ghostty
# License:  MIT
# Notes:    Ghostty 终端模拟器 (2025+)
# -----------------------------------------------------------------------------
ghostty|Ghostty 终端模拟器,
    ...
```

#### 2. 本地验证文件

```bash
# 检查语法
tic -x static/terminfo/your-terminal.ti

# 运行完整验证套件
contrib/run-all-checks.sh
```

#### 3. 更新校验和

```bash
sha256sum static/terminfo/your-terminal.ti >> static/terminfo/checksums.txt
```

或者让 pre-commit hook 帮你完成（推荐）：

```bash
# 一次性设置
cp contrib/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

#### 4. 打开 Pull Request

- 创建分支：`git checkout -b add-your-terminal`
- 提交更改（pre-commit hook 会提供帮助）
- 打开一个描述清晰的 PR

---

### 什么是好的贡献？

- 条目**必须**能通过 `tic -x` 干净编译
- 优先来自终端项目本身的**权威**条目
- 尽可能包含现代能力（`XT`、`Tc`、`Su`、kitty 键盘协议等）
- 在标题中清楚记录来源

### 行为准则

请保持尊重和建设性。终端模拟器发展迅速——我们都在努力让远程终端使用体验对每个人都更好。

有问题？打开 issue 或在 PR 中 @ 我们。
