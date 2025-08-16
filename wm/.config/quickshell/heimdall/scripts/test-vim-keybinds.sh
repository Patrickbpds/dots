#!/bin/bash

# Test script to validate vim-keybinds configuration

CONFIG_FILE="$HOME/.config/heimdall/shell.json"

echo "=== Vim Keybinds Configuration Test ==="
echo "Configuration file: $CONFIG_FILE"
echo ""

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file not found!"
    exit 1
fi

echo "✅ Configuration file exists"

# Validate JSON syntax
if command -v jq &> /dev/null; then
    if jq empty "$CONFIG_FILE" 2>/dev/null; then
        echo "✅ JSON syntax is valid"
    else
        echo "❌ JSON syntax error!"
        jq empty "$CONFIG_FILE"
        exit 1
    fi
else
    echo "⚠️  jq not installed, skipping JSON validation"
fi

# Check vim keybinds settings
echo ""
echo "=== Vim Keybinds Settings ==="

if command -v jq &> /dev/null; then
    LAUNCHER_VIM=$(jq -r '.modules.launcher.vimKeybinds' "$CONFIG_FILE")
    SESSION_VIM=$(jq -r '.modules.session.vimKeybinds' "$CONFIG_FILE")
    
    echo "Launcher vim keybinds: $LAUNCHER_VIM"
    echo "Session vim keybinds: $SESSION_VIM"
    
    if [ "$LAUNCHER_VIM" = "true" ]; then
        echo "✅ Launcher vim keybinds enabled"
    else
        echo "❌ Launcher vim keybinds disabled"
    fi
    
    if [ "$SESSION_VIM" = "true" ]; then
        echo "✅ Session vim keybinds enabled"
    else
        echo "❌ Session vim keybinds disabled"
    fi
else
    # Fallback to grep if jq is not available
    if grep -q '"vimKeybinds": true' "$CONFIG_FILE"; then
        echo "✅ Vim keybinds found in configuration"
    else
        echo "❌ Vim keybinds not found or disabled"
    fi
fi

echo ""
echo "=== Configuration Structure ==="
if command -v jq &> /dev/null; then
    echo "Modules configured:"
    jq -r '.modules | keys[]' "$CONFIG_FILE" 2>/dev/null | sed 's/^/  - /'
fi

echo ""
echo "=== Test Complete ==="
echo "To manually verify, check: $CONFIG_FILE"