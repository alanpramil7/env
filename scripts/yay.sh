#!/bin/bash
#
# AUR Helper Installation Script
# Installs yay AUR helper for managing Arch User Repository packages
#
# Usage: ./scripts/yay.sh
#
# Environment Variables:
#   ENV_DIR          Base directory for the env repository

set -euo pipefail

# Script configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly YAY_REPO="https://aur.archlinux.org/yay.git"
readonly TEMP_DIR="/tmp/yay-install-$$"

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

# Check if yay is already installed
check_yay_installed() {
    log_info "Checking if yay is installed..."
    
    if pacman -Qi yay >/dev/null 2>&1; then
        local yay_version=$(yay --version 2>/dev/null | head -n1 | cut -d' ' -f2)
        log_success "yay is already installed (version: $yay_version)"
        return 0
    else
        log_info "yay not found, proceeding with installation"
        return 1
    fi
}

# Validate system requirements
validate_requirements() {
    log_info "Validating system requirements..."
    
    # Check if we're on Arch Linux
    if ! command -v pacman >/dev/null 2>&1; then
        log_error "pacman not found - yay requires Arch Linux"
        return 1
    fi
    
    # Check for required commands
    local required_commands=("git" "makepkg" "sudo")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_error "Required command not found: $cmd"
            return 1
        fi
    done
    
    # Check if base-devel is installed
    if ! pacman -Qi base-devel >/dev/null 2>&1; then
        log_warning "base-devel package group is not installed"
        log_info "Installing base-devel..."
        
        sudo pacman -S --noconfirm --needed base-devel || {
            log_error "Failed to install base-devel"
            return 1
        }
        
        log_success "base-devel installed"
    fi
    
    log_success "System requirements validated"
    return 0
}

# Clone yay repository
clone_yay_repository() {
    log_info "Cloning yay repository..."
    
    # Create temporary directory
    mkdir -p "$TEMP_DIR" || {
        log_error "Failed to create temporary directory: $TEMP_DIR"
        return 1
    }
    
    # Clone the repository
    git clone "$YAY_REPO" "$TEMP_DIR" || {
        log_error "Failed to clone yay repository from: $YAY_REPO"
        return 1
    }
    
    log_success "yay repository cloned successfully"
    return 0
}

# Build and install yay
build_and_install_yay() {
    log_info "Building and installing yay..."
    
    # Change to build directory
    cd "$TEMP_DIR" || {
        log_error "Failed to change to build directory"
        return 1
    }
    
    # Build and install yay
    log_info "Running makepkg to build yay..."
    makepkg -si --noconfirm || {
        log_error "Failed to build and install yay"
        return 1
    }
    
    log_success "yay built and installed successfully"
    return 0
}

# Verify yay installation
verify_installation() {
    log_info "Verifying yay installation..."
    
    # Check if yay command is available
    if ! command -v yay >/dev/null 2>&1; then
        log_error "yay command not found after installation"
        return 1
    fi
    
    # Check if yay is properly installed via pacman
    if ! pacman -Qi yay >/dev/null 2>&1; then
        log_error "yay package not found in pacman database"
        return 1
    fi
    
    # Get yay version
    local yay_version=$(yay --version 2>/dev/null | head -n1 | cut -d' ' -f2)
    log_success "yay installation verified (version: $yay_version)"
    
    return 0
}

# Test yay functionality
test_yay_functionality() {
    log_info "Testing yay functionality..."
    
    # Test basic yay command
    yay --version >/dev/null 2>&1 || {
        log_error "yay --version failed"
        return 1
    }
    
    # Test AUR access
    log_info "Testing AUR access..."
    yay -Ss yay >/dev/null 2>&1 || {
        log_warning "Failed to search AUR, but yay is installed"
        log_warning "This might be a temporary network issue"
        return 0
    }
    
    log_success "yay functionality test passed"
    return 0
}

# Display usage information
show_usage_info() {
    log_info "yay AUR helper is now ready to use!"
    echo
    echo "Common yay commands:"
    echo "  yay -S <package>      # Install AUR package"
    echo "  yay -Ss <search>      # Search AUR packages"
    echo "  yay -Syu              # Update system and AUR packages"
    echo "  yay -Yc               # Clean unneeded dependencies"
    echo "  yay -Ps               # Show statistics"
    echo
    log_info "You can now install AUR packages with yay"
}

# Main execution function
main() {
    log_info "Starting yay AUR helper installation..."
    
    # Check if already installed
    if check_yay_installed; then
        return 0
    fi
    
    # Validate requirements
    if ! validate_requirements; then
        return 1
    fi
    
    # Clone repository
    if ! clone_yay_repository; then
        return 1
    fi
    
    # Build and install
    if ! build_and_install_yay; then
        return 1
    fi
    
    # Verify installation
    if ! verify_installation; then
        return 1
    fi
    
    # Test functionality
    test_yay_functionality
    
    # Show usage information
    echo
    show_usage_info
    echo
    
    log_success "yay installation completed successfully!"
    
    return 0
}

# Execute main function
main