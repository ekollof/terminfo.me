#!/bin/sh
# -----------------------------------------------------------------------------
# check-headers.sh — Verify .ti files have a proper comment header
# -----------------------------------------------------------------------------
# Usage:
#   contrib/check-headers.sh [FILE.ti ...]
#
# Checks that each .ti file begins with a comment block containing
# at minimum a "Terminal:" or terminal name line within the first
# few lines.
# -----------------------------------------------------------------------------

set -e

PROG="$(basename "$0")"
TERMINFO_DIR="${TERMINFO_DIR:-static/terminfo}"
ERRORS=0

info()  { printf '[%s] %s\n' "$PROG" "$*"; }
warn()  { printf '[%s] WARN: %s\n' "$PROG" "$*" >&2; }
error() { printf '[%s] ERROR: %s\n' "$PROG" "$*" >&2; }

if [ $# -gt 0 ]; then
    FILES="$*"
else
    if [ ! -d "$TERMINFO_DIR" ]; then
        error "Directory not found: $TERMINFO_DIR"
        exit 1
    fi
    FILES=""
    for f in "$TERMINFO_DIR"/*.ti; do
        [ -f "$f" ] || continue
        FILES="$FILES $f"
    done
fi

if [ -z "$FILES" ]; then
    error "No .ti files found to check."
    exit 1
fi

for f in $FILES; do
    BASENAME="$(basename "$f")"
    info "Checking header: $BASENAME ..."

    # Read first 10 lines and look for comment markers or the terminal name
    FIRST_LINES="$(head -n 10 "$f")"

    # Must have comment markers (#) in the first few lines
    if ! printf '%s\n' "$FIRST_LINES" | grep -q '^#'; then
        warn "  $BASENAME: no comment header found in first 10 lines"
        warn "  Consider adding a header with Terminal name, Source, License"
        ERRORS=$((ERRORS + 1))
        continue
    fi

    # The first non-comment line should be the terminfo entry definition
    ENTRY_LINE="$(sed -n '/^[^#]/p' "$f" | head -n 1)"
    if [ -z "$ENTRY_LINE" ]; then
        error "  $BASENAME: no terminfo entry definition found"
        ERRORS=$((ERRORS + 1))
        continue
    fi

    # Extract the canonical name from the entry (first token before | or ,)
    CANON_NAME="$(printf '%s' "$ENTRY_LINE" | sed 's/[|,].*//' | tr -d '[:space:]')"
    if [ -z "$CANON_NAME" ]; then
        error "  $BASENAME: could not extract terminal name from entry"
        ERRORS=$((ERRORS + 1))
        continue
    fi

    # Check that the canonical name appears in the file stem
    STEM="$(basename "$f" .ti)"
    if [ "$CANON_NAME" != "$STEM" ]; then
        warn "  $BASENAME: entry name '$CANON_NAME' does not match filename stem '$STEM'"
        # This is only a warning, not a hard error
    fi

    info "  OK: $BASENAME (entry: $CANON_NAME)"
done

if [ "$ERRORS" -gt 0 ]; then
    error "$ERRORS file(s) have header issues."
    exit 1
fi

info "All files have proper headers."
exit 0
