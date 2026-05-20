# AGENTS.md — terminfo.me

Agent-focused guide for working on the terminfo.me Hugo site.

## Project Overview

A fully static Hugo site hosting curated terminfo source files (`.ti`) for modern terminal emulators. Served at **https://terminfo.me**.

- **Generator:** Hugo (v0.161.1+, extended)
- **Theme:** Custom `terminfo` theme (dark-first, terminal-inspired)
- **Deploy:** GitHub Pages via GitHub Actions
- **Repo:** https://github.com/ekollof/terminfo.me

## Quick Commands

```bash
# Dev server (serves at http://localhost:1313/)
hugo server --buildDrafts

# Production build (outputs to ./public/)
hugo --gc --minify

# Validate all terminfo entries
contrib/run-all-checks.sh
```

## Directory Structure

```
.
├── hugo.toml                    # Site config (baseURL, menus, params)
├── content/
│   ├── install.md               # Install script documentation page
│   ├── contribute.md            # Contribution guide page
│   └── terminfo/_index.md       # Browse directory index page
├── static/
│   ├── install.sh               # Companion POSIX install script
│   ├── favicon.svg              # Terminal-prompt favicon
│   └── terminfo/                # Raw .ti source files (served as-is)
│       ├── alacritty.ti
│       ├── kitty.ti
│       ├── wezterm.ti
│       ├── ghostty.ti
│       ├── foot.ti
│       ├── tmux-256color.ti
│       ├── xterm-256color.ti
│       └── ... (16 entries total)
│       └── checksums.txt        # SHA-256 checksums for all .ti files
├── themes/terminfo/             # Custom Hugo theme
│   ├── assets/
│   │   ├── css/main.css         # Main stylesheet (~1000 lines)
│   │   └── js/main.js           # Typewriter, copy buttons, live search
│   └── layouts/
│       ├── baseof.html          # Site shell
│       ├── home.html            # Homepage (hero + problem demo + search)
│       ├── section.html         # /terminfo/ browsable directory
│       ├── page.html            # Generic content pages
│       ├── single.html          # Single entry view
│       └── _partials/
│           ├── head.html        # Meta, fonts, CSS/JS includes
│           ├── header.html      # Logo + nav
│           └── footer.html
├── contrib/                     # Validation scripts
│   ├── run-all-checks.sh
│   ├── check-syntax.sh          # tic -x compilation test
│   ├── check-headers.sh         # Header/entry name validation
│   ├── check-duplicates.sh      # Duplicate name detection
│   ├── check-checksums.sh       # SHA-256 verification
│   └── pre-commit               # Git pre-commit hook template
└── .github/workflows/pages.yaml # CI: build + deploy to GitHub Pages
```

## Critical File Relationships

### When adding a new terminfo entry

1. **Add the `.ti` file** to `static/terminfo/<name>.ti`
2. **Regenerate checksums** — `cd static/terminfo && sha256sum *.ti > checksums.txt`
3. **Run validation** — `contrib/run-all-checks.sh`
4. The homepage (`layouts/home.html`) and browse page (`layouts/section.html`) auto-generate listings by reading `static/terminfo/*.ti` — no manual edits needed.

### When changing the domain

Update these locations:
1. `hugo.toml` → `baseURL` and `params.domain`
2. `static/install.sh` → `BASE_URL` default
3. Rebuild with `hugo --gc --minify`

## Theme Architecture

- **Color scheme:** Dark-first CSS variables (`--bg: #0b0f14`, `--accent: #4cc38a`)
- **Fonts:** JetBrains Mono (mono) + Inter (body), loaded from Google Fonts
- **No external CSS framework** — all styles are in `themes/terminfo/assets/css/main.css`
- **JS features:** Typewriter terminal demo, copy-to-clipboard buttons, live search filtering
- **Responsive:** Mobile-first breakpoints at 640px

## Build & Deploy

GitHub Actions (`.github/workflows/pages.yaml`) runs on every push to `main`:
1. Checks out repo
2. Installs Hugo extended v0.161.1
3. Runs `hugo --gc --minify --baseURL "https://terminfo.me/"`
4. Uploads `public/` artifact
5. Deploys to GitHub Pages

**GitHub Pages setup:** Settings → Pages → Source: GitHub Actions

## Validation (contrib scripts)

All POSIX `/bin/sh` compliant. Run from repo root.

| Script | Purpose |
|--------|---------|
| `check-syntax.sh` | Compiles each `.ti` with `tic -x` to catch syntax errors |
| `check-headers.sh` | Verifies comment headers and extracts canonical entry names |
| `check-duplicates.sh` | Detects duplicate terminal names across `.ti` files |
| `check-checksums.sh` | Verifies `checksums.txt` matches current `.ti` contents; also checks `install.sh` against `data/install.json` |
| `run-all-checks.sh` | Runs all of the above in sequence |
| `update-install-checksum.sh` | Computes `static/install.sh` SHA-256 and writes it to `data/install.json` for Hugo to read at build time |

**Pre-commit hook:** `cp contrib/pre-commit .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit`

The hook auto-regenerates `data/install.json` when `install.sh` is staged, then runs the full validation suite.

## Style Conventions

- **CSS:** Custom properties (CSS variables) in `:root`. No preprocessors.
- **JS:** Vanilla IIFE, no frameworks. Event delegation for dynamic elements.
- **Go templates:** Use backtick strings for paths: `` `terminfo/%s` | relURL ``
- **URLs:** Always use `relURL` or `absURL` filters; never hardcode paths.
- **Indentation:** 2 spaces for HTML/CSS/JS, tabs for Go templates (Hugo standard)

## Common Pitfalls

- **BaseURL path prefix:** When `baseURL = '/'`, all `relURL` outputs root-relative paths (`/css/main.min.css`). Previously it was `/terminfo-collection/` — some templates may still have hardcoded paths. Always use template filters.
- **Checksums must be regenerated** after any `.ti` file change. `check-checksums.sh` will fail otherwise.
- **`public/` is build output** — do not commit this directory. It is already in `.gitignore` (ensure this).
- **Hugo `readDir` / `readFile`:** These read from the project root, not from `static/` directly. The homepage listing uses `static/terminfo` as the path prefix.
- **Install script is POSIX `/bin/sh`**, not bash. Avoid bashisms. The script runs under `dash`, `ksh`, etc.

## Testing Checklist

Before pushing changes:
- [ ] `hugo --gc --minify` builds without errors
- [ ] `contrib/run-all-checks.sh` passes
- [ ] Site looks correct at `http://localhost:1313/`
- [ ] Download links on `/terminfo/` work
- [ ] Install one-liner URL is correct on homepage
