#!/bin/bash
# Setup script to make m4btomp3 callable from anywhere in bash
# This script sets up m4btomp3 for Unix-like systems (Linux, macOS)

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}m4btomp3 Setup for Bash${NC}"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Make the main script executable
echo "Making m4btomp3.py executable..."
chmod +x "$SCRIPT_DIR/m4btomp3.py"

# For user-only installation (recommended):
echo "Installing to ~/.local/bin..."
mkdir -p ~/.local/bin
cp "$SCRIPT_DIR/m4btomp3.py" ~/.local/bin/m4btomp3
chmod +x ~/.local/bin/m4btomp3

# Add ~/.local/bin to PATH if not already there
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "Adding ~/.local/bin to PATH..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    
    # Also add to ~/.bash_profile for macOS login shells
    if [ -f ~/.bash_profile ]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bash_profile
    fi
    
    echo ""
    echo -e "${GREEN}✓ Setup complete!${NC}"
    echo ""
    echo "Please run one of the following to update your current shell:"
    echo "  source ~/.bashrc          # For bash"
    echo "  source ~/.bash_profile    # For macOS login shells"
else
    echo -e "${GREEN}✓ Setup complete!${NC}"
    echo "~/.local/bin is already in your PATH"
fi

echo ""
echo "You can now call m4btomp3 from anywhere:"
echo "  m4btomp3 <input_file> <output_folder>"
echo "  m4btomp3 --help"
echo ""
echo "Example:"
echo "  m4btomp3 audiobook.m4b output_folder"
echo "  m4btomp3 book.m4b chapters/ --separator \"-\""
