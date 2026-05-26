---
title: "Contribute"
description: "How to submit a new terminfo entry to the collection via GitHub."
---

## How to Contribute a New Terminfo Entry

We welcome high-quality terminfo source files for terminals that are missing from the system ncurses database or that have better/more complete definitions.

### Quick Start (Recommended)

The easiest way to contribute is to **open an issue** first:

→ **[Submit a new terminfo via GitHub Issue](https://github.com/ekollof/terminfo.me/issues/new?template=new-terminfo.yml)**

This gives us a chance to review the entry and give feedback before you open a pull request.

---

### Manual Process (for experienced contributors)

If you prefer to open a PR directly, follow these steps:

#### 1. Create the `.ti` file

Create a new file in `static/terminfo/<terminal-name>.ti` with this header format:

```text
# -----------------------------------------------------------------------------
# Terminal: <terminal-name>
# Source:   <URL to official source or documentation>
# License:  <e.g. MIT, Public Domain, GPL-2.0>
# Notes:    <any special capabilities or caveats>
# -----------------------------------------------------------------------------
```

Example:

```text
# -----------------------------------------------------------------------------
# Terminal: ghostty
# Source:   https://github.com/ghostty-org/ghostty
# License:  MIT
# Notes:    Ghostty terminal emulator (2025+)
# -----------------------------------------------------------------------------
ghostty|Ghostty terminal emulator,
    ...
```

#### 2. Validate the file locally

```bash
# Check syntax
tic -x static/terminfo/your-terminal.ti

# Run the full validation suite
contrib/run-all-checks.sh
```

#### 3. Update checksums

```bash
sha256sum static/terminfo/your-terminal.ti >> static/terminfo/checksums.txt
```

Or let the pre-commit hook do it for you (recommended):

```bash
# One-time setup
cp contrib/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

#### 4. Open a Pull Request

- Create a branch: `git checkout -b add-your-terminal`
- Commit your changes (the pre-commit hook will help)
- Open a PR with a clear description

---

### What Makes a Good Contribution?

- The entry **must** compile cleanly with `tic -x`
- Prefer entries that are **authoritative** (from the terminal project itself)
- Include as many modern capabilities as possible (`XT`, `Tc`, `Su`, kitty keyboard protocol, etc.)
- Document the source clearly in the header

### Code of Conduct

Be respectful and constructive. Terminal emulators evolve quickly — we're all trying to make remote terminal life better.

Questions? Open an issue or ping us in the PR.
