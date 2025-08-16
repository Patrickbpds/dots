#!/bin/bash

# Heimdall Configuration Migration Script
# Migrates shell.json from Quickshell location to Heimdall location

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration paths
OLD_CONFIG="$HOME/.config/quickshell/heimdall/shell.json"
NEW_CONFIG="$HOME/.config/heimdall/shell.json"
NEW_CONFIG_DIR="$HOME/.config/heimdall"
BACKUP_DIR="$HOME/.config/heimdall/backups"

echo "========================================="
echo "Heimdall Configuration Migration Script"
echo "========================================="
echo ""

# Check if new config already exists
if [ -f "$NEW_CONFIG" ]; then
    echo -e "${YELLOW}Warning:${NC} Configuration already exists at $NEW_CONFIG"
    echo "No migration needed."
    exit 0
fi

# Check if old config exists
if [ ! -f "$OLD_CONFIG" ]; then
    echo -e "${YELLOW}Info:${NC} No existing configuration found at $OLD_CONFIG"
    echo "A new configuration will be created when heimdall-cli runs."
    exit 0
fi

echo "Found existing configuration at: $OLD_CONFIG"
echo "Will migrate to: $NEW_CONFIG"
echo ""

# Create directories
echo "Creating configuration directories..."
mkdir -p "$NEW_CONFIG_DIR"
mkdir -p "$BACKUP_DIR"

# Create backup with timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/migrated_from_quickshell_${TIMESTAMP}.json"

echo "Creating backup at: $BACKUP_FILE"
cp "$OLD_CONFIG" "$BACKUP_FILE"

# Copy configuration to new location
echo "Migrating configuration..."
cp "$OLD_CONFIG" "$NEW_CONFIG"

# Add migration metadata
echo "Adding migration metadata..."
if command -v jq &> /dev/null; then
    # Use jq if available to add metadata
    jq '.metadata.migratedFrom = "quickshell" | .metadata.migrationDate = now | todate' \
        "$NEW_CONFIG" > "$NEW_CONFIG.tmp" && mv "$NEW_CONFIG.tmp" "$NEW_CONFIG"
else
    echo -e "${YELLOW}Note:${NC} jq not found, skipping metadata update"
fi

echo ""
echo -e "${GREEN}✓ Migration completed successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. The Quickshell configuration files have been updated to read from the new location"
echo "2. Test that Quickshell loads the configuration correctly"
echo "3. Run 'heimdall config check' to validate the configuration"
echo "4. Once verified, you can remove the old configuration at: $OLD_CONFIG"
echo ""
echo "Backup created at: $BACKUP_FILE"