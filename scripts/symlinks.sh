#!/bin/bash
#
# Configuration Management Symlink Script
# Creates symbolic links from home directory to configuration files in the env repository
#
# Usage: ./scripts/symlinks.sh
#
# Environment Variables:
#   ENV_DIR          Base directory for the env repository

set -euo pipefail

# Script configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Expand tilde in ENV_DIR if it's set, otherwise use script location
if [[ -n "${ENV_DIR:-}" ]]; then
    readonly BASE_DIR="${ENV_DIR/#\~/$HOME}"
else
    readonly BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

# Global flags
FORCE=true
VERBOSE=false

# ANSI color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration mapping: source_path:target_path
readonly SYMLINK_CONFIG=(
    "config/hypr:$HOME/.config/hypr"
    "config/ghostty:$HOME/.config/ghostty"
    "config/nvim:$HOME/.config/nvim"
    "config/tmux:$HOME/.config/tmux"
    "config/htop:$HOME/.config/htop"
    "config/zed:$HOME/.config/zed"
    # "config/i3:$HOME/.config/i3"
    "config/alacritty:$HOME/.config/alacritty"
    "config/wezterm:$HOME/.config/wezterm"
    "config/waybar:$HOME/.config/waybar"
    "config/rofi:$HOME/.config/rofi"
    "config/wofi:$HOME/.config/wofi"
    "config/.zshrc:$HOME/.zshrc"
)

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_verbose() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${BLUE}[VERBOSE]${NC} $*"
    fi
}



# Validate environment and prerequisites
validate_environment() {
    log_verbose "Validating environment..."

    if [[ ! -d "$BASE_DIR" ]]; then
        log_error "Base directory does not exist: $BASE_DIR"
        log_error "Set ENV_DIR environment variable or ensure the default path exists."
        return 1
    fi

    log_verbose "Base directory validated: $BASE_DIR"

    # Check if we can write to home directory
    if [[ ! -w "$HOME" ]]; then
        log_error "Cannot write to home directory: $HOME"
        return 1
    fi

    return 0
}

# Check if target exists and what type it is
get_target_status() {
    local target="$1"

    if [[ -L "$target" ]]; then
        echo "symlink"
    elif [[ -f "$target" ]]; then
        echo "file"
    elif [[ -d "$target" ]]; then
        echo "directory"
    else
        echo "none"
    fi
}

# Handle existing target based on type and force flag
handle_existing_target() {
    local target="$1"
    local target_status="$2"

    case "$target_status" in
        "none")
            return 0
            ;;
        "symlink")
            local current_link=$(readlink "$target" 2>/dev/null || echo "broken")
            log_verbose "Found existing symlink: $target -> $current_link"
            ;;
        "file")
            log_verbose "Found existing file: $target"
            ;;
        "directory")
            log_verbose "Found existing directory: $target"
            ;;
    esac

    if [[ "$FORCE" == false ]]; then
        log_warning "Target exists: $target (use --force to overwrite)"
        return 1
    fi

    log_verbose "Removing existing target: $target"
    rm -rf "$target" || {
        log_error "Failed to remove existing target: $target"
        return 1
    }

    return 0
}

# Create parent directory if needed
ensure_parent_directory() {
    local target="$1"
    local parent_dir=$(dirname "$target")

    if [[ ! -d "$parent_dir" ]]; then
        log_verbose "Creating parent directory: $parent_dir"
        mkdir -p "$parent_dir" || {
            log_error "Failed to create parent directory: $parent_dir"
            return 1
        }
    fi

    return 0
}

# Create a single symlink
create_symlink() {
    local source_rel="$1"
    local target="$2"
    local source="$BASE_DIR/$source_rel"

    log_verbose "Processing: $source_rel -> $target"

    # Validate source exists
    if [[ ! -e "$source" ]]; then
        log_error "Source does not exist: $source"
        return 1
    fi

    # Check target status
    local target_status=$(get_target_status "$target")

    # Handle existing target
    if ! handle_existing_target "$target" "$target_status"; then
        return 1
    fi

    # Ensure parent directory exists
    if ! ensure_parent_directory "$target"; then
        return 1
    fi

    # Create symlink
    ln -s "$source" "$target" || {
        log_error "Failed to create symlink: $target -> $source"
        return 1
    }
    log_success "Created symlink: $target -> $source"

    return 0
}

# Process all symlinks from configuration
process_symlinks() {
    local success_count=0
    local error_count=0

    log_info "Processing ${#SYMLINK_CONFIG[@]} symlink configurations..."

    for config_entry in "${SYMLINK_CONFIG[@]}"; do
        IFS=':' read -r source_path target_path <<< "$config_entry"

        if create_symlink "$source_path" "$target_path"; then
            ((success_count++))
        else
            ((error_count++))
            log_error "Failed to process: $source_path -> $target_path"
        fi
    done

    # Summary
    echo
    log_info "Symlink creation completed. $success_count successful, $error_count failed."

    return $error_count
}

# Main execution function
main() {
    # Show configuration if verbose
    if [[ "$VERBOSE" == true ]]; then
        log_verbose "Configuration:"
        log_verbose "  Base directory: $BASE_DIR"
        log_verbose "  Force: $FORCE"
        log_verbose "  Verbose: $VERBOSE"
        echo
    fi

    # Validate environment
    if ! validate_environment; then
        exit 1
    fi

    # Process symlinks
    if ! process_symlinks; then
        exit 1
    fi

    log_success "All symlink operations completed successfully!"
}

# Execute main function
main
