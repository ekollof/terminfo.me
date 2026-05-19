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

# Map common $TERM values to the filename used in the collection.
resolve_term() {
    case "$1" in
        xterm-kitty)
            printf '%s' "kitty"
            ;;
        xterm-ghostty)
            printf '%s' "ghostty"
            ;;
        *)
            printf '%s' "$1"
            ;;
    esac
}

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
    if ! command -v "$1" >/dev/null 2>&1; then
        error "Required command '$1' is not installed."
        error "Please install it via your package manager and try again."
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# Compute SHA-256 checksum of a file
# ---------------------------------------------------------------------------
sha256_file() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        error "Neither sha256sum nor shasum is available."
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# Download a .ti file
# ---------------------------------------------------------------------------
download_ti() {
    _dt_term="$1"
    _dt_dest="$2"
    _dt_url="${BASE_URL}/terminfo/${_dt_term}.ti"

    info "Downloading ${_dt_term}.ti ..."
    if ! $CURL -o "$_dt_dest" "$_dt_url"; then
        error "Failed to download ${_dt_url}"
        error "Is the term '${_dt_term}' available in the collection?"
        return 1
    fi

    # Sanity check: downloaded file should not be empty and should look like
    # a terminfo source (first line should contain the terminal name).
    if [ ! -s "$_dt_dest" ]; then
        error "Downloaded file is empty."
        return 1
    fi

    if ! grep -q "${_dt_term}" "$_dt_dest"; then
        warn "Downloaded file does not mention '${_dt_term}'; it may be invalid."
    fi

    return 0
}

# ---------------------------------------------------------------------------
# Verify checksum if available
# ---------------------------------------------------------------------------
verify_checksum() {
    _vc_term="$1"
    _vc_file="$2"

    _vc_checksum_url="${BASE_URL}/terminfo/checksums.txt"
    _vc_tmp_check="$(mktemp)"
    # Stack temp cleanup: prepend our cleanup to existing EXIT trap
    _vc_old_trap="$(trap | grep "^trap -- '.*' EXIT" | sed "s/^trap -- '//;s/' EXIT$//")"
    trap 'rm -f "$_vc_tmp_check"; eval "$_vc_old_trap"' EXIT

    info "Fetching checksums ..."
    if ! $CURL -o "$_vc_tmp_check" "$_vc_checksum_url" 2>/dev/null; then
        warn "Could not download checksums.txt; skipping verification."
        return 0
    fi

    _vc_expected="$(grep "^${_vc_term}.ti" "$_vc_tmp_check" | awk '{print $1}')"
    if [ -z "$_vc_expected" ]; then
        warn "No checksum found for ${_vc_term}.ti; skipping verification."
        return 0
    fi

    _vc_actual="$(sha256_file "$_vc_file")"

    if [ "$_vc_actual" != "$_vc_expected" ]; then
        error "Checksum mismatch for ${_vc_term}.ti!"
        error "  Expected: $_vc_expected"
        error "  Actual:   $_vc_actual"
        return 1
    fi

    info "Checksum verified OK."
    return 0
}

# ---------------------------------------------------------------------------
# Check if the terminfo entry is already installed and up to date
# ---------------------------------------------------------------------------
is_already_installed() {
    _iai_term="$1"

    # Check compiled database in ~/.terminfo
    if [ -d "$INSTALL_DIR" ]; then
        # terminfo stores files in letter-prefixed subdirectories
        _iai_first="$(printf '%s' "$_iai_term" | cut -c1)"
        if [ -f "$INSTALL_DIR/${_iai_first}/${_iai_term}" ]; then
            return 0
        fi
    fi

    # Also check system-wide locations as a courtesy
    if infocmp "$_iai_term" >/dev/null 2>&1; then
        return 0
    fi

    return 1
}

# ---------------------------------------------------------------------------
# Compile and install the .ti file with tic
# ---------------------------------------------------------------------------
compile_and_install() {
    info "Compiling with tic -x ..."
    mkdir -p "$INSTALL_DIR"
    tic -x -o "$INSTALL_DIR" "$1"
    info "Installed to ${INSTALL_DIR}"
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

    _term_file="$(resolve_term "$_term")"

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
    _tmpfile="$(mktemp "${TMPDIR:-/tmp}/terminfo-${_term_file}-XXXXXX.ti")"
    trap 'rm -f "$_tmpfile"' EXIT

    # Download
    if [ "$_dry_run" -eq 1 ]; then
        info "[dry-run] Would download ${BASE_URL}/terminfo/${_term_file}.ti"
    else
        if ! download_ti "$_term_file" "$_tmpfile"; then
            error "Download failed. Common causes:"
            error "  - The terminal '${_term_file}' is not yet in the collection."
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
            if ! verify_checksum "$_term_file" "$_tmpfile"; then
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
