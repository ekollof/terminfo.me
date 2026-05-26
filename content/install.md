---
title: "Install Script"
description: "How the install.sh companion script works and how to use it safely."
---

## install.sh

We provide a well-commented, idempotent Bash script that detects your `$TERM`, downloads the matching `.ti` source, compiles it with `tic -x`, and installs it into `~/.terminfo`.

### Quick usage

```bash
curl -fsSL https://terminfo.me/install.sh | sh
```

### With explicit terminal name

```bash
curl -fsSL https://terminfo.me/install.sh | sh -s -- alacritty
```

### Verify checksums

```bash
curl -fsSL https://terminfo.me/install.sh | sh -s -- --verify
```

### What the script does

1. **Self-verifies**: Downloads a fresh copy of itself and `install.json`, verifies its own SHA-256, and re-executes the verified copy (unless `--skip-self-check`).
2. Detects your `$TERM` environment variable.
3. Maps it to a `.ti` file in this collection.
4. Downloads the source over HTTPS.
5. Optionally verifies the SHA-256 checksum of the terminfo file.
6. Runs `tic -x -o ~/.terminfo <file.ti>`.
7. Skips re-installation if the entry is already present and up to date.

### Self-verification

Before doing anything else, the script performs a self-check:

- It downloads a fresh copy of `install.sh` and `install.json` from the server.
- It verifies that the downloaded script's SHA-256 matches the value published in `install.json`.
- If they match, it re-executes the verified copy and continues.
- If they don't match (or the download fails), the script aborts with an error.

This protects you in case the `install.sh` file on the server (or in a cache) has been tampered with.

You can bypass the self-check with `--skip-self-check` (not recommended).

### Safety

- The script **never** runs `tic` with `sudo` or elevated privileges.
- It only writes to `~/.terminfo` in your home directory.
- It fails gracefully with clear error messages if a terminfo entry is missing.
- You can inspect the script at any time before piping it to `sh`.

[View install.sh source on GitHub](https://github.com/ekollof/terminfo.me/blob/main/static/install.sh)
