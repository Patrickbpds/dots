#!/usr/bin/env bash

# Heimdall Setup Script
# This script helps set up Heimdall as independent from illogical-impulse

echo "Heimdall Setup Script"
echo "===================="
echo ""

# Check if we're in the right directory
if [ ! -f "migrate-from-ii.sh" ]; then
    echo "Error: Please run this script from the heimdall quickshell directory"
    echo "Expected location: ~/.config/quickshell/heimdall/"
    exit 1
fi

echo "Step 1: Running migration script..."
./migrate-from-ii.sh

echo ""
echo "Step 2: Checking Hyprland configuration..."

# Check if hyprland config has been updated
HYPR_CONFIG="$HOME/.config/hypr/hyprland.conf"
if [ -f "$HYPR_CONFIG" ]; then
    if grep -q '\$qsConfig = heimdall' "$HYPR_CONFIG"; then
        echo "✓ Hyprland configuration updated to use heimdall"
    else
        echo "⚠ Warning: Hyprland configuration still uses 'ii'. Please update manually:"
        echo "  Edit $HYPR_CONFIG and change '\$qsConfig = ii' to '\$qsConfig = heimdall'"
    fi
else
    echo "⚠ Warning: Hyprland configuration not found at $HYPR_CONFIG"
fi

echo ""
echo "Step 3: Testing Heimdall..."

# Test if quickshell can find the heimdall config
if command -v qs >/dev/null 2>&1; then
    echo "Testing quickshell with heimdall config..."
    if qs -c heimdall ipc call TEST_ALIVE >/dev/null 2>&1; then
        echo "✓ Heimdall is running and responding"
    else
        echo "ℹ Heimdall is not currently running. You can start it with: qs -c heimdall"
    fi
else
    echo "⚠ Warning: quickshell (qs) command not found in PATH"
fi

echo ""
echo "Setup completed!"
echo ""
echo "Next steps:"
echo "1. Reload Hyprland configuration: hyprctl reload"
echo "2. Start Heimdall: qs -c heimdall"
echo "3. Test the configuration by pressing Super+Space (overview toggle)"
echo ""
echo "If you encounter any issues, check the logs with: journalctl --user -f -u quickshell"