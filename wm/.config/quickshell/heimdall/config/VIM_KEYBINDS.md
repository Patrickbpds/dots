# Vim Keybinds Configuration for Heimdall

## Overview
Vim keybindings have been integrated into the Heimdall shell configuration system, allowing users to navigate using familiar vim-style keyboard shortcuts (hjkl).

## Configuration Location
The vim keybinds settings are stored in: `~/.config/heimdall/shell.json`

## Configuration Structure
```json
{
  "modules": {
    "launcher": {
      "vimKeybinds": true,  // Enable vim keys in launcher
      ...
    },
    "session": {
      "vimKeybinds": true,  // Enable vim keys in session menu
      ...
    }
  }
}
```

## Default Settings
- **Launcher vim keybinds**: `true` (enabled by default)
- **Session vim keybinds**: `true` (enabled by default)

## Key Mappings
When vim keybinds are enabled:

### Launcher Module
- `j` - Move down in the list
- `k` - Move up in the list
- `h` - Move left (for grid layouts)
- `l` - Move right (for grid layouts)
- `Enter` - Select/activate item
- `Escape` - Close launcher

### Session Module
- `j` - Navigate down through session options
- `k` - Navigate up through session options
- `h` - Move to previous option
- `l` - Move to next option
- `Enter` - Activate selected option
- `Escape` - Close session menu

## Toggling Vim Keybinds
To disable vim keybinds, edit `~/.config/heimdall/shell.json` and set:
```json
"vimKeybinds": false
```

## Implementation Files
The vim keybinds configuration is implemented in:
1. `~/.config/heimdall/shell.json` - Main configuration file
2. `config/LauncherConfig.qml` - Launcher configuration component
3. `config/SessionConfig.qml` - Session configuration component
4. `config/ConfigEnhanced.qml` - Configuration loader
5. `config/ConfigLoader.qml` - Helper for loading JSON config

## Applying Changes
After modifying the shell.json file:
1. The configuration will be automatically reloaded if hot-reload is enabled
2. Or restart the Heimdall shell to apply changes

## Troubleshooting
If vim keybinds are not working:
1. Check that `vimKeybinds` is set to `true` in shell.json
2. Verify the JSON file is valid (no syntax errors)
3. Check console logs for any configuration loading errors
4. Ensure the QML components are reading from the correct config path