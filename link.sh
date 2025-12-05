#!/bin/bash

# Script to link dotfiles from this repository to the home directory
# Usage: ./link.sh

set -e  # Exit on error

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to create symlink with backup handling
link_file() {
    local source="$1"
    local target="$2"
    
    # Check if target already exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
            echo -e "${GREEN}✓${NC} Already linked: $target"
            return 0
        else
            echo -e "${YELLOW}⚠${NC}  $target already exists"
            echo -e "   Backing up to ${target}.backup"
            mv "$target" "${target}.backup"
        fi
    fi
    
    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    
    # Create symlink
    ln -s "$source" "$target"
    echo -e "${GREEN}✓${NC} Linked: $target -> $source"
}

echo "Linking dotfiles from $DOTFILES_DIR to $HOME_DIR"
echo ""

# Link bashrc
link_file "$DOTFILES_DIR/bashrc" "$HOME_DIR/.bashrc"

# Link profile
link_file "$DOTFILES_DIR/profile" "$HOME_DIR/.profile"

# Link gitconfig
link_file "$DOTFILES_DIR/gitconfig" "$HOME_DIR/.gitconfig"

# Link aliases (as bash_aliases)
link_file "$DOTFILES_DIR/aliases" "$HOME_DIR/.bash_aliases"

# Link nvim config
link_file "$DOTFILES_DIR/config/nvim/init.lua" "$HOME_DIR/.config/nvim/init.lua"

echo ""
echo -e "${GREEN}Done!${NC} All dotfiles have been linked."
echo ""
echo "Note: If any files were backed up, they are saved with a .backup extension."
echo "To apply changes to bashrc, run: source ~/.bashrc"
