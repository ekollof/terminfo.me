#!/bin/sh
# -----------------------------------------------------------------------------
# check-syntax.sh — Validate terminfo source syntax with tic
# -----------------------------------------------------------------------------
# Usage:
#   contrib/check-syntax.sh [FILE.ti ...]
#
# If no arguments are given, all .ti files under static/terminfo/ are checked.
# Returns 0 if all files compile cleanly, 1 otherwise.
# -----------------------------------------------------------------------------

set -e

PROG="$(basename "$0")"
TERMINFO_DIR="${TERMINFO_DIR:-static/terminfo}"
ERRORS=0

info()  { printf '[%s] %s\n' "$PROG" "$*"; }
error() { printf '[%s] ERROR: %s\n' "$PROG" "$*" >&2; }

# Ensure tic is available
if ! command -v tic >/dev/null 2>&1; then
    error "'tic' not found. Please install ncurses development tools."
    exit 1
fi

# Determine files to check
if [ $# -gt 0 ]; then
    FILES="$*"
else
    if [ ! -d "$TERMINFO_DIR" ]; then
        error "Directory not found: $TERMINFO_DIR"
        error "Run from repository root or set TERMINFO_DIR"
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

TMPDIR="${TMPDIR:-/tmp}"
COMPILE_DIR="$(mktemp -d "$TMPDIR/tic-check-XXXXXX")"
trap 'rm -rf "$COMPILE_DIR"' EXIT

for f in $FILES; do
    if [ ! -f "$f" ]; then
        error "File not found: $f"
        ERRORS=$((ERRORS + 1))
        continue
    fi

    BASENAME="$(basename "$f")"
    info "Checking $BASENAME ..."

    # Compile with tic -x to catch syntax errors.
    # We use a temporary output directory and discard the compiled output.
    # Filter out a known harmless warning about description fields in older tic.
    OUTPUT="$(tic -x -o "$COMPILE_DIR" "$f" 2>&1)"
    # Remove known harmless warnings
    FILTERED="$(printf '%s\n' "$OUTPUT" | grep -v 'older tic versions may treat the description field as an alias' || true)"
    if [ -z "$FILTERED" ]; then
        info "  OK: $BASENAME compiles cleanly"
    else
        printf '%s\n' "$OUTPUT" >&2
        error "  FAILED: $BASENAME has syntax errors"
        ERRORS=$((ERRORS + 1))
    fi
done

if [ "$ERRORS" -gt 0 ]; then
    error "$ERRORS file(s) failed syntax check."
    exit 1
fi

info "All files passed syntax check."
exit 0
