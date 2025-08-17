#!/bin/bash
# Test hot reload functionality

CONFIG_FILE="$HOME/.config/heimdall/shell.json"

echo "Testing hot reload functionality..."
echo "Current config file: $CONFIG_FILE"

# Make a backup
cp "$CONFIG_FILE" "$CONFIG_FILE.test-backup"

# Read current config
CURRENT_CONFIG=$(cat "$CONFIG_FILE")

# Modify a simple value (e.g., launcher maxShown)
echo "Modifying launcher.maxShown value..."
MODIFIED_CONFIG=$(echo "$CURRENT_CONFIG" | python3 -c "
import sys, json
config = json.load(sys.stdin)
if 'modules' not in config:
    config['modules'] = {}
if 'launcher' not in config['modules']:
    config['modules']['launcher'] = {}
    
# Toggle maxShown between 8 and 10
current = config['modules']['launcher'].get('maxShown', 8)
config['modules']['launcher']['maxShown'] = 10 if current == 8 else 8
print(json.dumps(config, indent=2))
")

# Write modified config
echo "$MODIFIED_CONFIG" > "$CONFIG_FILE"

echo "Configuration modified. Check if quickshell reflects the change."
echo "The launcher.maxShown value has been changed."
echo ""
echo "Press Enter to restore original configuration..."
read

# Restore original
mv "$CONFIG_FILE.test-backup" "$CONFIG_FILE"
echo "Original configuration restored."
