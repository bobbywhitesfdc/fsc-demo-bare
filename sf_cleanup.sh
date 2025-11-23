#!/bin/bash

# SF CLI Cleanup Script
# Removes duplicate/conflicting Salesforce CLI installations
# WARNING: Review and uncomment only the sections you need!

echo "=========================================="
echo "SF CLI Cleanup Script"
echo "=========================================="
echo ""
echo "⚠️  WARNING: This script will remove SF CLI installations"
echo "Make sure you have backed up your auth data first!"
echo ""
read -p "Have you run the backup script? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Please run the backup script first. Exiting."
    exit 1
fi
echo ""

# Function to remove standalone installation
remove_standalone() {
    echo "Removing standalone installation..."
    
    # Try using the official uninstaller first
    if [ -f /usr/local/bin/sfdx ]; then
        echo "Attempting to use official uninstaller..."
        /usr/local/bin/sfdx uninstall 2>/dev/null
    fi
    
    # Manual removal
    echo "Removing standalone files..."
    sudo rm -rf /usr/local/bin/sf
    sudo rm -rf /usr/local/bin/sfdx
    sudo rm -rf /usr/local/lib/sfdx
    echo "  ✓ Standalone installation removed"
}

# Function to remove npm installations
remove_npm() {
    echo "Removing npm global installations..."
    npm uninstall -g sfdx-cli 2>/dev/null
    npm uninstall -g @salesforce/cli 2>/dev/null
    echo "  ✓ NPM installations removed"
}

# Function to remove and reinstall Homebrew version
reinstall_homebrew() {
    echo "Reinstalling Homebrew version..."
    brew uninstall salesforce-cli 2>/dev/null
    echo "  ✓ Uninstalled old version"
    echo "Installing fresh version..."
    brew install salesforce-cli
    echo "  ✓ Fresh installation complete"
}

# Main cleanup logic
echo "Select cleanup option:"
echo "1) Remove standalone only (keep Homebrew)"
echo "2) Remove npm only (keep Homebrew)"
echo "3) Remove standalone + npm (keep Homebrew)"
echo "4) Reinstall Homebrew version fresh"
echo "5) Remove ALL and reinstall Homebrew only"
echo "0) Cancel"
echo ""
read -p "Enter option (0-5): " option

case $option in
    1)
        remove_standalone
        ;;
    2)
        remove_npm
        ;;
    3)
        remove_standalone
        remove_npm
        ;;
    4)
        reinstall_homebrew
        ;;
    5)
        remove_standalone
        remove_npm
        reinstall_homebrew
        ;;
    0)
        echo "Cleanup cancelled."
        exit 0
        ;;
    *)
        echo "Invalid option. Exiting."
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "Cleanup Complete"
echo "=========================================="
echo ""
echo "Verifying installation..."
which sf
echo ""
sf version
echo ""
echo "Testing org connectivity..."
sf org list
echo ""
echo "If any orgs show as disconnected, re-authenticate with:"
echo "  sf org login web --alias ALIAS_NAME"
