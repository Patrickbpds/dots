#!/bin/bash

# Heimdall Configuration Setup Script
# Sets up the new configuration location and migrates existing config

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "========================================="
echo "Heimdall Configuration Setup"
echo "========================================="
echo ""

# Step 1: Create directory structure
echo -e "${BLUE}Step 1: Creating directory structure...${NC}"
mkdir -p ~/.config/heimdall/backups
echo "✓ Created ~/.config/heimdall/"
echo "✓ Created ~/.config/heimdall/backups/"

# Step 2: Check for existing configuration
OLD_CONFIG="$HOME/.config/quickshell/heimdall/shell.json"
NEW_CONFIG="$HOME/.config/heimdall/shell.json"

if [ -f "$NEW_CONFIG" ]; then
    echo ""
    echo -e "${YELLOW}Configuration already exists at new location.${NC}"
    echo "Location: $NEW_CONFIG"
else
    if [ -f "$OLD_CONFIG" ]; then
        echo ""
        echo -e "${BLUE}Step 2: Migrating existing configuration...${NC}"
        
        # Create backup
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        BACKUP_FILE="$HOME/.config/heimdall/backups/migrated_${TIMESTAMP}.json"
        cp "$OLD_CONFIG" "$BACKUP_FILE"
        echo "✓ Created backup: $BACKUP_FILE"
        
        # Copy to new location
        cp "$OLD_CONFIG" "$NEW_CONFIG"
        echo "✓ Copied configuration to: $NEW_CONFIG"
        
        # Add migration metadata if jq is available
        if command -v jq &> /dev/null; then
            TEMP_FILE=$(mktemp)
            jq '.metadata.migratedFrom = "quickshell" | .metadata.migrationDate = now | todate' \
                "$NEW_CONFIG" > "$TEMP_FILE" && mv "$TEMP_FILE" "$NEW_CONFIG"
            echo "✓ Added migration metadata"
        fi
    else
        echo ""
        echo -e "${BLUE}Step 2: Creating default configuration...${NC}"
        
        # Create a minimal default configuration
        cat > "$NEW_CONFIG" << 'EOF'
{
  "version": "1.0.0",
  "metadata": {
    "created": "2025-08-12T00:00:00Z",
    "lastModified": "2025-08-12T00:00:00Z",
    "profile": "default",
    "managedBy": "heimdall-cli"
  },
  "system": {
    "startup": {
      "sequence": [
        {"name": "display-init", "delay": 0},
        {"name": "wallpaper-daemon", "delay": 500},
        {"name": "quickshell", "delay": 1000}
      ]
    },
    "paths": {
      "state": "~/.local/state/quickshell/user/generated",
      "cache": "~/.cache/quickshell",
      "config": "~/.config/heimdall",
      "wallpaperDir": "~/Pictures/Wallpapers"
    }
  },
  "appearance": {
    "rounding": {
      "normal": 17,
      "small": 12,
      "large": 25
    },
    "spacing": {
      "normal": 12,
      "small": 7,
      "large": 20
    },
    "font": {
      "family": {
        "sans": "System Font",
        "mono": "Monospace"
      },
      "size": {
        "normal": 13,
        "small": 11,
        "large": 18
      }
    }
  },
  "bar": {
    "enabled": true,
    "position": "top",
    "height": 30
  },
  "modules": {
    "dashboard": {"enabled": true},
    "launcher": {"enabled": true},
    "notifications": {"enabled": true}
  },
  "commands": {
    "terminal": "kitty",
    "browser": "firefox",
    "fileManager": "nemo",
    "editor": "code"
  },
  "wallpaper": {
    "current": "~/Pictures/Wallpapers/default.jpg",
    "mode": "fill"
  }
}
EOF
        echo "✓ Created default configuration: $NEW_CONFIG"
    fi
fi

# Step 3: Verify configuration
echo ""
echo -e "${BLUE}Step 3: Verifying configuration...${NC}"

if [ -f "$NEW_CONFIG" ]; then
    echo "✓ Configuration file exists"
    
    if command -v jq &> /dev/null; then
        if jq empty "$NEW_CONFIG" 2>/dev/null; then
            echo "✓ Valid JSON syntax"
            
            VERSION=$(jq -r '.version' "$NEW_CONFIG" 2>/dev/null || echo "unknown")
            echo "✓ Configuration version: $VERSION"
        else
            echo -e "${RED}✗ Invalid JSON syntax${NC}"
        fi
    else
        echo -e "${YELLOW}! Cannot validate JSON (jq not installed)${NC}"
    fi
else
    echo -e "${RED}✗ Configuration file not found${NC}"
fi

# Step 4: Summary
echo ""
echo "========================================="
echo -e "${GREEN}Setup Complete!${NC}"
echo "========================================="
echo ""
echo "Configuration location: $NEW_CONFIG"
echo "Backup directory: ~/.config/heimdall/backups/"
echo ""
echo "Next steps:"
echo "1. Quickshell Config.qml has been updated to read from the new location"
echo "2. Test that Quickshell loads the configuration correctly"
echo "3. Copy the Go implementation files to your heimdall-cli repository"
echo "4. Build and test heimdall-cli with the new config management"
echo ""
echo "Implementation files are located at:"
echo "  /home/arthur/dots/docs/implementation/heimdall-cli-config/"
echo ""
echo "To integrate with heimdall-cli:"
echo "  1. Copy config/*.go to heimdall-cli/internal/config/"
echo "  2. Copy commands/config.go to heimdall-cli/internal/commands/"
echo "  3. Run: go get github.com/spf13/cobra"
echo "  4. Build: go build ./cmd/heimdall"