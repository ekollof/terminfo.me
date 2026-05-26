#!/bin/sh
# -----------------------------------------------------------------------------
# check-checksums.sh — Verify checksums.txt against actual .ti files + install.sh
# -----------------------------------------------------------------------------
# Usage:
#   contrib/check-checksums.sh
#
# Compares SHA-256 checksums in static/terminfo/checksums.txt against
# the current contents of all .ti files in static/terminfo/.
# Also verifies static/install.sh against data/install.json.
# Reports any .ti files missing from checksums.txt.
# -----------------------------------------------------------------------------

set -e

PROG="$(basename "$0")"
TERMINFO_DIR="${TERMINFO_DIR:-static/terminfo}"
CHECKSUM_FILE="$TERMINFO_DIR/checksums.txt"
INSTALL_SH="static/install.sh"
INSTALL_DATA="data/install.json"
ERRORS=0

info()  { printf '[%s] %s\n' "$PROG" "$*"; }
error() { printf '[%s] ERROR: %s\n' "$PROG" "$*" >&2; }
warn()  { printf '[%s] WARN: %s\n' "$PROG" "$*" >&2; }

# Determine sha256 command (portable across Linux, macOS, *BSD)
if command -v sha256sum >/dev/null 2>&1; then
    SHA_CMD="sha256sum"
    SHA_PARSE="awk '{print \$1}'"
elif command -v shasum >/dev/null 2>&1; then
    SHA_CMD="shasum -a 256"
    SHA_PARSE="awk '{print \$1}'"
elif command -v sha256 >/dev/null 2>&1; then
    # OpenBSD, FreeBSD, NetBSD
    SHA_CMD="sha256 -q"
    SHA_PARSE="cat"
elif command -v openssl >/dev/null 2>&1; then
    SHA_CMD="openssl dgst -sha256"
    SHA_PARSE="awk '{print \$NF}'"
else
    error "No SHA-256 utility found (tried: sha256sum, shasum, sha256, openssl)."
    exit 1
fi

# ---------------------------------------------------------------------------
# Verify .ti files
# ---------------------------------------------------------------------------
if [ ! -d "$TERMINFO_DIR" ]; then
    error "Directory not found: $TERMINFO_DIR"
    exit 1
fi

if [ ! -f "$CHECKSUM_FILE" ]; then
    error "Checksum file not found: $CHECKSUM_FILE"
    exit 1
fi

info "Verifying checksums from $CHECKSUM_FILE ..."

# Build a temp file of current checksums
TMPDIR="${TMPDIR:-/tmp}"
CURRENT_SUMS="$(mktemp "$TMPDIR/ti-current-XXXXXX")"
trap 'rm -f "$CURRENT_SUMS"' EXIT

for f in "$TERMINFO_DIR"/*.ti; do
    [ -f "$f" ] || continue
    BASENAME="$(basename "$f")"
    SUM="$($SHA_CMD "$f" | eval "$SHA_PARSE")"
    printf '%s  %s\n' "$SUM" "$BASENAME" >> "$CURRENT_SUMS"
done

# Compare each entry in checksums.txt
while IFS= read -r line; do
    # Skip empty lines and comments
    [ -n "$line" ] || continue
    case "$line" in
        \#*|'') continue ;;
    esac

    EXPECTED_SUM="$(printf '%s' "$line" | awk '{print $1}')"
    EXPECTED_FILE="$(printf '%s' "$line" | awk '{print $2}')"

    TI_PATH="$TERMINFO_DIR/$EXPECTED_FILE"
    if [ ! -f "$TI_PATH" ]; then
        warn "$EXPECTED_FILE: listed in checksums.txt but file is missing"
        ERRORS=$((ERRORS + 1))
        continue
    fi

    ACTUAL_SUM="$($SHA_CMD "$TI_PATH" | eval "$SHA_PARSE")"
    if [ "$EXPECTED_SUM" != "$ACTUAL_SUM" ]; then
        error "$EXPECTED_FILE: checksum mismatch"
        error "  expected: $EXPECTED_SUM"
        error "  actual:   $ACTUAL_SUM"
        ERRORS=$((ERRORS + 1))
    else
        info "  OK: $EXPECTED_FILE"
    fi
done < "$CHECKSUM_FILE"

# Find .ti files not in checksums.txt
for f in "$TERMINFO_DIR"/*.ti; do
    [ -f "$f" ] || continue
    BASENAME="$(basename "$f")"
    if ! grep -q "[[:space:]]${BASENAME}$" "$CHECKSUM_FILE" 2>/dev/null; then
        warn "$BASENAME: missing from checksums.txt"
        ERRORS=$((ERRORS + 1))
    fi
done

# ---------------------------------------------------------------------------
# Verify install.sh
# ---------------------------------------------------------------------------
if [ -f "$INSTALL_SH" ] && [ -f "$INSTALL_DATA" ]; then
    info "Verifying $INSTALL_SH against $INSTALL_DATA ..."
    EXPECTED_INSTALL="$(sed -n 's/.*"sha256".*: *"\([^"]*\)".*/\1/p' "$INSTALL_DATA")"
    if [ -z "$EXPECTED_INSTALL" ]; then
        warn "Could not parse sha256 from $INSTALL_DATA"
        ERRORS=$((ERRORS + 1))
    else
        ACTUAL_INSTALL="$($SHA_CMD "$INSTALL_SH" | eval "$SHA_PARSE")"
        if [ "$EXPECTED_INSTALL" != "$ACTUAL_INSTALL" ]; then
            error "install.sh: checksum mismatch"
            error "  expected: $EXPECTED_INSTALL"
            error "  actual:   $ACTUAL_INSTALL"
            error "Regenerate with: contrib/update-install-checksum.sh"
            ERRORS=$((ERRORS + 1))
        else
            info "  OK: install.sh"
        fi
    fi
else
    warn "Skipping install.sh check (file or data missing)"
fi

# Verify static/install.json is in sync with data/install.json
if [ -f "$INSTALL_DATA" ] && [ -f "static/install.json" ]; then
    if ! cmp -s "$INSTALL_DATA" "static/install.json"; then
        error "static/install.json is out of sync with data/install.json"
        error "Regenerate with: contrib/update-install-checksum.sh"
        ERRORS=$((ERRORS + 1))
    else
        info "  OK: static/install.json in sync"
    fi
elif [ -f "$INSTALL_DATA" ] && [ ! -f "static/install.json" ]; then
    error "static/install.json is missing (needed for production self-check)"
    error "Regenerate with: contrib/update-install-checksum.sh"
    ERRORS=$((ERRORS + 1))
fi

if [ "$ERRORS" -gt 0 ]; then
    error "$ERRORS checksum issue(s) found."
    error "Regenerate .ti checksums with: cd $TERMINFO_DIR && sha256sum *.ti > checksums.txt"
    error "Regenerate install checksum with: contrib/update-install-checksum.sh"
    exit 1
fi

info "All checksums verified OK."
exit 0
