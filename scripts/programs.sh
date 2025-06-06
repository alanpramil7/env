#!/usr/bin/env bash
#
# Script for installing essential system programs using pacman
# This script installs base development tools and utilities
#
# Usage: ./programs

# Set exit on error
set -e

echo "Installing essential programs..."

# Install base development packages and utilities
# --noconfirm: Don't ask for confirmation
# --needed: Don't reinstall packages that are already installed
sudo pacman -S --noconfirm --needed \
    git \
    alacritty \
    feh \ 
    brightnessctl \
    vim \
    openssh \
    curl \
    unzip \
    wget \
    neovim \
    nvidia \
    nvidia-utils \
    nvidia-settings \
    lazygit \
    nautilus \
    rofi \
    btop \
    htop \
    tmux \
    ripgrep \
    onefetch \
    meson \
    clang \
    bluetui \
    grim \
    slurp

# Check if installation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to install packages."
    exit 1
fi

echo "Base packages installed successfully."

# Optional: Install packages from AUR using yay
# Uncomment if needed:
# yay -S --noconfirm zed-preview-bin

# Installing rust if not already installed
if ! command -v rustc &> /dev/null || ! command -v cargo &> /dev/null; then
    echo "Rust not found. Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
else
    echo "Rust is already installed."
fi

exit 0
