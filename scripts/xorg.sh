#!/bin/bash
#
# Xorg Configuration Script
# Configures Xorg settings, including .xinitrc for dwm and touchpad behavior.
#
# Usage: ./scripts/xorg.sh
#

set -euo pipefail

# Script configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly XINITRC_PATH="$HOME/.xinitrc"
readonly TOUCHPAD_CONF_PATH="/etc/X11/xorg.conf.d/30-touchpad.conf"

# ANSI color codes
readonly RED='[0;31m'
readonly GREEN='[0;32m'
readonly YELLOW='[1;33m'
readonly BLUE='[0;34m'
readonly NC='[0m'

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

# Configure .xinitrc for dwm
configure_xinitrc() {
    log_info "Configuring .xinitrc for dwm..."

    # Create or update .xinitrc
    cat > "$XINITRC_PATH" <<EOF
#!/bin/sh
# Keyboard repeat rate (delay 200ms, interval 30ms)
xset r rate 200 30

# Launch dwm
exec dwm
EOF

    # Make .xinitrc executable
    chmod +x "$XINITRC_PATH"

    log_success ".xinitrc configured successfully at: $XINITRC_PATH"
    return 0
}

# Configure touchpad settings
configure_touchpad() {
    log_info "Configuring touchpad settings..."

    # Check for sudo privileges
    if ! sudo -n true 2>/dev/null; then
        log_warning "This script requires sudo privileges to configure touchpad settings"
        log_info "You may be prompted for your password"
    fi

    # Create directory if it doesn't exist
    sudo mkdir -p "$(dirname "$TOUCHPAD_CONF_PATH")"

    # Create or replace touchpad configuration file
    sudo tee "$TOUCHPAD_CONF_PATH" > /dev/null <<EOF
Section "InputClass"
    Identifier "libinput touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
    Option "NaturalScrolling" "true"
    Option "DisableWhileTyping" "true"
    Option "ScrollMethod" "twofinger"
    Option "HorizontalScrolling" "true"
EndSection
EOF

    log_success "Touchpad configured successfully at: $TOUCHPAD_CONF_PATH"
    return 0
}

# Verify the configuration
verify_configuration() {
    log_info "Verifying Xorg configuration..."

    # Verify .xinitrc
    if [[ ! -f "$XINITRC_PATH" ]]; then
        log_error ".xinitrc file not found at: $XINITRC_PATH"
        return 1
    fi

    if ! grep -q "exec dwm" "$XINITRC_PATH"; then
        log_error "dwm not configured in .xinitrc"
        return 1
    fi

    # Verify touchpad configuration
    if [[ ! -f "$TOUCHPAD_CONF_PATH" ]]; then
        log_error "Touchpad configuration file not found at: $TOUCHPAD_CONF_PATH"
        return 1
    fi

    if ! grep -q "NaturalScrolling" "$TOUCHPAD_CONF_PATH"; then
        log_error "Touchpad settings not applied correctly"
        return 1
    fi

    log_success "Xorg configuration verified successfully"
    return 0
}

# Main execution function
main() {
    log_info "Starting Xorg configuration..."

    # Configure .xinitrc
    if ! configure_xinitrc; then
        return 1
    fi

    # Configure touchpad
    if ! configure_touchpad; then
        return 1
    fi

    # Verify configuration
    if ! verify_configuration; then
        return 1
    fi

    log_success "Xorg configuration completed successfully!"
    return 0
}

# Execute main function
main
