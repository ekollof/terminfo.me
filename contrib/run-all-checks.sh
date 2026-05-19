#!/bin/sh
# -----------------------------------------------------------------------------
# run-all-checks.sh — Run all validation checks on the terminfo collection
# -----------------------------------------------------------------------------
# Usage:
#   contrib/run-all-checks.sh [FILE.ti ...]
#
# If no arguments are given, all .ti files under static/terminfo/ are checked.
# Exits with 0 if all checks pass, 1 if any check fails.
# -----------------------------------------------------------------------------

set -e

PROG="$(basename "$0")"
CONTRIB_DIR="$(cd "$(dirname "$0")" && pwd)"
ERRORS=0

info()  { printf '[%s] %s\n' "$PROG" "$*"; }
error() { printf '[%s] ERROR: %s\n' "$PROG" "$*" >&2; }

# Determine target files
if [ $# -gt 0 ]; then
    FILES="$*"
else
    FILES=""
fi

run_check() {
    SCRIPT="$1"
    shift
    info "--- Running $(basename "$SCRIPT") ---"
    if "$SCRIPT" "$@"; then
        info "--- $(basename "$SCRIPT") passed ---"
    else
        error "--- $(basename "$SCRIPT") FAILED ---"
        ERRORS=$((ERRORS + 1))
    fi
    printf '\n'
}

info "Starting validation checks..."
printf '\n'

# Run each check
run_check "$CONTRIB_DIR/check-syntax.sh" $FILES
run_check "$CONTRIB_DIR/check-headers.sh" $FILES
run_check "$CONTRIB_DIR/check-duplicates.sh" $FILES
run_check "$CONTRIB_DIR/check-checksums.sh"

if [ "$ERRORS" -gt 0 ]; then
    error "$ERRORS check(s) failed. Please fix the issues above."
    exit 1
fi

info "All checks passed!"
exit 0
