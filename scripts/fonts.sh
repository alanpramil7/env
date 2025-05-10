#!/bin/bash
#
# Script to download and install ComicShannsMono Nerd Font
# This script downloads the font from GitHub and installs it for the current user
#
# Usage: ./fonts

# Exit on error
set -e

echo "Checking for ComicShannsMono Nerd Font..."

# Check if font is already installed
if fc-list | grep -i "ComicShannsMono" > /dev/null; then
    echo "ComicShannsMono Nerd Font is already installed. Exiting."
    exit 0
fi

echo "ComicShannsMono Nerd Font not found. Setting up..."

# Create necessary directories
echo "Creating font directories..."
mkdir -p ~/.local/share/fonts/ || {
    echo "Error: Failed to create font directory in ~/.local/share/fonts/"
    exit 1
}

mkdir -p /tmp/font || {
    echo "Error: Failed to create temporary directory in /tmp/font/"
    exit 1
}

# Download the font
echo "Downloading ComicShannsMono Nerd Font..."
wget -P /tmp/font/ https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/ComicShannsMono.zip || {
    echo "Error: Failed to download font."
    rm -rf /tmp/font
    exit 1
}

# Unzip the font into the target directory
echo "Installing font to user directory..."
unzip -o /tmp/font/ComicShannsMono.zip -d ~/.local/share/fonts/ || {
    echo "Error: Failed to unzip font."
    rm -rf /tmp/font
    exit 1
}

# Refresh the font cache
echo "Updating font cache..."
fc-cache -v || {
    echo "Warning: Failed to update font cache. The font may not be immediately available."
}

# Clean up
echo "Cleaning up temporary files..."
rm -rf /tmp/font

echo "Font installation completed successfully."
exit 0
