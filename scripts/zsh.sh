#!/bin/bash
#
# Shell Configuration Script
# Installs and configures Zsh with Oh My Zsh framework
#
# Usage: ./scripts/zsh.sh
#
# Environment Variables:
#   ENV_DIR          Base directory for the env repository

set -euo pipefail

# Script configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly ZSH_SHELL="/usr/bin/zsh"
readonly OH_MY_ZSH_INSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
readonly OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"

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

# Validate system requirements
validate_requirements() {
    log_info "Validating system requirements..."
    
    # Check if we can use sudo
    if ! sudo -n true 2>/dev/null; then
        log_warning "This script requires sudo privileges for package installation"
        log_info "You may be prompted for your password"
    fi
    
    # Check for required commands
    local required_commands=("pacman" "curl" "chsh")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_error "Required command not found: $cmd"
            return 1
        fi
    done
    
    log_success "System requirements validated"
    return 0
}

# Check if Zsh is installed
check_zsh_installed() {
    log_info "Checking Zsh installation..."
    
    if pacman -Qi zsh >/dev/null 2>&1; then
        local zsh_version=$(zsh --version 2>/dev/null | cut -d' ' -f2)
        log_success "Zsh is already installed (version: $zsh_version)"
        return 0
    else
        log_info "Zsh not found, proceeding with installation"
        return 1
    fi
}

# Install Zsh package
install_zsh() {
    log_info "Installing Zsh shell..."
    
    sudo pacman -S --noconfirm --needed zsh || {
        log_error "Failed to install Zsh"
        return 1
    }
    
    # Verify installation
    if [[ ! -f "$ZSH_SHELL" ]]; then
        log_error "Zsh installation failed - shell not found at: $ZSH_SHELL"
        return 1
    fi
    
    log_success "Zsh installed successfully"
    return 0
}

# Check current default shell
get_current_shell() {
    getent passwd "$USER" | cut -d: -f7
}

# Set Zsh as default shell
configure_default_shell() {
    log_info "Configuring Zsh as default shell..."
    
    local current_shell=$(get_current_shell)
    
    if [[ "$current_shell" == "$ZSH_SHELL" ]]; then
        log_success "Zsh is already the default shell"
        return 0
    fi
    
    log_info "Current shell: $current_shell"
    log_info "Changing default shell to: $ZSH_SHELL"
    
    # Change default shell
    sudo chsh -s "$ZSH_SHELL" "$USER" || {
        log_error "Failed to set Zsh as default shell"
        return 1
    }
    
    log_success "Default shell changed to Zsh"
    log_warning "You will need to log out and back in for the shell change to take effect"
    
    return 0
}

# Check if Oh My Zsh is installed
check_oh_my_zsh_installed() {
    log_info "Checking Oh My Zsh installation..."
    
    if [[ -d "$OH_MY_ZSH_DIR" ]]; then
        log_success "Oh My Zsh is already installed"
        return 0
    else
        log_info "Oh My Zsh not found, proceeding with installation"
        return 1
    fi
}

# Install Oh My Zsh framework
install_oh_my_zsh() {
    log_info "Installing Oh My Zsh framework..."
    
    # Download and run the installation script
    sh -c "$(curl -fsSL $OH_MY_ZSH_INSTALL_URL)" "" --unattended || {
        log_error "Failed to install Oh My Zsh"
        return 1
    }
    
    # Verify installation
    if [[ ! -d "$OH_MY_ZSH_DIR" ]]; then
        log_error "Oh My Zsh installation failed - directory not found: $OH_MY_ZSH_DIR"
        return 1
    fi
    
    log_success "Oh My Zsh installed successfully"
    return 0
}

# Configure Oh My Zsh settings
configure_oh_my_zsh() {
    log_info "Configuring Oh My Zsh..."
    
    local zshrc_file="$HOME/.zshrc"
    
    if [[ ! -f "$zshrc_file" ]]; then
        log_warning "No .zshrc file found, Oh My Zsh will create one"
        return 0
    fi
    
    # Check if existing .zshrc is not from Oh My Zsh and inform user
    if ! grep -q "oh-my-zsh" "$zshrc_file" 2>/dev/null; then
        log_info "Existing .zshrc will be overwritten by Oh My Zsh installation"
    fi
    
    log_success "Oh My Zsh configuration completed"
    return 0
}

# Install useful Zsh plugins
install_zsh_plugins() {
    log_info "Installing useful Zsh plugins..."
    
    local plugins_dir="$OH_MY_ZSH_DIR/custom/plugins"
    
    if [[ ! -d "$plugins_dir" ]]; then
        log_warning "Oh My Zsh plugins directory not found: $plugins_dir"
        return 1
    fi
    
    # Install zsh-autosuggestions
    local autosuggestions_dir="$plugins_dir/zsh-autosuggestions"
    if [[ ! -d "$autosuggestions_dir" ]]; then
        log_info "Installing zsh-autosuggestions plugin..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$autosuggestions_dir" || {
            log_warning "Failed to install zsh-autosuggestions plugin"
        }
    fi
    
    # Install zsh-syntax-highlighting
    local syntax_highlighting_dir="$plugins_dir/zsh-syntax-highlighting"
    if [[ ! -d "$syntax_highlighting_dir" ]]; then
        log_info "Installing zsh-syntax-highlighting plugin..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$syntax_highlighting_dir" || {
            log_warning "Failed to install zsh-syntax-highlighting plugin"
        }
    fi
    
    log_success "Zsh plugins installation completed"
    return 0
}

# Verify Zsh installation and configuration
verify_installation() {
    log_info "Verifying Zsh installation and configuration..."
    
    # Check if Zsh is installed
    if ! command -v zsh >/dev/null 2>&1; then
        log_error "Zsh command not found after installation"
        return 1
    fi
    
    # Check if Zsh shell file exists
    if [[ ! -f "$ZSH_SHELL" ]]; then
        log_error "Zsh shell file not found: $ZSH_SHELL"
        return 1
    fi
    
    # Check if Oh My Zsh is installed
    if [[ ! -d "$OH_MY_ZSH_DIR" ]]; then
        log_error "Oh My Zsh directory not found: $OH_MY_ZSH_DIR"
        return 1
    fi
    
    # Test Zsh functionality
    zsh --version >/dev/null 2>&1 || {
        log_error "Zsh version check failed"
        return 1
    }
    
    log_success "Zsh installation and configuration verified"
    return 0
}

# Display configuration information
show_configuration_info() {
    local current_shell=$(get_current_shell)
    local zsh_version=$(zsh --version 2>/dev/null | cut -d' ' -f2)
    
    log_info "Zsh Configuration Summary:"
    echo "  Zsh version: $zsh_version"
    echo "  Zsh location: $ZSH_SHELL"
    echo "  Current default shell: $current_shell"
    echo "  Oh My Zsh directory: $OH_MY_ZSH_DIR"
    
    if [[ "$current_shell" != "$ZSH_SHELL" ]]; then
        echo
        log_warning "Default shell is not yet Zsh"
        log_info "Log out and back in to use Zsh as your default shell"
    fi
    
    echo
    log_info "Available features:"
    echo "  - Oh My Zsh framework with themes and plugins"
    echo "  - Auto-suggestions for commands"
    echo "  - Syntax highlighting"
    echo "  - Git integration and aliases"
    
    echo
    log_info "To customize your shell, edit: $HOME/.zshrc"
    log_info "To change themes, modify the ZSH_THEME variable in .zshrc"
}

# Main execution function
main() {
    log_info "Starting Zsh shell configuration..."
    
    # Validate requirements
    if ! validate_requirements; then
        return 1
    fi
    
    # Install Zsh if needed
    if ! check_zsh_installed; then
        if ! install_zsh; then
            return 1
        fi
    fi
    
    # Configure default shell
    if ! configure_default_shell; then
        return 1
    fi
    
    # Install Oh My Zsh if needed
    if ! check_oh_my_zsh_installed; then
        if ! install_oh_my_zsh; then
            return 1
        fi
        
        # Configure Oh My Zsh
        configure_oh_my_zsh
    fi
    
    # Install useful plugins
    install_zsh_plugins
    
    # Verify installation
    if ! verify_installation; then
        return 1
    fi
    
    # Show configuration info
    echo
    show_configuration_info
    echo
    
    log_success "Zsh setup completed successfully!"
    
    return 0
}

# Execute main function
main