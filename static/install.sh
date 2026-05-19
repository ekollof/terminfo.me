#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Terminfo Collection — install.sh
# A safe, idempotent companion script for installing terminfo entries
# from https://terminfo.me
# -----------------------------------------------------------------------------

set -euo pipefail

# Base URL where raw .ti files are hosted.
# Override with: export TERMINFO_BASE_URL="https://example.com/terminfo"
BASE_URL="${TERMINFO_BASE_URL:-https://terminfo.me}"

# Where to install compiled terminfo entries.
INSTALL_DIR="${HOME}/.terminfo"

# Whether to verify SHA-256 checksums.
VERIFY_CHECKSUMS="${TERMINFO_VERIFY:-0}"

# Curl command with common flags for safety.
CURL="curl -fsSL --connect-timeout 10 --max-time 30"

# ---------------------------------------------------------------------------
# Print usage
# ---------------------------------------------------------------------------
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [TERMINAL_NAME]

Install a terminfo entry from the Terminfo Collection into ~/.terminfo.

Options:
  -h, --help     Show this help message and exit
  -v, --verify   Enable SHA-256 checksum verification
  --dry-run      Show what would be done without making changes

Arguments:
  TERMINAL_NAME  Name of the terminal to install (defaults to \$TERM)

Examples:
  $(basename "$0")              # Auto-detect and install current \$TERM
  $(basename "$0") alacritty    # Explicitly install alacritty terminfo
  $(basename "$0") --verify     # Verify checksums during install
EOF
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()  { printf '\033[1;32m[info]\033[0m  %s\n' "$*"; }
warn()  { printf '\033[1;33m[warn]\033[0m  %s\n' "$*" >&2; }
error() { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; }

# ---------------------------------------------------------------------------
# Ensure we never run as root / with sudo
# ---------------------------------------------------------------------------
ensure_no_elevated_privileges() {
    if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
        error "This script must NOT be run as root or with sudo."
        error "It only writes to your home directory (~/.terminfo)."
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# Check if a required command is available
# ---------------------------------------------------------------------------
require_cmd() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        error "Required command '$cmd' is not installed."
        error "Please install it via your package manager and try again."
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# Compute SHA-256 checksum of a file
# ---------------------------------------------------------------------------
sha256_file() {
    local file="$1"
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file" | awk '{print $1}'
    else
        error "Neither sha256sum nor shasum is available."
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# Download a .ti file
# ---------------------------------------------------------------------------
download_ti() {
    local term="$1"
    local dest="$2"
    local url="${BASE_URL}/terminfo/${term}.ti"

    info "Downloading ${term}.ti ..."
    if ! $CURL -o "$dest" "$url"; then
        error "Failed to download ${url}"
        error "Is the term '${term}' available in the collection?"
        return 1
    fi

    # Sanity check: downloaded file should not be empty and should look like
    # a terminfo source (first line should contain the terminal name).
    if [[ ! -s "$dest" ]]; then
        error "Downloaded file is empty."
        return 1
    fi

    if ! grep -q "${term}" "$dest"; then
        warn "Downloaded file does not mention '${term}'; it may be invalid."
    fi

    return 0
}

# ---------------------------------------------------------------------------
# Verify checksum if available
# ---------------------------------------------------------------------------
verify_checksum() {
    local term="$1"
    local file="$2"

    local checksum_url="${BASE_URL}/terminfo/checksums.txt"
    local tmp_check
    tmp_check=$(mktemp)
    trap 'rm -f "$tmp_check"' RETURN

    info "Fetching checksums ..."
    if ! $CURL -o "$tmp_check" "$checksum_url" 2>/dev/null; then
        warn "Could not download checksums.txt; skipping verification."
        return 0
    fi

    local expected
    expected=$(grep "^${term}.ti" "$tmp_check" | awk '{print $1}')
    if [[ -z "$expected" ]]; then
        warn "No checksum found for ${term}.ti; skipping verification."
        return 0
    fi

    local actual
    actual=$(sha256_file "$file")

    if [[ "$actual" != "$expected" ]]; then
        error "Checksum mismatch for ${term}.ti!"
        error "  Expected: $expected"
        error "  Actual:   $actual"
        return 1
    fi

    info "Checksum verified OK."
    return 0
}

# ---------------------------------------------------------------------------
# Check if the terminfo entry is already installed and up to date
# ---------------------------------------------------------------------------
is_already_installed() {
    local term="$1"

    # Check compiled database in ~/.terminfo
    if [[ -d "$INSTALL_DIR" ]]; then
        # terminfo stores files in letter-prefixed subdirectories
        local first_char
        first_char=$(printf '%s' "$term" | cut -c1)
        if [[ -f "$INSTALL_DIR/${first_char}/${term}" ]]; then
            return 0
        fi
    fi

    # Also check system-wide locations as a courtesy
    if infocmp "$term" >/dev/null 2>&1; then
        return 0
    fi

    return 1
}

# ---------------------------------------------------------------------------
# Compile and install the .ti file with tic
# ---------------------------------------------------------------------------
compile_and_install() {
    local file="$1"

    info "Compiling with tic -x ..."
    mkdir -p "$INSTALL_DIR"
    tic -x -o "$INSTALL_DIR" "$file"
    info "Installed to ${INSTALL_DIR}"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    local term=""
    local dry_run=0

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verify)
                VERIFY_CHECKSUMS=1
                shift
                ;;
            --dry-run)
                dry_run=1
                shift
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                term="$1"
                shift
                ;;
        esac
    done

    # Determine target terminal name
    if [[ -z "$term" ]]; then
        term="${TERM:-}"
        if [[ -z "$term" ]]; then
            error "\$TERM is not set. Please provide a terminal name explicitly."
            usage
            exit 1
        fi
        info "Detected terminal: \$TERM=${term}"
    else
        info "Requested terminal: ${term}"
    fi

    # Safety checks
    ensure_no_elevated_privileges
    require_cmd curl
    require_cmd tic

    # Check if already installed
    if is_already_installed "$term"; then
        info "Terminfo for '${term}' appears to already be installed."
        read -r -p "Re-install? [y/N] " confirm </dev/tty
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            info "Skipping installation."
            exit 0
        fi
    fi

    # Prepare temporary file
    local tmpfile
    tmpfile=$(mktemp "${TMPDIR:-/tmp}/terminfo-${term}-XXXXXX.ti")
    trap 'rm -f "$tmpfile"' EXIT

    # Download
    if [[ "$dry_run" -eq 1 ]]; then
        info "[dry-run] Would download ${BASE_URL}/terminfo/${term}.ti"
    else
        if ! download_ti "$term" "$tmpfile"; then
            error "Download failed. Common causes:"
            error "  - The terminal '${term}' is not yet in the collection."
            error "  - Network connectivity issues."
            error "  - BASE_URL is misconfigured."
            exit 1
        fi
    fi

    # Verify checksum (optional)
    if [[ "$VERIFY_CHECKSUMS" -eq 1 ]]; then
        if [[ "$dry_run" -eq 1 ]]; then
            info "[dry-run] Would verify SHA-256 checksum."
        else
            if ! verify_checksum "$term" "$tmpfile"; then
                exit 1
            fi
        fi
    fi

    # Compile and install
    if [[ "$dry_run" -eq 1 ]]; then
        info "[dry-run] Would run: tic -x -o ${INSTALL_DIR} ${tmpfile}"
        info "[dry-run] Done."
    else
        compile_and_install "$tmpfile"
        info "Success! '${term}' terminfo is now installed in ${INSTALL_DIR}"
        info "You may need to restart your terminal or re-SSH for changes to take full effect."
    fi
}

main "$@"
