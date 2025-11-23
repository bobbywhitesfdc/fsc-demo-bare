#!/bin/bash

# Fix SF CLI Symlinks After Homebrew Update
# Resolves version mismatch between installed and running versions

echo "=========================================="
echo "SF CLI Symlink Diagnostic & Fix"
echo "=========================================="
echo ""

echo "1. Current sf command location and target:"
echo "---"
sf_location=$(which sf)
echo "which sf: $sf_location"
if [ -L "$sf_location" ]; then
    echo "Links to: $(readlink $sf_location)"
    echo "Real path: $(realpath $sf_location)"
fi
echo ""

echo "2. Checking all possible sf locations:"
echo "---"
which -a sf
echo ""

echo "3. Checking Homebrew Cask installation:"
echo "---"
if [ -d "/opt/homebrew/Caskroom/salesforce-cli" ]; then
    echo "Cask directory exists:"
    ls -la /opt/homebrew/Caskroom/salesforce-cli/
    echo ""
    
    # Find the actual sf binary in the cask
    echo "Looking for sf binary in cask..."
    find /opt/homebrew/Caskroom/salesforce-cli -name "sf" -type f 2>/dev/null
    echo ""
else
    echo "No cask directory found"
fi

echo "4. Checking /opt/homebrew/bin/:"
echo "---"
if [ -e /opt/homebrew/bin/sf ]; then
    ls -la /opt/homebrew/bin/sf
    if [ -L /opt/homebrew/bin/sf ]; then
        echo "Links to: $(readlink /opt/homebrew/bin/sf)"
    fi
else
    echo "No sf in /opt/homebrew/bin/"
fi
echo ""

echo "5. Checking /usr/local/bin/:"
echo "---"
if [ -e /usr/local/bin/sf ]; then
    ls -la /usr/local/bin/sf
    if [ -L /usr/local/bin/sf ]; then
        echo "Links to: $(readlink /usr/local/bin/sf)"
    fi
else
    echo "No sf in /usr/local/bin/"
fi
echo ""

echo "=========================================="
echo "Fix Options"
echo "=========================================="
echo ""
echo "The issue: Homebrew cask installs to a different location"
echo "than expected, causing version mismatch."
echo ""
echo "Choose a fix option:"
echo "1) Reinstall as Homebrew formula (not cask) - Recommended"
echo "2) Fix symlinks to point to cask installation"
echo "3) Reinstall via standalone installer"
echo "0) Cancel"
echo ""
read -p "Enter option (0-3): " option

case $option in
    1)
        echo ""
        echo "Reinstalling as Homebrew formula..."
        brew uninstall --cask salesforce-cli
        brew install salesforce-cli
        echo ""
        echo "Testing..."
        which sf
        sf version
        ;;
    2)
        echo ""
        echo "Finding cask binary location..."
        cask_sf=$(find /opt/homebrew/Caskroom/salesforce-cli -name "sf" -type f 2>/dev/null | head -1)
        if [ -z "$cask_sf" ]; then
            echo "❌ Could not find sf binary in cask installation"
            exit 1
        fi
        echo "Found: $cask_sf"
        echo ""
        echo "Creating symlink..."
        sudo ln -sf "$cask_sf" /opt/homebrew/bin/sf
        sudo ln -sf "$cask_sf" /opt/homebrew/bin/sfdx
        echo "✓ Symlinks created"
        echo ""
        echo "Testing..."
        hash -r
        which sf
        sf version
        ;;
    3)
        echo ""
        echo "Uninstalling Homebrew version..."
        brew uninstall --cask salesforce-cli 2>/dev/null
        brew uninstall salesforce-cli 2>/dev/null
        echo ""
        echo "Please download and install from:"
        echo "https://developer.salesforce.com/tools/salesforcecli"
        echo ""
        echo "Or install via npm:"
        echo "npm install -g @salesforce/cli"
        ;;
    0)
        echo "Cancelled."
        exit 0
        ;;
    *)
        echo "Invalid option."
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "Complete"
echo "=========================================="
