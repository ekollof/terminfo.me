#!/bin/sh
# -----------------------------------------------------------------------------
# Terminfo Collection — install.sh
# A safe, idempotent companion script for installing terminfo entries
# from https://terminfo.me
# POSIX-compliant so it runs under any /bin/sh (bash, dash, ksh, etc.)
# -----------------------------------------------------------------------------

set -eu

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
    if [ "$(id -u)" -eq 0 ]; then
        error "This script must NOT be run as root or with sudo."
        error "It only writes to your home directory (~/.terminfo)."
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# Check if a required command is available
# ---------------------------------------------------------------------------
require_cmd() {
    _cmd="$1"
    if ! command -v "$_cmd" >/dev/null 2>&1; then
        error "Required command '$_cmd' is not installed."
        error "Please install it via your package manager and try again."
        exit 1
    fi
    unset _cmd
}

# ---------------------------------------------------------------------------
# Compute SHA-256 checksum of a file
# ---------------------------------------------------------------------------
sha256_file() {
    _file="$1"
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$_file" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$_file" | awk '{print $1}'
    else
        error "Neither sha256sum nor shasum is available."
        exit 1
    fi
    unset _file
}

# ---------------------------------------------------------------------------
# Download a .ti file
# ---------------------------------------------------------------------------
download_ti() {
    _term="$1"
    _dest="$2"
    _url="${BASE_URL}/terminfo/${_term}.ti"

    info "Downloading ${_term}.ti ..."
    if ! $CURL -o "$_dest" "$_url"; then
        error "Failed to download ${_url}"
        error "Is the term '${_term}' available in the collection?"
        return 1
    fi

    # Sanity check: downloaded file should not be empty and should look like
    # a terminfo source (first line should contain the terminal name).
    if [ ! -s "$_dest" ]; then
        error "Downloaded file is empty."
        return 1
    fi

    if ! grep -q "${_term}" "$_dest"; then
        warn "Downloaded file does not mention '${_term}'; it may be invalid."
    fi

    unset _term _dest _url
    return 0
}

# ---------------------------------------------------------------------------
# Verify checksum if available
# ---------------------------------------------------------------------------
verify_checksum() {
    _term="$1"
    _file="$2"

    _checksum_url="${BASE_URL}/terminfo/checksums.txt"
    _tmp_check="$(mktemp)"
    # Clean up temp file on exit
    _old_exit_trap="$(trap -p EXIT 2>/dev/null || true)"
    trap 'rm -f "$_tmp_check"; eval "$_old_exit_trap"' EXIT

    info "Fetching checksums ..."
    if ! $CURL -o "$_tmp_check" "$_checksum_url" 2>/dev/null; then
        warn "Could not download checksums.txt; skipping verification."
        return 0
    fi

    _expected="$(grep "^${_term}.ti" "$_tmp_check" | awk '{print $1}')"
    if [ -z "$_expected" ]; then
        warn "No checksum found for ${_term}.ti; skipping verification."
        return 0
    fi

    _actual="$(sha256_file "$_file")"

    if [ "$_actual" != "$_expected" ]; then
        error "Checksum mismatch for ${_term}.ti!"
        error "  Expected: $_expected"
        error "  Actual:   $_actual"
        return 1
    fi

    info "Checksum verified OK."
    unset _term _file _checksum_url _tmp_check _expected _actual _old_exit_trap
    return 0
}

# ---------------------------------------------------------------------------
# Check if the terminfo entry is already installed and up to date
# ---------------------------------------------------------------------------
is_already_installed() {
    _term="$1"

    # Check compiled database in ~/.terminfo
    if [ -d "$INSTALL_DIR" ]; then
        # terminfo stores files in letter-prefixed subdirectories
        _first_char="$(printf '%s' "$_term" | cut -c1)"
        if [ -f "$INSTALL_DIR/${_first_char}/${_term}" ]; then
            unset _term _first_char
            return 0
        fi
        unset _first_char
    fi

    # Also check system-wide locations as a courtesy
    if infocmp "$_term" >/dev/null 2>&1; then
        unset _term
        return 0
    fi

    unset _term
    return 1
}

# ---------------------------------------------------------------------------
# Compile and install the .ti file with tic
# ---------------------------------------------------------------------------
compile_and_install() {
    _file="$1"

    info "Compiling with tic -x ..."
    mkdir -p "$INSTALL_DIR"
    tic -x -o "$INSTALL_DIR" "$_file"
    info "Installed to ${INSTALL_DIR}"
    unset _file
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    _term=""
    _dry_run=0

    # Parse arguments
    while [ "$#" -gt 0 ]; do
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
                _dry_run=1
                shift
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                _term="$1"
                shift
                ;;
        esac
    done

    # Determine target terminal name
    if [ -z "$_term" ]; then
        _term="${TERM:-}"
        if [ -z "$_term" ]; then
            error "\$TERM is not set. Please provide a terminal name explicitly."
            usage
            exit 1
        fi
        info "Detected terminal: \$TERM=${_term}"
    else
        info "Requested terminal: ${_term}"
    fi

    # Safety checks
    ensure_no_elevated_privileges
    require_cmd curl
    require_cmd tic

    # Check if already installed
    if is_already_installed "$_term"; then
        info "Terminfo for '${_term}' appears to already be installed."
        printf '%s' "Re-install? [y/N] "
        read -r _confirm </dev/tty
        case "$_confirm" in
            [Yy])
                ;;
            *)
                info "Skipping installation."
                exit 0
                ;;
        esac
    fi

    # Prepare temporary file
    _tmpfile="$(mktemp "${TMPDIR:-/tmp}/terminfo-${_term}-XXXXXX.ti")"
    trap 'rm -f "$_tmpfile"' EXIT

    # Download
    if [ "$_dry_run" -eq 1 ]; then
        info "[dry-run] Would download ${BASE_URL}/terminfo/${_term}.ti"
    else
        if ! download_ti "$_term" "$_tmpfile"; then
            error "Download failed. Common causes:"
            error "  - The terminal '${_term}' is not yet in the collection."
            error "  - Network connectivity issues."
            error "  - BASE_URL is misconfigured."
            exit 1
        fi
    fi

    # Verify checksum (optional)
    if [ "$VERIFY_CHECKSUMS" -eq 1 ]; then
        if [ "$_dry_run" -eq 1 ]; then
            info "[dry-run] Would verify SHA-256 checksum."
        else
            if ! verify_checksum "$_term" "$_tmpfile"; then
                exit 1
            fi
        fi
    fi

    # Compile and install
    if [ "$_dry_run" -eq 1 ]; then
        info "[dry-run] Would run: tic -x -o ${INSTALL_DIR} ${_tmpfile}"
        info "[dry-run] Done."
    else
        compile_and_install "$_tmpfile"
        info "Success! '${_term}' terminfo is now installed in ${INSTALL_DIR}"
        info "You may need to restart your terminal or re-SSH for changes to take full effect."
    fi
}

main "$@"
