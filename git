#!/usr/bin/env bash
#
# Script to configure global Git settings
# Sets up default user email and name for Git commits
#
# Usage: ./git

# Exit on error
set -e

echo "Configuring Git global settings..."

# Set user email
echo "Setting Git user email..."
git config --global user.email "alanpramil7@gmail.com" || {
    echo "Error: Failed to set Git user email."
    exit 1
}

# Set user name
echo "Setting Git user name..."
git config --global user.name "Alan" || {
    echo "Error: Failed to set Git user name."
    exit 1
}

# Optional: Configure additional Git settings if needed
# git config --global core.editor "nvim"
# git config --global pull.rebase false

echo "Git configuration completed successfully."
exit 0
