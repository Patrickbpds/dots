# Quickshell Heimdall JSON Configuration System

## Overview

This is the enhanced Quickshell Heimdall configuration with a centralized JSON-based configuration system that provides hot-reload capabilities, improved stability, and fixes for critical issues.

## Key Features

- **Centralized Configuration**: All settings in a single `shell.json` file
- **Hot-Reload**: Changes apply instantly without restart
- **Validation**: Built-in schema validation prevents invalid configurations
- **Backup/Restore**: Automatic backups with easy rollback
- **Migration Tools**: Smooth transition from QML-based configuration
- **Critical Fixes**: Resolved wallpaper persistence, logout commands, and startup issues

## Fixed Issues

### 1. Wallpaper Persistence ✓
- Wallpaper now persists across reboots
- Proper state synchronization between heimdall and quickshell
- Automatic restoration on startup

### 2. Session Management ✓
- Logout command now works correctly with dynamic username resolution
- All power menu options functional
- Fallback commands for edge cases

### 3. Startup Sequence ✓
- Orchestrated startup prevents race conditions
- No more blank screens on boot
- Proper daemon initialization
- Docker Desktop starts reliably

### 4. Configuration Management ✓
- Single source of truth in `shell.json`
- Hot-reload for instant changes
- Schema validation prevents errors
- Easy backup and restore

## Quick Start

### 1. Initial Setup

Run the setup script to create necessary directories and symlinks:

```bash
./scripts/setup-paths.sh
```

### 2. Migration (if upgrading)

If you have existing QML configuration:

```bash
./scripts/migrate-config.py
```

Or to see what would be migrated without making changes:

```bash
./scripts/migrate-config.py --dry-run
```

### 3. Validate Configuration

Check that your configuration is valid:

```bash
./scripts/validate-config.py
```

### 4. Apply Configuration

The configuration is automatically loaded on startup. To manually reload:

```bash
touch shell.json  # Triggers hot-reload
```

## Configuration Structure

The `shell.json` file contains these main sections:

### System Configuration
```json
{
  "system": {
    "startup": {
      "sequence": [...]  // Startup order with delays
    },
    "paths": {...},      // State and cache directories
    "environment": {...} // Environment variables
  }
}
```

### Appearance
```json
{
  "appearance": {
    "rounding": {...},   // Corner radius values
    "spacing": {...},    // Spacing between elements
    "padding": {...},    // Internal padding
    "font": {...},       // Font families and sizes
    "animation": {...},  // Animation curves and durations
    "transparency": {...} // Transparency settings
  }
}
```

### Commands
```json
{
  "commands": {
    "terminal": "kitty",
    "logout": ["loginctl", "terminate-user", "${USER}"],
    "shutdown": ["systemctl", "poweroff"],
    // ... other commands
  }
}
```

### Hot-Reload Settings
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

## Scripts and Tools

### Configuration Management

- **`config-manager.sh`**: Interactive configuration management
  ```bash
  ./scripts/config-manager.sh
  # Options: backup, restore, validate, apply, diff
  ```

- **`validate-config.py`**: Validate JSON configuration
  ```bash
  ./scripts/validate-config.py [config-file]
  ```

- **`migrate-config.py`**: Migrate from QML to JSON
  ```bash
  ./scripts/migrate-config.py [--input old.json] [--output new.json]
  ```

### Testing

- **`test-phase1.sh`**: Test all Phase 1 fixes
  ```bash
  ./scripts/test-phase1.sh
  ```

- **`test-validation.sh`**: Test configuration validator
  ```bash
  ./scripts/test-validation.sh
  ```

- **`test-hot-reload.sh`**: Test hot-reload performance
  ```bash
  ./scripts/test-hot-reload.sh
  ```

### System Scripts

- **`startup-orchestrator.sh`**: Manages startup sequence
- **`wallpaper-sync.sh`**: Synchronizes wallpaper state
- **`restore-wallpaper.sh`**: Restores wallpaper on boot
- **`docker-desktop.sh`**: Starts Docker Desktop reliably

## Hot-Reload Usage

### Making Changes

1. Edit `shell.json` with your preferred editor
2. Changes are automatically detected and applied
3. Debouncing prevents multiple reloads for rapid edits

### Creating Hot-Reload Components

Use the `ConfigurableComponent` mixin:

```qml
import "../utils"

ConfigurableComponent {
    configSection: "appearance"  // Section to watch
    
    function refreshFromConfig() {
        // Update component from configuration
        myProperty = configValue("appearance.rounding.normal", 17)
    }
}
```

## Troubleshooting

### Configuration Not Loading

1. Check validation:
   ```bash
   ./scripts/validate-config.py
   ```

2. Check file permissions:
   ```bash
   ls -la shell.json
   ```

3. Check logs:
   ```bash
   journalctl --user -f | grep quickshell
   ```

### Wallpaper Not Persisting

1. Check state file:
   ```bash
   cat ~/.local/state/quickshell/user/generated/wallpaper/path.txt
   ```

2. Verify wallpaper daemon:
   ```bash
   pgrep -x swww-daemon || pgrep -x hyprpaper
   ```

3. Run restore manually:
   ```bash
   ~/.config/hypr/programs/restore-wallpaper.sh
   ```

### Hot-Reload Not Working

1. Check if enabled:
   ```bash
   jq '.hotReload.enabled' shell.json
   ```

2. Test file watching:
   ```bash
   touch shell.json
   # Check logs for reload message
   ```

3. Verify debounce settings:
   ```bash
   jq '.hotReload.debounceMs' shell.json
   ```

## Backup and Recovery

### Automatic Backups

Backups are created automatically when:
- Configuration is modified through config-manager.sh
- Hot-reload with `backupOnChange` enabled
- Before migration or major changes

### Manual Backup

```bash
./scripts/config-manager.sh backup
```

### Restore from Backup

```bash
./scripts/config-manager.sh restore
# Or restore specific backup:
./scripts/config-manager.sh restore backups/shell.json.20250812-143022
```

### Rollback After Failed Change

```bash
./scripts/config-manager.sh restore latest
```

## Development

### Adding New Configuration Options

1. Add to `shell.json`:
   ```json
   {
     "mySection": {
       "myOption": "value"
     }
   }
   ```

2. Update validator in `validate-config.py`:
   ```python
   def _validate_my_section(self, section: Dict[str, Any]):
       # Add validation logic
   ```

3. Use in QML:
   ```qml
   property var myValue: Config.get("mySection.myOption", "default")
   ```

### Creating Test Cases

Add tests to `test-validation.sh`:

```bash
run_test "My test name" '{
    "version": "1.0.0",
    "mySection": {
        "myOption": "testValue"
    }
}' "true"  # or "false" if should fail
```

## Version History

- **1.0.0** (2025-08-12): Initial JSON configuration system
  - Fixed critical issues (wallpaper, logout, startup)
  - Implemented hot-reload
  - Added validation and migration tools

## Support

For issues or questions:
1. Check the troubleshooting section
2. Run diagnostic tests: `./scripts/test-phase1.sh`
3. Review logs: `journalctl --user -f | grep quickshell`

## License

This configuration system is part of the Quickshell Heimdall project.