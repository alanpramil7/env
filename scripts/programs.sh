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
#    "hyprland"
    "wl-clipboard"
    "cliphist"
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
#    "alacritty"
    "ghostty"
    "feh"
#    "firefox"
    "brightnessctl"
    "swww"
    "mpv"
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

# Install Zig programming language
install_zig() {
    log_info "Checking Zig installation..."

    if command -v zig >/dev/null 2>&1; then
        local zig_version=$(zig version 2>/dev/null)
        log_success "Zig is already installed (version: $zig_version)"
        return 0
    fi

    log_info "Installing Zig programming language..."

    local tmp_dir=$(mktemp -d)
    local zig_url="https://ziglang.org/download/0.14.1/zig-x86_64-linux-0.14.1.tar.xz"
    local zig_tar="$tmp_dir/zig.tar.xz"

    # Create .local/bin directory if it doesn't exist
    mkdir -p "$HOME/.local/bin"

    # Download Zig
    log_info "Downloading Zig..."
    curl -L "$zig_url" -o "$zig_tar" || {
        log_error "Failed to download Zig"
        rm -rf "$tmp_dir"
        return 1
    }

    # Extract Zig
    log_info "Extracting Zig..."
    tar -xf "$zig_tar" -C "$tmp_dir" || {
        log_error "Failed to extract Zig"
        rm -rf "$tmp_dir"
        return 1
    }

    # Find the extracted directory
    local zig_dir=$(find "$tmp_dir" -name "zig-*" -type d | head -1)
    if [[ ! -d "$zig_dir" ]]; then
        log_error "Could not find extracted Zig directory"
        rm -rf "$tmp_dir"
        return 1
    fi

    # Move Zig binary and lib folder to .local/bin
    log_info "Installing Zig to ~/.local/bin..."
    cp "$zig_dir/zig" "$HOME/.local/bin/" || {
        log_error "Failed to copy Zig binary"
        rm -rf "$tmp_dir"
        return 1
    }

    # Copy lib folder
    cp -r "$zig_dir/lib" "$HOME/.local/bin/" || {
        log_error "Failed to copy Zig lib folder"
        rm -rf "$tmp_dir"
        return 1
    }

    # Make sure zig binary is executable
    chmod +x "$HOME/.local/bin/zig"

    # Clean up
    rm -rf "$tmp_dir"

    # Verify installation
    if command -v zig >/dev/null 2>&1; then
        local zig_version=$(zig version 2>/dev/null)
        log_success "Zig installed successfully (version: $zig_version)"
    else
        log_error "Zig installation verification failed"
        log_warning "Make sure ~/.local/bin is in your PATH"
        return 1
    fi

    return 0
}

# Install ZLS (Zig Language Server)
install_zls() {
    log_info "Checking ZLS installation..."

    if command -v zls >/dev/null 2>&1; then
        log_success "ZLS is already installed"
        return 0
    fi

    log_info "Installing ZLS (Zig Language Server)..."

    local tmp_dir=$(mktemp -d)
    local zls_url="https://builds.zigtools.org/zls-linux-x86_64-0.14.0.tar.xz"
    local zls_tar="$tmp_dir/zls.tar.xz"

    # Create .local/bin directory if it doesn't exist
    mkdir -p "$HOME/.local/bin"

    # Download ZLS
    log_info "Downloading ZLS..."
    curl -L "$zls_url" -o "$zls_tar" || {
        log_error "Failed to download ZLS"
        rm -rf "$tmp_dir"
        return 1
    }

    # Extract ZLS
    log_info "Extracting ZLS..."
    tar -xf "$zls_tar" -C "$tmp_dir" || {
        log_error "Failed to extract ZLS"
        rm -rf "$tmp_dir"
        return 1
    }

    # Find and move ZLS binary
    local zls_binary=$(find "$tmp_dir" -name "zls" -type f | head -1)
    if [[ ! -f "$zls_binary" ]]; then
        log_error "Could not find ZLS binary in extracted files"
        rm -rf "$tmp_dir"
        return 1
    fi

    # Move ZLS binary to .local/bin
    log_info "Installing ZLS to ~/.local/bin..."
    cp "$zls_binary" "$HOME/.local/bin/" || {
        log_error "Failed to copy ZLS binary"
        rm -rf "$tmp_dir"
        return 1
    }

    # Make sure zls binary is executable
    chmod +x "$HOME/.local/bin/zls"

    # Clean up
    rm -rf "$tmp_dir"

    # Verify installation
    if command -v zls >/dev/null 2>&1; then
        log_success "ZLS installed successfully"
    else
        log_error "ZLS installation verification failed"
        log_warning "Make sure ~/.local/bin is in your PATH"
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

    if command -v zig >/dev/null 2>&1; then
        local zig_version=$(zig version 2>/dev/null)
        echo "  Zig: $zig_version"
    fi

    if command -v zls >/dev/null 2>&1; then
        echo "  ZLS: installed"
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

    # Install Zig
    if ! install_zig; then
        log_warning "Zig installation failed, continuing with other packages"
    fi

    # Install ZLS
    if ! install_zls; then
        log_warning "ZLS installation failed, continuing with other packages"
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
