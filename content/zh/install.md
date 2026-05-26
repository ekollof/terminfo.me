---
title: "安装脚本"
description: "install.sh 配套脚本的工作原理以及如何安全使用。"
---

## install.sh

我们提供了一个注释良好、幂等的 Bash 脚本，它可以检测你的 `$TERM`，下载匹配的 `.ti` 源文件，使用 `tic -x` 编译，并安装到 `~/.terminfo`。

### 快速用法

```bash
curl -fsSL https://terminfo.me/install.sh | sh
```

### 指定终端名称

```bash
curl -fsSL https://terminfo.me/install.sh | sh -s -- alacritty
```

### 验证校验和

```bash
curl -fsSL https://terminfo.me/install.sh | sh -s -- --verify
```

### 脚本功能

1. **自我验证**：下载自身和 `install.json` 的最新副本，验证自己的 SHA-256，然后重新执行已验证的副本（除非使用 `--skip-self-check`）。
2. 检测你的 `$TERM` 环境变量。
3. 将其映射到此集合中的 `.ti` 文件。
4. 通过 HTTPS 下载源文件。
5. 可选地验证 terminfo 文件的 SHA-256 校验和。
6. 运行 `tic -x -o ~/.terminfo <file.ti>`。
7. 如果条目已存在且是最新的，则跳过重新安装。

### 自我验证

在执行其他任何操作之前，脚本会进行自我检查：

- 从服务器下载 `install.sh` 和 `install.json` 的最新副本。
- 验证下载的脚本的 SHA-256 是否与 `install.json` 中发布的值匹配。
- 如果匹配，则重新执行已验证的副本并继续。
- 如果不匹配（或下载失败），脚本将以错误中止。

这可以保护你在服务器上的 `install.sh` 文件（或缓存中）被篡改的情况。

你可以使用 `--skip-self-check` 绕过自我检查（不推荐）。

### 安全性

- 脚本**绝不会**使用 `sudo` 或提升权限运行 `tic`。
- 它只写入你主目录中的 `~/.terminfo`。
- 如果 terminfo 条目缺失，它会以清晰的错误消息优雅地失败。
- 你可以在将脚本通过管道传输到 `sh` 之前随时检查脚本。

[在 GitHub 上查看 install.sh 源代码](https://github.com/ekollof/terminfo.me/blob/main/static/install.sh)
