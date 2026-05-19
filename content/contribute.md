---
title: "Contribute"
description: "How to submit a new terminfo entry to the collection via GitHub Pull Request."
---

## How to Contribute

We welcome high-quality terminfo source files for terminal emulators that are missing from the main ncurses database or that have improved definitions.

### Before you submit

- Make sure the `.ti` file compiles cleanly with `tic -x`.
- Include a comment header with the terminal name, author, source URL, and license.
- Do not include compiled `.db` or binary files—only source.

### Submission template

Create a new file in `static/terminfo/` named `<terminal-name>.ti`. Use this header:

```
# -----------------------------------------------------------------------------
# Terminal: <terminal-name>
# Source:   <URL to official repo or documentation>
# License:  <e.g., MIT, Public Domain, GPL-2.0>
# Notes:    <any special instructions or caveats>
# -----------------------------------------------------------------------------
```

Then run the checksum helper:

```bash
sha256sum static/terminfo/<terminal-name>.ti >> static/terminfo/checksums.txt
```

### Open a Pull Request

1. Fork the repository on GitHub.
2. Create a branch: `git checkout -b add-<terminal-name>`.
3. Add your `.ti` file and updated checksum.
4. Open a Pull Request with a clear description of what terminal it covers and why it is needed.

All submissions are reviewed before merging to ensure correctness and safety.

### Code of Conduct

Be respectful and constructive. We are all here to make terminal life better for everyone.
