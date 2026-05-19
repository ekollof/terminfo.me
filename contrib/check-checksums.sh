#!/bin/sh
# -----------------------------------------------------------------------------
# check-checksums.sh — Verify checksums.txt against actual .ti files
# -----------------------------------------------------------------------------
# Usage:
#   contrib/check-checksums.sh
#
# Compares SHA-256 checksums in static/terminfo/checksums.txt against
# the current contents of all .ti files in static/terminfo/.
# Also reports any .ti files missing from checksums.txt.
# -----------------------------------------------------------------------------

set -e

PROG="$(basename "$0")"
TERMINFO_DIR="${TERMINFO_DIR:-static/terminfo}"
CHECKSUM_FILE="$TERMINFO_DIR/checksums.txt"
ERRORS=0

info()  { printf '[%s] %s\n' "$PROG" "$*"; }
error() { printf '[%s] ERROR: %s\n' "$PROG" "$*" >&2; }
warn()  { printf '[%s] WARN: %s\n' "$PROG" "$*" >&2; }

if [ ! -d "$TERMINFO_DIR" ]; then
    error "Directory not found: $TERMINFO_DIR"
    exit 1
fi

if [ ! -f "$CHECKSUM_FILE" ]; then
    error "Checksum file not found: $CHECKSUM_FILE"
    exit 1
fi

# Determine sha256 command
if command -v sha256sum >/dev/null 2>&1; then
    SHA_CMD="sha256sum"
    SHA_PARSE="awk '{print \$1}'"
elif command -v shasum >/dev/null 2>&1; then
    SHA_CMD="shasum -a 256"
    SHA_PARSE="awk '{print \$1}'"
else
    error "Neither sha256sum nor shasum is available."
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

if [ "$ERRORS" -gt 0 ]; then
    error "$ERRORS checksum issue(s) found."
    error "Regenerate with: cd $TERMINFO_DIR && sha256sum *.ti > checksums.txt"
    exit 1
fi

info "All checksums verified OK."
exit 0
