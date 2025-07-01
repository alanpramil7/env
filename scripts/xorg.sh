#!/bin/bash

set -e

# Location for .xinitrc
XINITRC="$HOME/.xinitrc"

echo "[+] Creating or updating $XINITRC..."

cat > "$XINITRC" <<EOF
#!/bin/sh
# Keyboard repeat rate (delay 200ms, interval 30ms)
xset r rate 200 30

# Launch dwm
exec dwm
EOF

chmod +x "$XINITRC"
echo "[+] .xinitrc configured."

# Touchpad config file path
TOUCHPAD_CONF="/etc/X11/xorg.conf.d/30-touchpad.conf"

echo "[+] Creating or replacing $TOUCHPAD_CONF (requires sudo)..."

sudo mkdir -p /etc/X11/xorg.conf.d

sudo tee "$TOUCHPAD_CONF" > /dev/null <<EOF
Section "InputClass"
    Identifier "libinput touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
    Option "NaturalScrolling" "true"
    Option "DisableWhileTyping" "true"
EndSection
EOF

echo "[+] Touchpad config applied: natural scrolling + tap to click enabled."

echo "[✓] DWM xinit + touchpad setup complete."
