# Quickshell Configuration System Architecture

## Overview

The Heimdall quickshell configuration system implements a sophisticated multi-layered architecture that provides:
- **External JSON configuration** with hot-reload capabilities
- **Default value management** through QML singleton objects
- **Type-safe property binding** via JsonAdapter
- **Debounced change propagation** for performance
- **Validation and rollback** mechanisms for safety

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     External Layer                           │
│  ~/.config/heimdall/shell.json (User Configuration)         │
└────────────────────┬────────────────────────────────────────┘
                     │ FileView (watches)
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                    Configuration Core                        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Config.qml (Singleton)                               │  │
│  │ - Merges external with defaults                      │  │
│  │ - Manages JsonAdapter                                │  │
│  │ - Emits change signals                               │  │
│  └──────────────────────────────────────────────────────┘  │
│                           │                                  │
│  ┌────────────────┐      │      ┌─────────────────────┐    │
│  │ ConfigLoader   │◄─────┼─────►│ HotReloadManager   │    │
│  │ (Alternative)  │      │      │ - Debouncing        │    │
│  └────────────────┘      │      │ - Validation       │    │
│                          │      │ - Rollback         │    │
│                          │      └─────────────────────┘    │
└──────────────────────────┼──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    Module Configs                            │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│  │ Appearance   │ │ Launcher     │ │ Session      │ ...   │
│  │ Config       │ │ Config       │ │ Config       │       │
│  └──────────────┘ └──────────────┘ └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    UI Components                             │
│  Bar, Dashboard, Launcher, Control Center, etc.             │
└─────────────────────────────────────────────────────────────┘
```

## Configuration Flow

### 1. Initial Loading Sequence

```qml
// Config.qml initialization flow
Component.onCompleted → FileView.load() → applyExternalConfig() → propagate changes
```

**Detailed Steps:**
1. **FileView Initialization**: Monitors `~/.config/heimdall/shell.json`
2. **JSON Parsing**: Validates and parses external configuration
3. **Merge Process**: Deep merges external values with defaults
4. **Property Assignment**: Updates JsonAdapter properties
5. **Signal Emission**: Notifies components of configuration changes

### 2. Hot Reload Flow

```qml
File Change → FileView.onFileChanged → Debounce → Validate → Apply → Rollback if failed
```

**Key Components:**

```qml
// HotReloadManager.qml - Debounced reload
Timer {
    id: debounceTimer
    interval: root.debounceMs // Default: 500ms
    repeat: false
    onTriggered: performReload()
}
```

### 3. Change Propagation

```qml
Config Change → ConfigChangeHandler → Debounce → Handler Callbacks → UI Update
```

## Default Value Management

### Structure

Each configuration module defines its defaults as QML properties:

```qml
// LauncherConfig.qml
JsonObject {
    property bool enabled: true
    property int maxShown: 8
    property bool vimKeybinds: true // Default value
    
    component Sizes: JsonObject {
        property int itemWidth: 600
        property int itemHeight: 57
    }
}
```

### Merge Strategy

The system uses a deep merge algorithm that:
- Preserves nested object structure
- Overrides only specified values
- Maintains type safety
- Handles arrays as complete replacements

```javascript
function mergeConfig(external, defaults) {
    if (!external) return defaults
    
    for (let key in external) {
        if (defaults.hasOwnProperty(key)) {
            if (typeof external[key] === 'object' && !Array.isArray(external[key])) {
                // Recursive merge for nested objects
                defaults[key] = mergeConfig(external[key], defaults[key])
            } else {
                // Direct override for primitives and arrays
                defaults[key] = external[key]
            }
        }
    }
    return defaults
}
```

## External Configuration Structure

### File Location
- **Primary**: `~/.config/heimdall/shell.json`
- **Backup Directory**: `~/.config/heimdall/backups/`
- **Schema Directory**: `~/.config/heimdall/schemas/`

### JSON Schema

```json
{
  "version": "1.0.0",
  "appearance": {
    "rounding": {
      "scale": 1,
      "small": 12,
      "normal": 17,
      "large": 25,
      "full": 1000
    },
    "spacing": { /* ... */ },
    "padding": { /* ... */ },
    "font": {
      "family": {
        "sans": "IBM Plex Sans",
        "mono": "JetBrains Mono NF",
        "material": "Material Symbols Rounded"
      },
      "size": { /* ... */ }
    },
    "transparency": {
      "enabled": false,
      "base": 0.85,
      "layers": 0.4
    }
  },
  "modules": {
    "launcher": {
      "enabled": true,
      "vimKeybinds": true,
      "maxShown": 8,
      "sizes": {
        "itemWidth": 600,
        "itemHeight": 57
      }
    },
    "session": {
      "enabled": true,
      "vimKeybinds": true
    },
    "bar": { /* ... */ },
    "dashboard": { /* ... */ },
    "controlCenter": { /* ... */ }
  },
  "hotReload": {
    "enabled": true,
    "debounceMs": 500,
    "validateSchema": true,
    "backupOnChange": true,
    "maxBackups": 10
  }
}
```

## Hot Reload Mechanism

### Features

1. **Debouncing**: Prevents rapid successive reloads
2. **Validation**: Schema validation before applying
3. **Backup System**: Automatic backups with rollback capability
4. **Statistics Tracking**: Success/failure metrics

### Implementation

```qml
// HotReloadManager core functions
function scheduleReload(configPath, configContent, callback) {
    if (reloadInProgress) {
        // Queue the reload
        pendingReload = { path, content, callback }
        return
    }
    
    debounceTimer.restart()
    reloadScheduled()
}

function performReload(configPath, configContent, callback) {
    // 1. Parse configuration
    const config = JSON.parse(configContent)
    
    // 2. Validate against schema
    if (validateSchema) {
        const result = validateConfiguration(config)
        if (!result.valid) {
            rollback()
            return
        }
    }
    
    // 3. Create backup
    if (backupOnChange) {
        createBackup(lastValidConfig)
    }
    
    // 4. Apply configuration
    applyConfiguration(config)
    
    // 5. Store as last valid
    lastValidConfig = config
}
```

### Validation Rules

```qml
function validateConfiguration(config) {
    // Structure validation
    if (!config || typeof config !== 'object') {
        return { valid: false, error: "Invalid structure" }
    }
    
    // Module validation
    for (let moduleName in config.modules) {
        const module = config.modules[moduleName]
        const validation = validateModule(moduleName, module)
        if (!validation.valid) return validation
    }
    
    // Type validation for known properties
    // Color validation for appearance values
    // Range validation for numeric properties
    
    return { valid: true }
}
```

## Write-Back Capabilities

### Current Implementation

The system currently supports:
- **Read-only external config**: Changes via file editing
- **FileView monitoring**: Automatic detection of changes
- **JsonAdapter binding**: One-way data flow

### Planned Write-Back Features

```qml
// Proposed write-back implementation
function writeConfiguration(section, value) {
    // 1. Load current configuration
    const config = loadCurrentConfig()
    
    // 2. Update specific section
    config[section] = value
    
    // 3. Validate before writing
    if (!validateConfiguration(config).valid) {
        return false
    }
    
    // 4. Write to file with atomic operation
    const tempFile = configPath + ".tmp"
    writeFile(tempFile, JSON.stringify(config, null, 2))
    renameFile(tempFile, configPath)
    
    return true
}
```

## Best Practices

### 1. Configuration Organization

- **Group related settings** in nested objects
- **Use semantic naming** for clarity
- **Provide sensible defaults** for all values
- **Document non-obvious settings** with comments

### 2. Module Configuration

```qml
// Good: Organized with clear structure
JsonObject {
    property bool enabled: true
    property Behavior behavior: Behavior {}
    property Appearance appearance: Appearance {}
    
    component Behavior: JsonObject {
        property int timeout: 5000
        property bool autoHide: true
    }
    
    component Appearance: JsonObject {
        property string theme: "dark"
        property real opacity: 0.9
    }
}
```

### 3. Hot Reload Optimization

- **Set appropriate debounce times**: 500ms for user edits, 100ms for programmatic
- **Batch related changes**: Update entire sections together
- **Use validation**: Prevent invalid states from being applied
- **Enable backups**: Allow safe experimentation

### 4. Performance Considerations

```qml
// Use property bindings efficiently
property alias launcher: adapter.launcher // Direct alias
property var cachedConfig: null // Cache expensive computations

// Debounce expensive operations
ConfigChangeHandler.registerHandler("appearance", function() {
    // Batch UI updates
    Qt.callLater(updateAllComponents)
})
```

### 5. Error Handling

```qml
// Robust error handling pattern
function applyExternalConfig(configText) {
    try {
        const config = JSON.parse(configText)
        // Validate
        if (!validateConfig(config)) {
            console.warn("Invalid config, using defaults")
            return
        }
        // Apply
        mergeConfig(config, defaults)
    } catch (error) {
        console.error("Config error:", error)
        // Fallback to defaults
        useDefaultConfiguration()
    }
}
```

## Recommendations

### For Developers

1. **Extend Module Configs**: Add new configuration modules by creating `*Config.qml` files
2. **Use JsonAdapter**: Leverage type-safe property binding
3. **Implement Validation**: Add module-specific validation rules
4. **Test Hot Reload**: Ensure components handle configuration changes gracefully

### For Users

1. **Start with defaults**: Copy example configuration as starting point
2. **Use version control**: Track configuration changes in git
3. **Test incrementally**: Make small changes and verify behavior
4. **Monitor logs**: Check console output for configuration errors

### System Improvements

1. **Schema Generation**: Auto-generate JSON schema from QML definitions
2. **GUI Configuration**: Implement settings UI with write-back
3. **Configuration Profiles**: Support multiple configuration sets
4. **Migration Tools**: Handle configuration version upgrades
5. **Validation UI**: Visual feedback for invalid configurations

## Code Examples

### Creating a New Configuration Module

```qml
// MyModuleConfig.qml
import Quickshell.Io

JsonObject {
    property bool enabled: true
    property string mode: "default"
    property Settings settings: Settings {}
    
    component Settings: JsonObject {
        property int refreshRate: 60
        property bool autoStart: false
        property list<string> allowedModes: ["default", "compact", "expanded"]
    }
}
```

### Registering for Configuration Changes

```qml
// MyComponent.qml
import QtQuick

Item {
    Component.onCompleted: {
        ConfigChangeHandler.registerHandler("myModule", function(section) {
            console.log("MyModule config changed")
            updateComponent()
        })
    }
    
    function updateComponent() {
        // React to configuration changes
        visible = Config.myModule.enabled
        state = Config.myModule.mode
    }
}
```

### Implementing Custom Validation

```qml
// Custom validation for module
function validateMyModule(config) {
    // Check required fields
    if (!config.mode) {
        return { valid: false, error: "Mode is required" }
    }
    
    // Validate enum values
    const allowedModes = ["default", "compact", "expanded"]
    if (!allowedModes.includes(config.mode)) {
        return { valid: false, error: "Invalid mode value" }
    }
    
    // Validate numeric ranges
    if (config.settings?.refreshRate) {
        const rate = config.settings.refreshRate
        if (rate < 1 || rate > 144) {
            return { valid: false, error: "Refresh rate must be 1-144" }
        }
    }
    
    return { valid: true }
}
```

## Conclusion

The Heimdall quickshell configuration system provides a robust, extensible architecture for managing shell configuration. Its combination of default values, external configuration, hot reload, and validation creates a flexible yet safe environment for customization. The clear separation of concerns and modular design make it easy to extend and maintain while providing excellent user experience through features like hot reload and automatic rollback.