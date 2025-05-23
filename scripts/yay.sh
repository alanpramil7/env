#!/usr/bin/env bash
#
# Script to install the yay AUR helper if not already installed
# yay is an AUR helper written in Go that allows you to install AUR packages
#
# Usage: ./yay

# Check if yay is already installed
if pacman -Qi yay >/dev/null 2>&1; then
    echo "yay is already installed."
    exit 0
else
    echo "yay is not installed. Installing yay..."

    # Clean up any previous installation attempts
    rm -rf /tmp/yay

    # Clone the yay repository
    echo "Cloning yay repository..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay || {
        echo "Error: Failed to clone yay repository."
        exit 1
    }

    # Build and install yay
    echo "Building and installing yay..."
    cd /tmp/yay || {
        echo "Error: Failed to change directory to /tmp/yay."
        exit 1
    }

    # -s: Install dependencies
    # -i: Install the package after building
    makepkg -si || {
        echo "Error: Failed to build and install yay."
        exit 1
    }

    # Clean up
    cd - > /dev/null
    rm -rf /tmp/yay

    echo "yay has been successfully installed."
    exit 0
fi
