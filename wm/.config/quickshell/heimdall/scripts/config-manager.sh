#!/bin/bash
# Configuration management script for Quickshell Heimdall
# Provides backup, restore, and rollback functionality

CONFIG_DIR="$HOME/.config/quickshell/heimdall"
CONFIG_FILE="$CONFIG_DIR/shell.json"
BACKUP_DIR="$CONFIG_DIR/backups"
MAX_BACKUPS=10

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to create a backup
backup_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${RED}Error: Configuration file not found: $CONFIG_FILE${NC}"
        return 1
    fi
    
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/shell.json.$TIMESTAMP"
    
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Backup created: $BACKUP_FILE${NC}"
        
        # Clean old backups (keep only MAX_BACKUPS most recent)
        ls -t "$BACKUP_DIR"/shell.json.* 2>/dev/null | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm -f
        echo "Keeping last $MAX_BACKUPS backups"
        return 0
    else
        echo -e "${RED}✗ Failed to create backup${NC}"
        return 1
    fi
}

# Function to list available backups
list_backups() {
    echo "Available backups:"
    ls -lt "$BACKUP_DIR"/shell.json.* 2>/dev/null | head -n "$MAX_BACKUPS" | while read -r line; do
        echo "  $line"
    done
    
    if [ $(ls "$BACKUP_DIR"/shell.json.* 2>/dev/null | wc -l) -eq 0 ]; then
        echo "  No backups found"
    fi
}

# Function to restore from a backup
restore_backup() {
    local BACKUP_FILE="$1"
    
    if [ -z "$BACKUP_FILE" ]; then
        # Show list and prompt for selection
        list_backups
        echo ""
        echo "Enter backup filename to restore (or 'latest' for most recent):"
        read -r BACKUP_FILE
        
        if [ "$BACKUP_FILE" = "latest" ]; then
            BACKUP_FILE=$(ls -t "$BACKUP_DIR"/shell.json.* 2>/dev/null | head -n 1)
        fi
    fi
    
    # Handle full path or just filename
    if [ ! -f "$BACKUP_FILE" ]; then
        BACKUP_FILE="$BACKUP_DIR/$BACKUP_FILE"
    fi
    
    if [ ! -f "$BACKUP_FILE" ]; then
        echo -e "${RED}Error: Backup file not found: $BACKUP_FILE${NC}"
        return 1
    fi
    
    # Validate backup before restoring
    python3 "$CONFIG_DIR/scripts/validate-config.py" "$BACKUP_FILE"
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}Warning: Backup validation failed. Continue anyway? (y/n)${NC}"
        read -r CONFIRM
        if [ "$CONFIRM" != "y" ]; then
            echo "Restore cancelled"
            return 1
        fi
    fi
    
    # Create backup of current config before restoring
    echo "Creating backup of current configuration..."
    backup_config
    
    # Restore the backup
    cp "$BACKUP_FILE" "$CONFIG_FILE"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Configuration restored from: $BACKUP_FILE${NC}"
        
        # Trigger reload if Quickshell is running
        if pgrep -f "quickshell" > /dev/null; then
            echo "Triggering configuration reload..."
            touch "$CONFIG_FILE"
        fi
        return 0
    else
        echo -e "${RED}✗ Failed to restore configuration${NC}"
        return 1
    fi
}

# Function to validate current configuration
validate_config() {
    echo "Validating current configuration..."
    python3 "$CONFIG_DIR/scripts/validate-config.py" "$CONFIG_FILE"
    return $?
}

# Function to apply a configuration change with rollback on failure
apply_with_rollback() {
    local NEW_CONFIG="$1"
    
    if [ ! -f "$NEW_CONFIG" ]; then
        echo -e "${RED}Error: New configuration file not found: $NEW_CONFIG${NC}"
        return 1
    fi
    
    # Validate new configuration
    echo "Validating new configuration..."
    python3 "$CONFIG_DIR/scripts/validate-config.py" "$NEW_CONFIG"
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ New configuration validation failed${NC}"
        return 1
    fi
    
    # Create backup
    echo "Creating backup of current configuration..."
    backup_config
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Failed to create backup, aborting${NC}"
        return 1
    fi
    
    # Apply new configuration
    cp "$NEW_CONFIG" "$CONFIG_FILE"
    echo -e "${GREEN}✓ New configuration applied${NC}"
    
    # Wait for reload and test
    sleep 2
    
    # Simple health check - can be enhanced
    if pgrep -f "quickshell" > /dev/null; then
        echo -e "${GREEN}✓ Quickshell is running${NC}"
        return 0
    else
        echo -e "${RED}✗ Quickshell not running after configuration change${NC}"
        echo "Rolling back to previous configuration..."
        restore_backup "latest"
        return 1
    fi
}

# Function to show configuration diff
show_diff() {
    local FILE1="$1"
    local FILE2="$2"
    
    if [ -z "$FILE2" ]; then
        FILE2="$CONFIG_FILE"
    fi
    
    if [ ! -f "$FILE1" ] || [ ! -f "$FILE2" ]; then
        echo -e "${RED}Error: One or both files not found${NC}"
        return 1
    fi
    
    echo "Showing differences between configurations:"
    diff -u "$FILE1" "$FILE2" | head -50
}

# Main menu
show_menu() {
    echo ""
    echo "Quickshell Heimdall Configuration Manager"
    echo "========================================="
    echo "1. Backup current configuration"
    echo "2. List available backups"
    echo "3. Restore from backup"
    echo "4. Validate current configuration"
    echo "5. Apply new configuration (with rollback)"
    echo "6. Show configuration differences"
    echo "7. Exit"
    echo ""
    echo -n "Select option: "
}

# Parse command line arguments
case "$1" in
    backup)
        backup_config
        ;;
    list)
        list_backups
        ;;
    restore)
        restore_backup "$2"
        ;;
    validate)
        validate_config
        ;;
    apply)
        apply_with_rollback "$2"
        ;;
    diff)
        show_diff "$2" "$3"
        ;;
    *)
        # Interactive mode
        while true; do
            show_menu
            read -r OPTION
            
            case $OPTION in
                1)
                    backup_config
                    ;;
                2)
                    list_backups
                    ;;
                3)
                    restore_backup
                    ;;
                4)
                    validate_config
                    ;;
                5)
                    echo "Enter path to new configuration file:"
                    read -r NEW_CONFIG
                    apply_with_rollback "$NEW_CONFIG"
                    ;;
                6)
                    echo "Enter path to first configuration file:"
                    read -r FILE1
                    show_diff "$FILE1"
                    ;;
                7)
                    echo "Goodbye!"
                    exit 0
                    ;;
                *)
                    echo -e "${RED}Invalid option${NC}"
                    ;;
            esac
            
            echo ""
            echo "Press Enter to continue..."
            read -r
        done
        ;;
esac