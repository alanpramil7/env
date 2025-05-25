#!/bin/bash
#
# Keyboard Remapping Configuration Script
# Installs and configures keyd for keyboard remapping on Linux
#
# Usage: ./scripts/keyd.sh
#
# Environment Variables:
#   ENV_DIR          Base directory for the env repository

set -euo pipefail

# Script configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly KEYD_REPO="https://github.com/rvaiya/keyd"
readonly KEYD_CONFIG_DIR="/etc/keyd"
readonly KEYD_CONFIG_FILE="$KEYD_CONFIG_DIR/default.conf"
readonly TEMP_DIR="/tmp/keyd-install-$$"

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

# Check if keyd is already installed
check_keyd_installed() {
    log_info "Checking if keyd is installed..."
    
    if command -v keyd >/dev/null 2>&1; then
        local keyd_version=$(keyd --version 2>/dev/null || echo "unknown")
        log_success "keyd is already installed (version: $keyd_version)"
        return 0
    else
        log_info "keyd not found, proceeding with installation"
        return 1
    fi
}

# Validate system requirements
validate_requirements() {
    log_info "Validating system requirements..."
    
    # Check for required commands
    local required_commands=("git" "make" "sudo")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_error "Required command not found: $cmd"
            return 1
        fi
    done
    
    # Check if we can use sudo
    if ! sudo -n true 2>/dev/null; then
        log_warning "This script requires sudo privileges for installation"
        log_info "You may be prompted for your password"
    fi
    
    log_info "System requirements validated"
    return 0
}

# Install keyd from source
install_keyd() {
    log_info "Installing keyd from source..."
    
    # Create temporary directory
    mkdir -p "$TEMP_DIR" || {
        log_error "Failed to create temporary directory: $TEMP_DIR"
        return 1
    }
    
    # Clone repository
    log_info "Cloning keyd repository..."
    git clone "$KEYD_REPO" "$TEMP_DIR" || {
        log_error "Failed to clone keyd repository from: $KEYD_REPO"
        return 1
    }
    
    # Build keyd
    log_info "Building keyd..."
    cd "$TEMP_DIR" || {
        log_error "Failed to change to temporary directory"
        return 1
    }
    
    make || {
        log_error "Failed to build keyd"
        return 1
    }
    
    # Install keyd
    log_info "Installing keyd system-wide..."
    sudo make install || {
        log_error "Failed to install keyd"
        return 1
    }
    
    log_success "keyd installation completed"
    return 0
}

# Create keyd configuration directory
setup_config_directory() {
    log_info "Setting up keyd configuration directory..."
    
    if [[ ! -d "$KEYD_CONFIG_DIR" ]]; then
        log_info "Creating keyd config directory: $KEYD_CONFIG_DIR"
        sudo mkdir -p "$KEYD_CONFIG_DIR" || {
            log_error "Failed to create keyd config directory"
            return 1
        }
    fi
    
    log_success "Configuration directory ready"
    return 0
}

# Create keyd configuration file
create_config_file() {
    log_info "Creating keyd configuration..."
    
    if [[ -f "$KEYD_CONFIG_FILE" ]]; then
        log_info "Configuration file already exists, overwriting: $KEYD_CONFIG_FILE"
    fi
    
    log_info "Writing keyd configuration to: $KEYD_CONFIG_FILE"
    sudo tee "$KEYD_CONFIG_FILE" > /dev/null <<'EOF'
[ids]

*

[main]

# Maps capslock to escape when pressed and control when held.
capslock = overload(control, esc)

# Remaps the escape key to capslock
esc = capslock
EOF
    
    if [[ $? -ne 0 ]]; then
        log_error "Failed to create keyd configuration file"
        return 1
    fi
    
    log_success "Configuration file created successfully"
    return 0
}

# Manage keyd service
manage_keyd_service() {
    log_info "Managing keyd systemd service..."
    
    # Enable keyd service
    log_info "Enabling keyd service..."
    sudo systemctl enable keyd || {
        log_error "Failed to enable keyd service"
        return 1
    }
    
    # Start/restart keyd service
    log_info "Starting keyd service..."
    if systemctl is-active --quiet keyd; then
        log_info "Restarting keyd service to apply new configuration..."
        sudo systemctl restart keyd || {
            log_error "Failed to restart keyd service"
            return 1
        }
    else
        sudo systemctl start keyd || {
            log_error "Failed to start keyd service"
            return 1
        }
    fi
    
    log_success "keyd service is running"
    return 0
}

# Verify keyd installation and service
verify_installation() {
    log_info "Verifying keyd installation..."
    
    # Check if keyd command is available
    if ! command -v keyd >/dev/null 2>&1; then
        log_error "keyd command not found after installation"
        return 1
    fi
    
    # Check if service is running
    if ! systemctl is-active --quiet keyd; then
        log_error "keyd service is not running"
        return 1
    fi
    
    # Check if configuration file exists
    if [[ ! -f "$KEYD_CONFIG_FILE" ]]; then
        log_error "keyd configuration file not found: $KEYD_CONFIG_FILE"
        return 1
    fi
    
    log_success "keyd installation and configuration verified"
    
    # Show service status
    log_info "keyd service status:"
    systemctl status keyd --no-pager --lines=3 || true
    
    return 0
}

# Display configuration information
show_configuration_info() {
    log_info "Current keyd configuration:"
    echo "  Configuration file: $KEYD_CONFIG_FILE"
    echo "  Active mappings:"
    echo "    - CapsLock → Escape (when pressed) / Control (when held)"
    echo "    - Escape → CapsLock"
    echo
    log_info "To modify the configuration, edit: $KEYD_CONFIG_FILE"
    log_info "After making changes, restart keyd: sudo systemctl restart keyd"
}

# Main execution function
main() {
    log_info "Starting keyd installation and configuration..."
    
    # Check if already installed
    if check_keyd_installed; then
        log_info "Proceeding with configuration setup..."
    else
        # Validate requirements
        if ! validate_requirements; then
            return 1
        fi
        
        # Install keyd
        if ! install_keyd; then
            return 1
        fi
    fi
    
    # Setup configuration
    if ! setup_config_directory; then
        return 1
    fi
    
    if ! create_config_file; then
        return 1
    fi
    
    # Manage service
    if ! manage_keyd_service; then
        return 1
    fi
    
    # Verify installation
    if ! verify_installation; then
        return 1
    fi
    
    # Show configuration info
    echo
    show_configuration_info
    echo
    
    log_success "keyd setup completed successfully!"
    log_info "Your keyboard remapping is now active"
    
    return 0
}

# Execute main function
main