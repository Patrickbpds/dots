#!/usr/bin/env bash

# Migration script to copy illogical-impulse config to heimdall
# Run this script to migrate your existing ii configuration

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
II_CONFIG_DIR="$XDG_CONFIG_HOME/illogical-impulse"
HEIMDALL_CONFIG_DIR="$XDG_CONFIG_HOME/heimdall"

echo "Heimdall Configuration Migration Script"
echo "======================================="

if [ -d "$II_CONFIG_DIR" ]; then
    echo "Found existing illogical-impulse configuration at: $II_CONFIG_DIR"
    
    if [ -d "$HEIMDALL_CONFIG_DIR" ]; then
        echo "Heimdall config directory already exists. Creating backup..."
        mv "$HEIMDALL_CONFIG_DIR" "$HEIMDALL_CONFIG_DIR.backup.$(date +%s)"
    fi
    
    echo "Copying illogical-impulse config to heimdall..."
    cp -r "$II_CONFIG_DIR" "$HEIMDALL_CONFIG_DIR"
    
    echo "Migration completed successfully!"
    echo "Your illogical-impulse configuration has been copied to: $HEIMDALL_CONFIG_DIR"
    echo ""
    echo "Note: Your original illogical-impulse config is preserved at: $II_CONFIG_DIR"
    echo "You can safely remove it later if you no longer need it."
else
    echo "No existing illogical-impulse configuration found."
    echo "Creating default heimdall config directory..."
    mkdir -p "$HEIMDALL_CONFIG_DIR"
    echo "Default configuration will be created when you first run Heimdall."
fi

echo ""
echo "IMPORTANT: After running this migration script, you should:"
echo "1. Restart Hyprland or reload the configuration: hyprctl reload"
echo "2. Launch Heimdall: qs -c heimdall"
echo ""
echo "Migration script completed!"