#!/bin/bash
#
# Script to create symbolic links for configuration files
# This script sets up symlinks from the user's home directory to the configurations in the env repository
#
# Usage: ./scripts/symlinks.sh

# Exit on error
set -e

# Function to create a symlink
create_symlink() {
    local source="$1"
    local target="$2"

    echo "Setting up symlink for $target..."

    # Check if source exists
    if [ ! -e "$source" ]; then
        echo "Error: Source path $source does not exist."
        return 1
    fi

    # Remove existing target if it's a file or directory
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "Removing existing $target..."
        rm -rf "$target" || {
            echo "Error: Failed to remove $target."
            return 1
        }
    fi

    # Create parent directory if needed
    local parent_dir=$(dirname "$target")
    if [ ! -d "$parent_dir" ]; then
        echo "Creating parent directory $parent_dir..."
        mkdir -p "$parent_dir" || {
            echo "Error: Failed to create directory $parent_dir."
            return 1
        }
    fi

    # Create symlink
    echo "Creating symlink: $target -> $source"
    ln -s "$source" "$target" || {
        echo "Error: Failed to create symlink for $target."
        return 1
    }

    echo "Symlink for $target created successfully."
    return 0
}

# Get the base directory of the repository
BASE_DIR="${ENV_DIR:-$HOME/personal/env}"

# Create symlinks for each configuration
# create_symlink "$BASE_DIR/config/hypr" "$HOME/.config/hypr"
create_symlink "$BASE_DIR/config/ghostty" "$HOME/.config/ghostty"
create_symlink "$BASE_DIR/config/nvim" "$HOME/.config/nvim"
create_symlink "$BASE_DIR/config/tmux" "$HOME/.config/tmux"
create_symlink "$BASE_DIR/config/zed" "$HOME/.config/zed"
create_symlink "$BASE_DIR/config/i3" "$HOME/.config/i3"
# create_symlink "$BASE_DIR/config/waybar" "$HOME/.config/waybar"
create_symlink "$BASE_DIR/config/rofi" "$HOME/.config/rofi"
create_symlink "$BASE_DIR/config/.zshrc" "$HOME/.zshrc"

echo "All symlinks created successfully."
exit 0
