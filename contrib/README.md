# Contrib Scripts

These POSIX-compliant shell scripts help maintainers and contributors validate terminfo entries before submitting or merging.

All scripts can be run from the repository root.

## Scripts

### `run-all-checks.sh`
Convenience wrapper that runs all validation checks in sequence.

```sh
contrib/run-all-checks.sh
```

### `check-syntax.sh`
Compiles each `.ti` file with `tic -x` to catch syntax errors.

```sh
# Check all .ti files
contrib/check-syntax.sh

# Check specific files
contrib/check-syntax.sh static/terminfo/alacritty.ti static/terminfo/kitty.ti
```

### `check-headers.sh`
Verifies that each `.ti` file has a proper comment header and that the canonical terminal name can be extracted from the first non-comment line.

```sh
contrib/check-headers.sh
```

### `check-duplicates.sh`
Detects duplicate canonical terminal names across `.ti` files to prevent collisions.

```sh
contrib/check-duplicates.sh
```

### `check-checksums.sh`
Verifies that `static/terminfo/checksums.txt` is up to date and matches the current contents of all `.ti` files. Also reports any `.ti` files missing from the checksum file.

```sh
contrib/check-checksums.sh
```

## Regenerating Checksums

If `check-checksums.sh` reports mismatches, regenerate with:

```sh
cd static/terminfo
sha256sum *.ti > checksums.txt
```

## Requirements

- POSIX `/bin/sh`
- `tic` (from ncurses)
- `sha256sum` or `shasum`
- Standard utilities: `sed`, `awk`, `grep`, `sort`, `mktemp`
