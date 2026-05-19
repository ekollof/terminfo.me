#!/bin/sh
# -----------------------------------------------------------------------------
# check-duplicates.sh — Detect duplicate terminal names across .ti files
# -----------------------------------------------------------------------------
# Usage:
#   contrib/check-duplicates.sh [FILE.ti ...]
#
# Extracts the canonical terminal name (first token before | or ,) from
# each .ti file and reports duplicates. Aliases/descriptions are ignored
# to avoid false positives from free-form text.
# -----------------------------------------------------------------------------

set -e

PROG="$(basename "$0")"
TERMINFO_DIR="${TERMINFO_DIR:-static/terminfo}"
ERRORS=0

info()  { printf '[%s] %s\n' "$PROG" "$*"; }
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

TMPDIR="${TMPDIR:-/tmp}"
NAME_MAP="$(mktemp "$TMPDIR/ti-names-XXXXXX")"
trap 'rm -f "$NAME_MAP"' EXIT

for f in $FILES; do
    BASENAME="$(basename "$f")"
    # Extract first non-comment, non-empty, non-whitespace-only line
    ENTRY_LINE=""
    while IFS= read -r line; do
        # Skip comment lines and blank lines
        case "$line" in
            \#*|'') continue ;;
        esac
        # Skip continuation lines (indented, not the main definition)
        case "$line" in
            \t*|' '*) continue ;;
        esac
        ENTRY_LINE="$line"
        break
    done < "$f"

    if [ -z "$ENTRY_LINE" ]; then
        error "$BASENAME: no entry definition found"
        ERRORS=$((ERRORS + 1))
        continue
    fi

    # Canonical name: first token before | or ,
    CANON_NAME="$(printf '%s' "$ENTRY_LINE" | sed 's/[|,].*//' | tr -d '[:space:]')"
    if [ -z "$CANON_NAME" ]; then
        error "$BASENAME: could not extract terminal name"
        ERRORS=$((ERRORS + 1))
        continue
    fi

    printf '%s:%s\n' "$CANON_NAME" "$BASENAME" >> "$NAME_MAP"
done

# Find duplicates (compare first field, grouped by sorted order)
DUPS="$(sort -t: -k1,1 "$NAME_MAP" | awk -F: '
    {
        name=$1
        file=$2
        if (name == prev) {
            if (!seen[name]) {
                print "Duplicate terminal name: " name
                print "  " prevfile
                seen[name]=1
            }
            print "  " file
        }
        prev = name
        prevfile = file
    }
')"

if [ -n "$DUPS" ]; then
    error "Duplicate terminal names detected:"
    printf '%s\n' "$DUPS"
    exit 1
fi

info "No duplicate terminal names found."
exit 0
