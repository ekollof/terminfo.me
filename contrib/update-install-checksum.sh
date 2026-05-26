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
STATIC_FILE="$REPO_ROOT/static/install.json"

info()  { printf '[%s] %s\n' "$PROG" "$*"; }
error() { printf '[%s] ERROR: %s\n' "$PROG" "$*" >&2; }

if [ ! -f "$INSTALL_SH" ]; then
    error "install.sh not found: $INSTALL_SH"
    exit 1
fi

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

# Also copy to static/ so it's served on the site
cp "$DATA_FILE" "$STATIC_FILE"

info "Updated $DATA_FILE"
info "  sha256: $SUM"
info "  size:   $SIZE bytes"
