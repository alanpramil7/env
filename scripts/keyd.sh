#!/bin/bash
#
# Script to install and configure keyd for keyboard remapping
# keyd is a key remapping daemon for Linux that allows for complex keyboard remapping
#
# Usage: ./keyd

# Exit on error
set -e

# Check if keyd is installed
if ! command -v keyd >/dev/null 2>&1; then
    echo "keyd not found. Installing..."

    # Clean up any previous installation attempts
    rm -rf /tmp/keyd
    
    # Clone the keyd repository
    echo "Cloning keyd repository..."
    git clone https://github.com/rvaiya/keyd /tmp/keyd || {
        echo "Error: Failed to clone keyd repository."
        exit 1
    }
    
    # Build and install keyd
    echo "Building and installing keyd..."
    cd /tmp/keyd || {
        echo "Error: Failed to change directory to /tmp/keyd."
        exit 1
    }
    
    make || {
        echo "Error: Failed to build keyd."
        exit 1
    }
    
    sudo make install || {
        echo "Error: Failed to install keyd."
        exit 1
    }
    
    sudo systemctl enable --now keyd || {
        echo "Error: Failed to enable keyd service."
        exit 1
    }
    
    # Clean up
    cd - > /dev/null
    rm -rf /tmp/keyd
    
    echo "keyd has been successfully installed."
else
    echo "keyd is already installed."
fi

# Ensure the config directory exists
echo "Creating keyd configuration directory..."
sudo mkdir -p /etc/keyd || {
    echo "Error: Failed to create /etc/keyd directory."
    exit 1
}

# Create default.conf only if it doesn't already exist
if [ ! -f /etc/keyd/default.conf ]; then
    echo "Creating /etc/keyd/default.conf..."
    sudo tee /etc/keyd/default.conf > /dev/null <<'EOF'
[ids]

*

[main]

# Maps capslock to escape when pressed and control when held.
capslock = overload(control, esc)

# Remaps the escape key to capslock
esc = capslock
EOF
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create default.conf file."
        exit 1
    fi
    
    echo "Configuration file created successfully."
else
    echo "/etc/keyd/default.conf already exists. Skipping creation."
fi

# Enable and start keyd service
echo "Enabling and starting keyd service..."
sudo systemctl enable keyd || {
    echo "Error: Failed to enable keyd service."
    exit 1
}

sudo systemctl restart keyd || {
    echo "Error: Failed to restart keyd service."
    exit 1
}

echo "keyd setup completed successfully."
exit 0
