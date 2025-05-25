#!/bin/bash
#
# System Programs Installation Script
# Installs essential development tools and utilities using pacman
#
# Usage: ./scripts/programs.sh
#
# Environment Variables:
#   ENV_DIR          Base directory for the env repository

set -euo pipefail

# Script configuration
readonly SCRIPT_NAME="$(basename "$0")"

# ANSI color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Package lists
readonly ESSENTIAL_PACKAGES=(
    "git"
    "curl"
    "wget"
    "unzip"
    "openssh"
    "vim"
    "neovim"
    "tmux"
    "htop"
    "btop"
    "ripgrep"
    "lazygit"
    "onefetch"
    "meson"
    "clang"
)

readonly DESKTOP_PACKAGES=(
    "alacritty"
    "feh"
    "brightnessctl"
    "swww"
    "hyprlock"
    "hypridle"
    "nautilus"
    "rofi"
    "bluetui"
    "grim"
    "slurp"
)

readonly NVIDIA_PACKAGES=(
    "nvidia"
    "nvidia-utils"
    "nvidia-settings"
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

# Check if running on Arch Linux
validate_system() {
    log_info "Validating system requirements..."

    if ! command -v pacman >/dev/null 2>&1; then
        log_error "pacman not found - this script is designed for Arch Linux"
        return 1
    fi

    # Check if we can use sudo
    if ! sudo -n true 2>/dev/null; then
        log_warning "This script requires sudo privileges for package installation"
        log_info "You may be prompted for your password"
    fi

    log_success "System validation completed"
    return 0
}

# Update package database
update_package_database() {
    log_info "Updating package database..."

    sudo pacman -Sy || {
        log_error "Failed to update package database"
        return 1
    }

    log_success "Package database updated"
    return 0
}

# Install package group with validation
install_package_group() {
    local group_name="$1"
    shift
    local packages=("$@")

    log_info "Installing $group_name packages..."

    local to_install=()
    local already_installed=()

    # Check which packages need installation
    for package in "${packages[@]}"; do
        if pacman -Qi "$package" >/dev/null 2>&1; then
            already_installed+=("$package")
        else
            to_install+=("$package")
        fi
    done

    # Report already installed packages
    if [[ ${#already_installed[@]} -gt 0 ]]; then
        log_info "Already installed: ${already_installed[*]}"
    fi

    # Install new packages
    if [[ ${#to_install[@]} -gt 0 ]]; then
        log_info "Installing: ${to_install[*]}"

        sudo pacman -S --noconfirm --needed "${to_install[@]}" || {
            log_error "Failed to install $group_name packages"
            return 1
        }

        log_success "Installed ${#to_install[@]} $group_name packages"
    else
        log_success "All $group_name packages already installed"
    fi

    return 0
}

# Check if system has NVIDIA GPU
has_nvidia_gpu() {
    lspci | grep -i nvidia >/dev/null 2>&1
}

# Install NVIDIA drivers if needed
install_nvidia_drivers() {
    log_info "Checking for NVIDIA GPU..."

    if ! has_nvidia_gpu; then
        log_info "No NVIDIA GPU detected, skipping NVIDIA drivers"
        return 0
    fi

    log_info "NVIDIA GPU detected, installing drivers..."

    if ! install_package_group "NVIDIA" "${NVIDIA_PACKAGES[@]}"; then
        log_warning "NVIDIA driver installation failed"
        log_warning "You may need to install drivers manually"
        return 1
    fi

    log_success "NVIDIA drivers installed successfully"
    return 0
}

# Install Rust programming language
install_rust() {
    log_info "Checking Rust installation..."

    if command -v rustc >/dev/null 2>&1 && command -v cargo >/dev/null 2>&1; then
        local rust_version=$(rustc --version 2>/dev/null | cut -d' ' -f2)
        log_success "Rust is already installed (version: $rust_version)"
        return 0
    fi

    log_info "Installing Rust programming language..."

    # Download and install Rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || {
        log_error "Failed to install Rust"
        return 1
    }

    # Source the cargo environment
    if [[ -f "$HOME/.cargo/env" ]]; then
        source "$HOME/.cargo/env"
    fi

    # Verify installation
    if command -v rustc >/dev/null 2>&1 && command -v cargo >/dev/null 2>&1; then
        local rust_version=$(rustc --version 2>/dev/null | cut -d' ' -f2)
        log_success "Rust installed successfully (version: $rust_version)"
    else
        log_error "Rust installation verification failed"
        return 1
    fi

    return 0
}

# Verify package installations
verify_installations() {
    log_info "Verifying package installations..."

    local failed_packages=()
    local all_packages=("${ESSENTIAL_PACKAGES[@]}" "${DESKTOP_PACKAGES[@]}")

    for package in "${all_packages[@]}"; do
        if ! pacman -Qi "$package" >/dev/null 2>&1; then
            failed_packages+=("$package")
        fi
    done

    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        log_warning "Some packages failed to install: ${failed_packages[*]}"
        return 1
    fi

    log_success "All packages verified successfully"
    return 0
}

# Display installation summary
show_installation_summary() {
    log_info "Installation Summary:"

    echo "  Essential packages: ${#ESSENTIAL_PACKAGES[@]} installed"
    echo "  Desktop packages: ${#DESKTOP_PACKAGES[@]} installed"

    if has_nvidia_gpu; then
        echo "  NVIDIA packages: ${#NVIDIA_PACKAGES[@]} installed"
    fi

    if command -v rustc >/dev/null 2>&1; then
        local rust_version=$(rustc --version 2>/dev/null | cut -d' ' -f2)
        echo "  Rust: $rust_version"
    fi

    echo
    log_info "Installed applications are ready to use"
    log_info "Some applications may require a restart to function properly"
}

# Main execution function
main() {
    log_info "Starting system programs installation..."

    # Validate system
    if ! validate_system; then
        return 1
    fi

    # Update package database
    if ! update_package_database; then
        return 1
    fi

    # Install essential packages
    if ! install_package_group "essential" "${ESSENTIAL_PACKAGES[@]}"; then
        return 1
    fi

    # Install desktop packages
    if ! install_package_group "desktop" "${DESKTOP_PACKAGES[@]}"; then
        return 1
    fi

    # Install NVIDIA drivers if needed
    install_nvidia_drivers

    # Install Rust
    if ! install_rust; then
        log_warning "Rust installation failed, continuing with other packages"
    fi

    # Verify installations
    verify_installations

    # Show summary
    echo
    show_installation_summary
    echo

    log_success "Programs installation completed successfully!"

    return 0
}

# Execute main function
main
