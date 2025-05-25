#!/bin/bash
#
# Font Installation Script
# Downloads and installs ComicShannsMono Nerd Font for the current user
#
# Usage: ./scripts/fonts.sh
#
# Environment Variables:
#   ENV_DIR          Base directory for the env repository

set -euo pipefail

# Script configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly FONT_NAME="ComicShannsMono"
readonly FONT_VERSION="v3.4.0"
readonly FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/${FONT_NAME}.zip"
readonly FONT_DIR="$HOME/.local/share/fonts"
readonly TEMP_DIR="/tmp/font-install-$$"

# ANSI color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

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

# Cleanup function
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        log_info "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
}

# Set up cleanup trap
trap cleanup EXIT

# Check if font is already installed
check_font_installed() {
    log_info "Checking if $FONT_NAME Nerd Font is installed..."
    
    # Check if font files exist in the font directory
    if find "$FONT_DIR" -name "*${FONT_NAME}*" -type f 2>/dev/null | grep -q .; then
        log_success "$FONT_NAME Nerd Font files found in $FONT_DIR"
        return 0
    fi
    
    # Check using fc-list for ComicShannsMono variations
    if fc-list | grep -iq "ComicShannsMono" >/dev/null 2>&1; then
        log_success "$FONT_NAME Nerd Font is already installed"
        return 0
    fi
    
    log_info "$FONT_NAME Nerd Font not found, proceeding with installation"
    return 1
}

# Validate system requirements
validate_requirements() {
    log_info "Validating system requirements..."
    
    # Check for required commands
    local required_commands=("wget" "unzip" "fc-cache" "fc-list")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_error "Required command not found: $cmd"
            log_error "Please install the required packages and try again"
            return 1
        fi
    done
    
    log_info "All required commands are available"
    return 0
}

# Create necessary directories
setup_directories() {
    log_info "Setting up directories..."
    
    # Create font directory
    if [[ ! -d "$FONT_DIR" ]]; then
        log_info "Creating font directory: $FONT_DIR"
        mkdir -p "$FONT_DIR" || {
            log_error "Failed to create font directory: $FONT_DIR"
            return 1
        }
    fi
    
    # Create temporary directory
    log_info "Creating temporary directory: $TEMP_DIR"
    mkdir -p "$TEMP_DIR" || {
        log_error "Failed to create temporary directory: $TEMP_DIR"
        return 1
    }
    
    log_info "Directories setup completed"
    return 0
}

# Download font archive
download_font() {
    log_info "Downloading $FONT_NAME Nerd Font from GitHub..."
    log_info "Source: $FONT_URL"
    
    local font_archive="$TEMP_DIR/${FONT_NAME}.zip"
    
    wget -O "$font_archive" "$FONT_URL" || {
        log_error "Failed to download font from: $FONT_URL"
        return 1
    }
    
    # Verify download
    if [[ ! -f "$font_archive" ]] || [[ ! -s "$font_archive" ]]; then
        log_error "Downloaded file is missing or empty: $font_archive"
        return 1
    fi
    
    log_success "Font archive downloaded successfully"
    return 0
}

# Extract and install font
install_font() {
    log_info "Installing font to user directory..."
    
    local font_archive="$TEMP_DIR/${FONT_NAME}.zip"
    
    # Extract font files
    unzip -o "$font_archive" -d "$FONT_DIR" || {
        log_error "Failed to extract font archive: $font_archive"
        return 1
    }
    
    # Count installed font files
    local font_count=$(find "$FONT_DIR" -name "*${FONT_NAME}*" -type f | wc -l)
    
    if [[ $font_count -eq 0 ]]; then
        log_error "No font files were installed"
        return 1
    fi
    
    log_success "Installed $font_count font files"
    return 0
}

# Update font cache
update_font_cache() {
    log_info "Updating font cache..."
    
    fc-cache -fv "$FONT_DIR" || {
        log_warning "Failed to update font cache completely"
        log_warning "Font may not be immediately available in all applications"
        return 1
    }
    
    log_success "Font cache updated successfully"
    return 0
}

# Verify installation
verify_installation() {
    log_info "Verifying font installation..."
    
    # Give font cache a moment to update
    sleep 2
    
    # Try multiple ways to verify the font installation
    local font_found=false
    
    # Check 1: Look for any ComicShannsMono font files
    if find "$FONT_DIR" -name "*${FONT_NAME}*" -type f | grep -q .; then
        log_info "Font files found in directory"
        font_found=true
    fi
    
    # Check 2: Use fc-list to find the font
    if fc-list | grep -iq "ComicShannsMono" >/dev/null 2>&1; then
        log_info "Font found in font cache"
        font_found=true
    fi
    
    if [[ "$font_found" == true ]]; then
        log_success "$FONT_NAME Nerd Font installation verified"
        
        # Show available font variants
        log_info "Available font variants:"
        fc-list | grep -i "ComicShannsMono" | cut -d: -f2 | sort | sed 's/^/  /' || echo "  (Font cache still updating)"
        
        return 0
    else
        log_error "Font installation verification failed"
        log_error "Font may not be properly installed or cached"
        return 1
    fi
}

# Main execution function
main() {
    log_info "Starting $FONT_NAME Nerd Font installation..."
    
    # Check if already installed - exit early if found
    if check_font_installed; then
        log_success "Font installation completed successfully!"
        return 0
    fi
    
    # Validate requirements
    if ! validate_requirements; then
        return 1
    fi
    
    # Setup directories
    if ! setup_directories; then
        return 1
    fi
    
    # Download font
    if ! download_font; then
        return 1
    fi
    
    # Install font
    if ! install_font; then
        return 1
    fi
    
    # Update font cache
    update_font_cache
    
    # Verify installation
    if ! verify_installation; then
        return 1
    fi
    
    log_success "Font installation completed successfully!"
    log_info "You may need to restart applications to see the new font"
    
    return 0
}

# Execute main function
main