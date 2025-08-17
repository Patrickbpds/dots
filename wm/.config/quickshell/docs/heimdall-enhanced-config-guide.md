# Heimdall Enhanced Configuration System Guide

## Overview

The Heimdall Enhanced Configuration System provides robust support for nested object configurations, type conversion, and intelligent hot-reload capabilities for Quickshell.

## Key Features

### 1. Nested Object Support
- **Deep property assignment**: Supports configurations like `launcher.sizes.itemWidth`
- **Recursive merging**: Properly merges nested objects with defaults
- **Array handling**: Correctly processes array properties
- **Type preservation**: Maintains proper types during assignment

### 2. Type Conversion System
- **Automatic conversion**: Converts string values to appropriate types
- **Qt type support**: Handles Qt-specific types (color, size, point, rect, font)
- **Smart detection**: Automatically detects formats (hex colors, dates, URLs)
- **Validation**: Ensures converted values are valid

### 3. Hot Reload Management
- **Debouncing**: Prevents excessive reloads (configurable delay)
- **Validation**: Checks configuration before applying
- **Backup system**: Automatic backups with history
- **Rollback**: Reverts to last valid config on failure
- **Statistics**: Tracks reload success/failure rates

## Configuration Structure

### Basic Structure
```json
{
  "version": "1.0.0",
  "hotReload": {
    "enabled": true,
    "debounceMs": 500,
    "validateSchema": true,
    "backupOnChange": true
  },
  "modules": {
    "launcher": {
      "enabled": true,
      "vimKeybinds": true,
      "sizes": {
        "itemWidth": 200,
        "itemHeight": 50,
        "padding": 10
      },
      "colors": {
        "background": "#1a1a1a",
        "text": "#ffffff",
        "accent": "#00ff00"
      }
    }
  },
  "appearance": {
    "theme": "dark",
    "font": {
      "family": "Inter",
      "size": 12
    },
    "colors": {
      "primary": "#007acc"
    }
  }
}
```

### Supported Modules

#### Launcher Module
```json
{
  "launcher": {
    "enabled": true,
    "vimKeybinds": true,
    "sizes": {
      "itemWidth": 200,
      "itemHeight": 50,
      "padding": 10,
      "iconSize": 24,
      "fontSize": 14
    },
    "colors": {
      "background": "#1a1a1a",
      "text": "#ffffff",
      "accent": "#00ff00",
      "hover": "#333333",
      "selected": "#444444"
    },
    "animations": {
      "enabled": true,
      "duration": 200,
      "easing": "easeInOutQuad"
    },
    "search": {
      "caseSensitive": false,
      "fuzzy": true,
      "maxResults": 10
    }
  }
}
```

#### Session Module
```json
{
  "session": {
    "enabled": true,
    "vimKeybinds": true,
    "buttons": {
      "shutdown": true,
      "reboot": true,
      "logout": true,
      "lock": true,
      "suspend": true
    },
    "appearance": {
      "buttonSize": 80,
      "spacing": 20,
      "showLabels": true
    }
  }
}
```

#### Bar Module
```json
{
  "bar": {
    "enabled": true,
    "position": "top",
    "height": 30,
    "margin": {
      "top": 5,
      "left": 5,
      "right": 5,
      "bottom": 0
    },
    "modules": {
      "workspaces": true,
      "clock": true,
      "battery": true,
      "network": true,
      "volume": true
    }
  }
}
```

## Type Conversion Examples

### Boolean Conversion
- `"true"`, `"yes"`, `"on"`, `"1"` → `true`
- `"false"`, `"no"`, `"off"`, `"0"` → `false`

### Number Conversion
- `"123"` → `123`
- `"45.67"` → `45.67`
- `"50%"` → `0.5`
- `"0xFF"` → `255`

### Color Conversion
- `"#FF0000"` → Qt color (red)
- `"rgb(255, 0, 0)"` → Qt color (red)
- `{"r": 255, "g": 0, "b": 0}` → Qt color (red)
- `"red"` → Qt color (named color)

### Size Conversion
- `{"width": 100, "height": 50}` → Qt.size(100, 50)
- `"100x50"` → Qt.size(100, 50)
- `100` → Qt.size(100, 100)

### Font Conversion
```json
{
  "family": "Inter",
  "size": 14,
  "weight": "bold",
  "italic": false
}
```

## Hot Reload Configuration

### Settings
```json
{
  "hotReload": {
    "enabled": true,
    "debounceMs": 500,
    "validateSchema": true,
    "backupOnChange": true
  }
}
```

### Behavior
1. **File Change Detection**: Monitors `~/.config/heimdall/shell.json`
2. **Debouncing**: Waits 500ms after last change before reloading
3. **Validation**: Checks configuration structure before applying
4. **Backup**: Creates backup before applying changes
5. **Rollback**: Reverts to previous config if application fails

## Integration Guide

### Step 1: Install Components
Ensure all components are in place:
- `/heimdall/utils/ConfigPropertyAssigner.qml`
- `/heimdall/utils/TypeConverter.qml`
- `/heimdall/utils/HotReloadManager.qml`
- `/heimdall/config/ConfigV2.qml`

### Step 2: Backup Current Config
```bash
cp ~/.config/quickshell/heimdall/config/Config.qml \
   ~/.config/quickshell/heimdall/config/Config.qml.bak
```

### Step 3: Deploy Enhanced Config
```bash
cp ~/.config/quickshell/heimdall/config/ConfigV2.qml \
   ~/.config/quickshell/heimdall/config/Config.qml
```

### Step 4: Create Configuration File
```bash
cat > ~/.config/heimdall/shell.json << 'EOF'
{
  "version": "1.0.0",
  "modules": {
    "launcher": {
      "enabled": true,
      "vimKeybinds": true
    }
  }
}
EOF
```

### Step 5: Restart Quickshell
```bash
pkill qs
qs -c heimdall -n &
```

## Testing

### Run Test Suite
```bash
bash ~/.config/quickshell/heimdall/scripts/test-nested-config.sh
```

### Manual Testing
1. Edit `~/.config/heimdall/shell.json`
2. Save the file
3. Watch quickshell reload automatically
4. Check logs for confirmation:
   ```bash
   journalctl -f | grep Config
   ```

## Troubleshooting

### Configuration Not Loading
1. Check file exists: `ls -la ~/.config/heimdall/shell.json`
2. Validate JSON: `jq . ~/.config/heimdall/shell.json`
3. Check logs: `journalctl -u quickshell | grep Config`

### Hot Reload Not Working
1. Verify `hotReload.enabled` is `true`
2. Check file watching: `inotifywait -m ~/.config/heimdall/shell.json`
3. Increase debounce time if changes are too rapid

### Type Conversion Issues
1. Check value format matches expected type
2. Review TypeConverter logs for warnings
3. Use explicit types in configuration

### Rollback Triggered
1. Check validation errors in logs
2. Verify configuration structure
3. Test with simpler configuration first

## Migration from Old System

### Old Format (Flat)
```json
{
  "launcher_enabled": true,
  "launcher_vimKeybinds": true,
  "launcher_itemWidth": 200
}
```

### New Format (Nested)
```json
{
  "modules": {
    "launcher": {
      "enabled": true,
      "vimKeybinds": true,
      "sizes": {
        "itemWidth": 200
      }
    }
  }
}
```

## Performance Considerations

### Debouncing
- Default: 500ms
- For rapid edits: Increase to 1000-2000ms
- For immediate feedback: Decrease to 100-200ms

### Validation
- Disable for trusted configurations: `"validateSchema": false`
- Enable for development: `"validateSchema": true`

### Backup Management
- Default: 10 backups maximum
- Adjust in HotReloadManager.qml if needed
- Clear old backups periodically

## API Reference

### ConfigPropertyAssigner
```qml
// Assign properties recursively
assignProperties(target, source, path)

// Validate value against schema
validateValue(value, schema)

// Merge with defaults
mergeWithDefaults(source, defaults)
```

### TypeConverter
```qml
// Convert to specific type
convert(value, targetType)

// Individual converters
toBoolean(value)
toNumber(value)
toColor(value)
toSize(value)
toFont(value)

// Detect type
detectType(value)
```

### HotReloadManager
```qml
// Schedule reload
scheduleReload(configPath, configContent, callback)

// Get statistics
getStats()

// Manual rollback
rollback()
rollbackToBackup(index)
```

## Best Practices

1. **Start Simple**: Begin with basic configuration and add complexity gradually
2. **Use Validation**: Keep validation enabled during development
3. **Test Changes**: Use test configuration before production
4. **Monitor Logs**: Watch logs during configuration changes
5. **Backup Regularly**: Keep backups of working configurations
6. **Document Custom Properties**: Document any custom module properties

## Support

For issues or questions:
1. Check the implementation plan: `/docs/plans/heimdall-config-plan.md`
2. Review test results: Run `test-nested-config.sh`
3. Check component logs: `journalctl -f | grep -E "Config|PropertyAssigner|TypeConverter|HotReload"`

---

*Enhanced Configuration System v1.0.0*
*Created: 2025-08-16*