#!/bin/bash

# Remove Standalone SF CLI Installation
# This script removes the standalone installer and switches to Homebrew version

echo "=========================================="
echo "Remove Standalone SF CLI Installation"
echo "=========================================="
echo ""

# Verify Homebrew installation exists
if [ ! -f /opt/homebrew/bin/sf ]; then
    echo "❌ ERROR: Homebrew SF CLI not found at /opt/homebrew/bin/sf"
    echo "Please ensure Homebrew version is installed first:"
    echo "  brew install salesforce-cli"
    exit 1
fi

echo "✓ Homebrew SF CLI found at /opt/homebrew/bin/sf"
echo ""

# Show what will be removed
echo "The following will be removed:"
echo "  - /usr/local/lib/sf/"
echo "  - /usr/local/bin/sf"
echo "  - /usr/local/bin/sfdx"
echo ""

read -p "Continue with removal? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Removal cancelled."
    exit 0
fi

echo ""
echo "Removing standalone installation..."

# Remove the main installation directory
if [ -d /usr/local/lib/sf ]; then
    echo "Removing /usr/local/lib/sf/..."
    sudo rm -rf /usr/local/lib/sf
    if [ $? -eq 0 ]; then
        echo "  ✓ Removed /usr/local/lib/sf/"
    else
        echo "  ❌ Failed to remove /usr/local/lib/sf/"
        exit 1
    fi
else
    echo "  ℹ /usr/local/lib/sf/ not found"
fi

# Remove symlinks
if [ -L /usr/local/bin/sf ]; then
    echo "Removing /usr/local/bin/sf symlink..."
    sudo rm /usr/local/bin/sf
    echo "  ✓ Removed /usr/local/bin/sf"
else
    echo "  ℹ /usr/local/bin/sf not found"
fi

if [ -L /usr/local/bin/sfdx ]; then
    echo "Removing /usr/local/bin/sfdx symlink..."
    sudo rm /usr/local/bin/sfdx
    echo "  ✓ Removed /usr/local/bin/sfdx"
else
    echo "  ℹ /usr/local/bin/sfdx not found"
fi

echo ""
echo "=========================================="
echo "Removal Complete"
echo "=========================================="
echo ""

# Verify the switch
echo "Verifying Homebrew SF CLI is now active..."
echo ""

# Force shell to recognize the change
hash -r 2>/dev/null

echo "Current sf location:"
which sf
echo ""

echo "Current sf version:"
sf version --verbose
echo ""

echo "Testing org connectivity..."
sf org list --all
echo ""

# Check if PATH needs adjustment
current_sf=$(which sf)
if [[ "$current_sf" != "/opt/homebrew/bin/sf" ]]; then
    echo "⚠️  WARNING: sf command is not pointing to Homebrew installation"
    echo "Current location: $current_sf"
    echo ""
    echo "You may need to adjust your PATH. Add this to your ~/.zshrc:"
    echo '  export PATH="/opt/homebrew/bin:$PATH"'
    echo ""
    echo "Then run: source ~/.zshrc"
else
    echo "✓ SUCCESS: Now using Homebrew SF CLI"
    echo ""
    echo "Your org connections should be intact."
    echo "If any orgs show issues, re-authenticate with:"
    echo "  sf org login web --alias ALIAS_NAME"
fi

echo ""
echo "=========================================="
