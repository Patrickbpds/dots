# Configuration Management Summary

## 1. Where Default Values Are Set

Default values are defined directly in the QML configuration modules as property initializers:

### Primary Default Locations
- **Module Configs**: Each module has its own config file with defaults
  - `config/LauncherConfig.qml` - e.g., `vimKeybinds: true`, `maxShown: 8`
  - `config/SessionConfig.qml` - e.g., `vimKeybinds: true`, `dragThreshold: 30`
  - `config/BarConfig.qml` - bar-specific defaults
  - `config/BackgroundConfig.qml` - background defaults
  - Other module configs follow same pattern

### Default Value Pattern
```qml
// Example from LauncherConfig.qml
property bool vimKeybinds: true  // Default value set inline
property int maxShown: 8         // Default value set inline
```

## 2. How External Configuration Is Managed

The system uses a two-tier configuration approach:

### External Config Location
- **Primary Path**: `~/.config/heimdall/shell.json`
- **Loaded By**: `config/ConfigLoader.qml` and `config/Config.qml`

### Loading Process
1. **ConfigLoader.qml** reads the JSON file at startup
2. **Config.qml** applies external values through `applyExternalConfig()`
3. External values override defaults using property assignment
4. Deep merge strategy for nested objects

### Key Files
- `config/Config.qml` - Main configuration singleton, lines 52-150 handle external config
- `config/ConfigLoader.qml` - Dedicated JSON loader, provides helper functions
- External file: `~/.config/heimdall/shell.json`

## 3. Does the System Update the Config File?

**No**, the system is **read-only** for configuration:

### Evidence
- No write operations found in Config.qml or ConfigLoader.qml
- Only reads from `shell.json` using `FileView` component
- No JSON.stringify() or file write operations detected
- Configuration changes are runtime-only, not persisted

### Implications
- Users must manually edit `shell.json` to change settings
- System restarts reload configuration from file
- No risk of system corrupting user configuration

## 4. Centralized Configuration Management Approach

### Architecture Overview

```
┌─────────────────────┐
│  shell.json (User)  │  External configuration
└──────────┬──────────┘
           │ Reads
┌──────────▼──────────┐
│   ConfigLoader.qml  │  JSON parser & helper functions
└──────────┬──────────┘
           │ Provides data
┌──────────▼──────────┐
│     Config.qml      │  Central singleton, merges configs
└──────────┬──────────┘
           │ Exposes via aliases
┌──────────▼──────────┐
│   Module Configs    │  Default values + overrides
│  (Launcher, Bar...)  │
└─────────────────────┘
```

### Key Components

1. **Config.qml (Singleton)**
   - Central access point for all configuration
   - Property aliases to module configs (lines 10-24)
   - Merge function for external config (lines 33-48)
   - Signal for configuration changes (line 27)

2. **ConfigLoader.qml (Singleton)**
   - Reads `shell.json` from disk
   - Provides helper functions like `getConfigValue()`
   - Specific accessors like `isLauncherVimEnabled()`

3. **Module Config Files**
   - Define default values as QML properties
   - Inherit from `JsonObject` for JSON compatibility
   - Self-contained configuration for each module

### Configuration Priority
1. External JSON values (highest priority)
2. QML property defaults (fallback)
3. No hardcoded values in components

### Access Pattern
Components access configuration through:
```qml
import "config" as Config
// Then use: Config.Config.launcher.vimKeybinds
```

## Actionable Insights

1. **To change settings**: Edit `~/.config/heimdall/shell.json`
2. **To add new config options**: 
   - Add property with default to relevant module config QML file
   - External JSON will automatically override if present
3. **To debug config issues**: Check ConfigLoader console output at startup
4. **Configuration is immutable at runtime**: Changes require restart