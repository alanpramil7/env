#!/bin/bash
#
# Git Configuration Script
# Sets up global Git settings and configuration for development environment
#
# Usage: ./scripts/git.sh
#
# Environment Variables:
#   ENV_DIR          Base directory for the env repository

set -euo pipefail

# Script configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly GIT_USER_EMAIL="alanpramil7@gmail.com"
readonly GIT_USER_NAME="Alan"

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

# Check if Git is installed
validate_git_installation() {
    log_info "Validating Git installation..."
    
    if ! command -v git >/dev/null 2>&1; then
        log_error "Git is not installed"
        log_error "Please install Git and try again"
        return 1
    fi
    
    local git_version=$(git --version 2>/dev/null | cut -d' ' -f3)
    log_info "Git version: $git_version"
    return 0
}

# Get current Git configuration
get_current_config() {
    local config_key="$1"
    git config --global "$config_key" 2>/dev/null || echo ""
}

# Set Git configuration with validation
set_git_config() {
    local config_key="$1"
    local config_value="$2"
    local description="$3"
    
    local current_value=$(get_current_config "$config_key")
    
    if [[ "$current_value" == "$config_value" ]]; then
        log_info "$description is already set to: $config_value"
        return 0
    fi
    
    if [[ -n "$current_value" ]]; then
        log_warning "$description is currently set to: $current_value"
        log_info "Updating to: $config_value"
    else
        log_info "Setting $description to: $config_value"
    fi
    
    git config --global "$config_key" "$config_value" || {
        log_error "Failed to set $description"
        return 1
    }
    
    log_success "$description configured successfully"
    return 0
}

# Configure user information
configure_user_info() {
    log_info "Configuring Git user information..."
    
    if ! set_git_config "user.email" "$GIT_USER_EMAIL" "Git user email"; then
        return 1
    fi
    
    if ! set_git_config "user.name" "$GIT_USER_NAME" "Git user name"; then
        return 1
    fi
    
    return 0
}

# Configure additional Git settings
configure_additional_settings() {
    log_info "Configuring additional Git settings..."
    
    # Set default editor to neovim if available, otherwise vim
    local editor="vim"
    if command -v nvim >/dev/null 2>&1; then
        editor="nvim"
    fi
    
    if ! set_git_config "core.editor" "$editor" "Git default editor"; then
        return 1
    fi
    
    # Set default branch name
    if ! set_git_config "init.defaultBranch" "main" "Default branch name"; then
        return 1
    fi
    
    # Configure pull behavior
    if ! set_git_config "pull.rebase" "false" "Pull rebase behavior"; then
        return 1
    fi
    
    # Enable color output
    if ! set_git_config "color.ui" "auto" "Color output"; then
        return 1
    fi
    
    # Configure line ending handling
    if ! set_git_config "core.autocrlf" "input" "Line ending handling"; then
        return 1
    fi
    
    return 0
}

# Display current Git configuration
show_git_config() {
    log_info "Current Git configuration:"
    
    local config_items=(
        "user.name:User name"
        "user.email:User email"
        "core.editor:Default editor"
        "init.defaultBranch:Default branch"
        "pull.rebase:Pull rebase"
        "color.ui:Color output"
        "core.autocrlf:Line endings"
    )
    
    for item in "${config_items[@]}"; do
        IFS=':' read -r key desc <<< "$item"
        local value=$(get_current_config "$key")
        if [[ -n "$value" ]]; then
            echo "  $desc: $value"
        else
            echo "  $desc: (not set)"
        fi
    done
}

# Verify configuration
verify_configuration() {
    log_info "Verifying Git configuration..."
    
    local user_email=$(get_current_config "user.email")
    local user_name=$(get_current_config "user.name")
    
    if [[ "$user_email" != "$GIT_USER_EMAIL" ]]; then
        log_error "Git user email verification failed"
        log_error "Expected: $GIT_USER_EMAIL, Got: $user_email"
        return 1
    fi
    
    if [[ "$user_name" != "$GIT_USER_NAME" ]]; then
        log_error "Git user name verification failed"
        log_error "Expected: $GIT_USER_NAME, Got: $user_name"
        return 1
    fi
    
    log_success "Git configuration verified successfully"
    return 0
}

# Main execution function
main() {
    log_info "Starting Git configuration..."
    
    # Validate Git installation
    if ! validate_git_installation; then
        return 1
    fi
    
    # Configure user information
    if ! configure_user_info; then
        return 1
    fi
    
    # Configure additional settings
    if ! configure_additional_settings; then
        return 1
    fi
    
    # Verify configuration
    if ! verify_configuration; then
        return 1
    fi
    
    # Show final configuration
    echo
    show_git_config
    echo
    
    log_success "Git configuration completed successfully!"
    return 0
}

# Execute main function
main