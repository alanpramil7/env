#!/bin/bash
#
# Script to install and configure Zsh with Oh My Zsh
# Sets up Zsh as default shell and installs Oh My Zsh framework
#
# Usage: ./zsh

# Exit on error
set -e

echo "Installing Zsh..."
# Install Zsh if not already installed
sudo pacman -S zsh --noconfirm --needed || {
    echo "Error: Failed to install Zsh."
    exit 1
}

echo "Setting Zsh as default shell..."
# Change default shell to Zsh
sudo chsh -s /usr/bin/zsh $USER || {
    echo "Error: Failed to set Zsh as default shell."
    exit 1
}

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
        echo "Error: Failed to install Oh My Zsh."
        exit 1
    }
    echo "Oh My Zsh installed successfully."
else
    echo "Oh My Zsh is already installed."
fi

echo "Zsh setup completed successfully."
exit 0