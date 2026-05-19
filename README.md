# Terminfo Collection

A curated, public collection of high-quality terminfo source files (`.ti`) for modern terminal emulators.

**Live site:** https://terminfo.me

## What is this?

Many terminal emulators ship with custom terminfo entries that are missing from older system ncurses databases. This causes broken colors, missing key sequences, and other issues when SSHing into remote machines or using older distributions.

This repository hosts official `.ti` source files for popular terminals, makes them browsable, and provides a one-line installer that detects your `$TERM`, downloads the correct entry, and compiles it into `~/.terminfo` safely.

## Features

- Clean, fast, static Hugo site with a terminal-inspired aesthetic
- Browse and preview all available terminfo entries
- One-liner install script (`install.sh`) with checksum verification
- Dark-first design, excellent mobile experience
- Deployed automatically to GitHub Pages

## Quick Start (Development)

```bash
# Clone the repository
git clone https://github.com/ekollof/terminfo.me.git
cd terminfo.me

# Run the Hugo dev server
hugo server --buildDrafts
```

## Adding a New Terminfo Entry

1. Place the `.ti` source file in `static/terminfo/<name>.ti`
2. Regenerate checksums:
   ```bash
   cd static/terminfo
   sha256sum *.ti > checksums.txt
   ```
3. Open a Pull Request with a clear description

All submissions are reviewed before merging.

## Deployment

This site is built and deployed to GitHub Pages automatically via GitHub Actions on every push to `main`.

To configure Pages:
1. Go to **Settings > Pages** in your GitHub repository
2. Set **Source** to **GitHub Actions**

## Security

- The install script never runs `tic` with elevated privileges
- Only writes to `~/.terminfo` within your home directory
- All `.ti` files are plain text and reviewed before merging
- SHA-256 checksums are provided for optional verification

## License

MIT — see [LICENSE](LICENSE).

## Credits

Terminfo entries are sourced from their respective terminal emulator projects and the official ncurses database. See each `.ti` file for its origin and license.
