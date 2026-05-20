#!/bin/sh
# -----------------------------------------------------------------------------
# update-install-checksum.sh — Regenerate data/install.json from static/install.sh
# -----------------------------------------------------------------------------
# Usage:
#   contrib/update-install-checksum.sh
#
# Computes the SHA-256 of static/install.sh and writes it to data/install.json
# so Hugo can read it at render time via .Site.Data.install.sha256
# -----------------------------------------------------------------------------

set -e

PROG="$(basename "$0")"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALL_SH="$REPO_ROOT/static/install.sh"
DATA_FILE="$REPO_ROOT/data/install.json"

info()  { printf '[%s] %s\n' "$PROG" "$*"; }
error() { printf '[%s] ERROR: %s\n' "$PROG" "$*" >&2; }

if [ ! -f "$INSTALL_SH" ]; then
    error "install.sh not found: $INSTALL_SH"
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

SUM="$($SHA_CMD "$INSTALL_SH" | eval "$SHA_PARSE")"
SIZE="$(wc -c < "$INSTALL_SH" | tr -d ' ')"
DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

mkdir -p "$(dirname "$DATA_FILE")"

cat > "$DATA_FILE" <<EOF
{
  "filename": "install.sh",
  "sha256": "$SUM",
  "size": $SIZE,
  "updated": "$DATE"
}
EOF

info "Updated $DATA_FILE"
info "  sha256: $SUM"
info "  size:   $SIZE bytes"
