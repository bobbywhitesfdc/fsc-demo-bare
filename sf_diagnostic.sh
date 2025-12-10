#!/bin/bash

# SF CLI Installation Diagnostic Script
# This script identifies all Salesforce CLI installations on your Mac

echo "=========================================="
echo "Salesforce CLI Installation Diagnostic"
echo "=========================================="
echo ""

echo "1. Checking which sf/sfdx commands are active:"
echo "---"
which sf 2>/dev/null || echo "sf command not found"
which sfdx 2>/dev/null || echo "sfdx command not found"
echo ""

echo "2. Finding all sf command locations:"
echo "---"
which -a sf 2>/dev/null || echo "No sf commands found"
echo ""

echo "3. Checking Homebrew installations:"
echo "---"
brew list 2>/dev/null | grep -i salesforce || echo "No Salesforce packages found in Homebrew"
echo ""

echo "4. Checking standalone installer locations:"
echo "---"
if [ -f /usr/local/bin/sf ]; then
    echo "Found: /usr/local/bin/sf"
    ls -lh /usr/local/bin/sf
else
    echo "Not found: /usr/local/bin/sf"
fi

if [ -f /usr/local/bin/sfdx ]; then
    echo "Found: /usr/local/bin/sfdx"
    ls -lh /usr/local/bin/sfdx
else
    echo "Not found: /usr/local/bin/sfdx"
fi

if [ -d /usr/local/lib/sfdx ]; then
    echo "Found: /usr/local/lib/sfdx/"
    ls -lh /usr/local/lib/sfdx/
else
    echo "Not found: /usr/local/lib/sfdx/"
fi

if [ -d ~/sf ]; then
    echo "Found: ~/sf/"
    ls -lh ~/sf/
else
    echo "Not found: ~/sf/"
fi

if [ -d ~/sfdx ]; then
    echo "Found: ~/sfdx/"
    ls -lh ~/sfdx/
else
    echo "Not found: ~/sfdx/"
fi
echo ""

echo "5. Checking npm global installations:"
echo "---"
if command -v npm &> /dev/null; then
    npm list -g --depth=0 2>/dev/null | grep -i sfdx || echo "No sfdx npm packages found"
    npm list -g --depth=0 2>/dev/null | grep -i salesforce || echo "No salesforce npm packages found"
else
    echo "npm not installed or not in PATH"
fi
echo ""

echo "6. Current SF CLI version and location:"
echo "---"
if command -v sf &> /dev/null; then
    sf version --verbose
else
    echo "sf command not available"
fi
echo ""

echo "7. Checking shell configuration for SF/SFDX PATH entries:"
echo "---"
for config_file in ~/.zshrc ~/.bash_profile ~/.bashrc ~/.profile; do
    if [ -f "$config_file" ]; then
        echo "Checking $config_file:"
        grep -i -E '(sf|sfdx)' "$config_file" 2>/dev/null || echo "  No SF/SFDX entries found"
        echo ""
    fi
done

echo "=========================================="
echo "Diagnostic Complete"
echo "=========================================="
