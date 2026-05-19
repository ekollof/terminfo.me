---
title: "Install Script"
description: "How the install.sh companion script works and how to use it safely."
---

## install.sh

We provide a well-commented, idempotent Bash script that detects your `$TERM`, downloads the matching `.ti` source, compiles it with `tic -x`, and installs it into `~/.terminfo`.

### Quick usage

```bash
curl -fsSL https://terminfo.example.com/install.sh | bash
```

### With explicit terminal name

```bash
curl -fsSL https://terminfo.example.com/install.sh | bash -s -- alacritty
```

### Verify checksums

```bash
curl -fsSL https://terminfo.example.com/install.sh | bash -s -- --verify
```

### What the script does

1. Detects your `$TERM` environment variable.
2. Maps it to a `.ti` file in this collection.
3. Downloads the source over HTTPS.
4. Optionally verifies the SHA-256 checksum.
5. Runs `tic -x -o ~/.terminfo <file.ti>`.
6. Skips re-installation if the entry is already present and up to date.

### Safety

- The script **never** runs `tic` with `sudo` or elevated privileges.
- It only writes to `~/.terminfo` in your home directory.
- It fails gracefully with clear error messages if a terminfo entry is missing.
- You can inspect the script at any time before piping it to `bash`.

[View install.sh source on GitHub](https://github.com/yourusername/terminfo-collection/blob/main/static/install.sh)
