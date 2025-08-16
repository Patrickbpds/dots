#!/bin/bash

# Script to update shell.json with vim-keybinds configuration
# This enables vim keybindings by default in Heimdall launcher and session modules

CONFIG_FILE="$HOME/.config/heimdall/shell.json"
BACKUP_FILE="$CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"

# Create backup
if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo "Backup created: $BACKUP_FILE"
fi

# Create updated configuration with vim-keybinds enabled
cat > "$CONFIG_FILE" << 'EOF'
{
  "version": "1.0.0",
  "metadata": {
    "description": "Heimdall Shell Configuration",
    "lastModified": "2025-08-15",
    "comments": {
      "vimKeybinds": "Enable vim-style keyboard navigation (hjkl) in launcher and session modules",
      "launcher.vimKeybinds": "When true, enables vim keys in launcher: j/k for up/down, h/l for left/right",
      "session.vimKeybinds": "When true, enables vim keys in session menu navigation"
    }
  },
  "modules": {
    "launcher": {
      "enabled": true,
      "vimKeybinds": true,
      "maxShown": 8,
      "maxWallpapers": 9,
      "actionPrefix": ">",
      "enableDangerousActions": false,
      "dragThreshold": 50,
      "useFuzzy": {
        "apps": false,
        "actions": false,
        "schemes": false,
        "variants": false,
        "wallpapers": false
      },
      "sizes": {
        "itemWidth": 600,
        "itemHeight": 57,
        "wallpaperWidth": 280,
        "wallpaperHeight": 200
      }
    },
    "session": {
      "enabled": true,
      "vimKeybinds": true,
      "dragThreshold": 30,
      "commands": {
        "logout": ["hyprctl", "dispatch", "exit"],
        "shutdown": ["systemctl", "poweroff"],
        "hibernate": ["systemctl", "hibernate"],
        "reboot": ["systemctl", "reboot"]
      },
      "sizes": {
        "button": 80
      }
    }
  }
}
EOF

echo "Updated $CONFIG_FILE with vim-keybinds configuration enabled"
echo "Vim keybindings are now enabled by default for launcher and session modules"