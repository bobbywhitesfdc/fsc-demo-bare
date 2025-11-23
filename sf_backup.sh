#!/bin/bash

# SF CLI Authentication Backup Script
# Backs up your SF CLI authentication data before cleanup

BACKUP_DIR=~/sf_cli_backup_$(date +%Y%m%d_%H%M%S)

echo "=========================================="
echo "SF CLI Authentication Backup"
echo "=========================================="
echo ""
echo "Creating backup directory: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Backup SF directory
if [ -d ~/.sf ]; then
    echo "Backing up ~/.sf/..."
    cp -r ~/.sf "$BACKUP_DIR/sf"
    echo "  ✓ Backed up to $BACKUP_DIR/sf"
else
    echo "  ℹ ~/.sf directory not found"
fi

# Backup SFDX directory
if [ -d ~/.sfdx ]; then
    echo "Backing up ~/.sfdx/..."
    cp -r ~/.sfdx "$BACKUP_DIR/sfdx"
    echo "  ✓ Backed up to $BACKUP_DIR/sfdx"
else
    echo "  ℹ ~/.sfdx directory not found"
fi

# Export org list
if command -v sf &> /dev/null; then
    echo "Exporting org list..."
    sf org list --all --json > "$BACKUP_DIR/myorgs.json" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "  ✓ Org list saved to $BACKUP_DIR/myorgs.json"
    else
        echo "  ⚠ Could not export org list"
    fi
else
    echo "  ℹ sf command not available"
fi

echo ""
echo "=========================================="
echo "Backup Complete"
echo "Location: $BACKUP_DIR"
echo "=========================================="
echo ""
echo "To restore later if needed:"
echo "  cp -r $BACKUP_DIR/sf ~/.sf"
echo "  cp -r $BACKUP_DIR/sfdx ~/.sfdx"
