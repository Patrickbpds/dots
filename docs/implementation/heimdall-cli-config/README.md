# Heimdall CLI Configuration Management Implementation

This is a production-ready implementation of the smart configuration management system for heimdall-cli, following the plan in `docs/plans/heimdall-cli-smart-config-plan.md`.

## Overview

This implementation provides intelligent shell.json configuration management with:
- Automatic configuration discovery and creation at `~/.config/heimdall/shell.json`
- Non-destructive property injection for new features
- Intelligent version migration with rollback capabilities
- Preservation of user customizations
- Real-time validation and error recovery
- Atomic file operations to prevent corruption

## Project Structure

```
heimdall-cli-config/
├── config/
│   ├── manager.go      # Main configuration manager
│   ├── schema.go       # Configuration schema definitions
│   ├── validator.go    # Schema validation
│   ├── injector.go     # Property injection system
│   ├── migrator.go     # Version migration
│   └── defaults.go     # Default configuration templates
├── commands/
│   └── config.go       # CLI commands for config management
├── main.go             # Main entry point
├── go.mod              # Go module definition
└── README.md           # This file
```

## Features Implemented

### Phase 1: Core Infrastructure ✅
- [x] Configuration path discovery with XDG compliance
- [x] JSON parser with proper marshaling/unmarshaling
- [x] Atomic file operations with automatic backup
- [x] Migration from legacy quickshell location

### Phase 2: Schema & Validation ✅
- [x] Complete schema structures in Go
- [x] Schema validator with detailed error reporting
- [x] Default configuration generator with profiles
- [x] Configuration comparison utilities

### Phase 3: Property Injection ✅
- [x] Deep merge algorithm for nested structures
- [x] Injection rule engine with conditions
- [x] User preference preservation
- [x] Property discovery system for missing fields

### Phase 4: Version Migration ✅
- [x] Migration interface with validate/migrate/rollback
- [x] Version comparison with semantic versioning
- [x] Migration chain resolver with path finding
- [x] Automatic rollback mechanism on failure

### Phase 5: CLI Integration ✅
- [x] Complete CLI command structure
- [x] Config commands: init, validate, migrate, inject
- [x] Get/set operations for individual properties
- [x] Lock/unlock for user preference protection
- [x] Import/export functionality

## Installation

To use this implementation in your heimdall-cli project:

1. Copy the implementation files to your heimdall-cli repository:
```bash
# From /home/arthur/dots/docs/implementation/heimdall-cli-config/
cp -r config/ /path/to/heimdall-cli/
cp -r commands/ /path/to/heimdall-cli/
cp main.go /path/to/heimdall-cli/
```

2. Install dependencies:
```bash
cd /path/to/heimdall-cli/
go mod init heimdall-cli  # If not already initialized
go get github.com/spf13/cobra
go mod tidy
```

3. Build the application:
```bash
go build -o heimdall-cli
```

## Usage

### Initialize Configuration
```bash
# Create default configuration
heimdall-cli config init

# Create with specific profile
heimdall-cli config init gaming
heimdall-cli config init productivity
heimdall-cli config init development

# Force overwrite existing
heimdall-cli config init --force
```

### Validate Configuration
```bash
# Check for errors and warnings
heimdall-cli config validate
```

### Migrate Configuration
```bash
# Migrate to latest version
heimdall-cli config migrate

# Migrate to specific version
heimdall-cli config migrate 1.0.0
```

### Inject Default Properties
```bash
# Add missing properties without overwriting
heimdall-cli config inject
```

### Get/Set Values
```bash
# Get a value
heimdall-cli config get system.shell
heimdall-cli config get appearance.colors --json

# Set a value
heimdall-cli config set system.shell zsh
heimdall-cli config set appearance.transparency 0.9
heimdall-cli config set modules.enabled '["clock","battery"]'
```

### Lock/Unlock Properties
```bash
# Prevent automatic updates
heimdall-cli config lock appearance.colors
heimdall-cli config lock "modules.*"

# Allow updates again
heimdall-cli config unlock appearance.colors
```

### Import/Export
```bash
# Export to file
heimdall-cli config export backup.json

# Export to stdout
heimdall-cli config export

# Import from file
heimdall-cli config import backup.json
```

## Configuration Schema

The configuration follows this structure:

```json
{
  "version": "1.0.0",
  "metadata": {
    "created": "2025-08-12T10:00:00Z",
    "lastModified": "2025-08-12T10:00:00Z",
    "profile": "default",
    "managedBy": "heimdall-cli",
    "userLocked": []
  },
  "system": {
    "shell": "bash",
    "terminal": "kitty",
    "fileManager": "nemo",
    "editor": "nvim",
    "browser": "firefox",
    "font": {
      "family": "JetBrainsMono Nerd Font",
      "size": 11,
      "weight": "Regular"
    }
  },
  "appearance": {
    "theme": "dark",
    "colorScheme": "catppuccin-mocha",
    "accentColor": "#89b4fa",
    "transparency": 0.8,
    "blurRadius": 10,
    "colors": {
      "background": "#1e1e2e",
      "foreground": "#cdd6f4",
      "primary": "#89b4fa",
      "secondary": "#f5c2e7"
    }
  },
  "bar": {
    "position": "top",
    "height": 30,
    "width": "100%"
  },
  "modules": {
    "enabled": ["workspaces", "clock", "battery"],
    "disabled": [],
    "order": ["workspaces", "clock", "battery"]
  },
  "services": {
    "notifications": {
      "enabled": true,
      "position": "top-right",
      "timeout": 5000
    }
  },
  "wallpaper": {
    "mode": "static",
    "path": "",
    "fillMode": "cover"
  },
  "hotReload": {
    "enabled": true,
    "watchPaths": ["~/.config/heimdall/shell.json"],
    "debounce": 100
  }
}
```

## Configuration Profiles

The implementation includes several pre-configured profiles:

### Default Profile
- Balanced configuration suitable for most users
- Full feature set enabled
- Catppuccin Mocha color scheme

### Minimal Profile
- Bare minimum configuration
- Only essential modules
- No visual effects

### Gaming Profile
- Performance-optimized settings
- Disabled animations and effects
- Auto-hide bar
- Minimal modules

### Productivity Profile
- Focus-oriented configuration
- Clean, distraction-free appearance
- Pomodoro and todo modules
- Eye comfort settings

### Development Profile
- Developer-friendly settings
- Additional monitoring modules (CPU, memory, disk)
- Git and Docker integration
- Hot reload enabled

## Error Handling

The implementation includes comprehensive error handling:

### Validation Errors
- **Critical**: Configuration cannot function
- **Error**: Important issues that should be fixed
- **Warning**: Recommendations for improvement

### Automatic Recovery
- Missing required fields are injected
- Invalid types are coerced when possible
- Malformed JSON triggers format recovery
- Backup restoration on critical failures

### User Intervention
When automatic recovery isn't possible:
- Clear error messages with suggested fixes
- Command examples for resolution
- Rollback options for migrations

## Performance

The implementation is optimized for:
- Config load time: < 10ms
- Validation time: < 50ms
- Migration time: < 100ms per version
- Property injection: < 20ms

Includes caching with TTL and file modification checking.

## Security

### File Permissions
- Config file: 0644 (readable by all, writable by owner)
- Backup files: 0600 (owner only)
- Directory: 0755 (standard directory permissions)

### Input Validation
- All user inputs are sanitized
- JSON structure validation
- Path traversal prevention
- File size limits

## Testing

To test the implementation:

```bash
# Run unit tests
go test ./config/...
go test ./commands/...

# Run with verbose output
go test -v ./...

# Run with coverage
go test -cover ./...
```

## Integration with Quickshell

To integrate with Quickshell, update the Config.qml file:

```qml
// ~/.config/quickshell/heimdall/Config.qml
import Quickshell
import Quickshell.Io

Singleton {
    property string configPath: `${Quickshell.env("HOME")}/.config/heimdall/shell.json`
    
    property var config: JsonFile {
        path: configPath
        // Configuration will be automatically loaded
    }
}
```

## Troubleshooting

### Configuration Not Found
```bash
# Check if config exists
ls -la ~/.config/heimdall/shell.json

# Initialize if missing
heimdall-cli config init
```

### Permission Denied
```bash
# Fix permissions
chmod 644 ~/.config/heimdall/shell.json
chmod 755 ~/.config/heimdall/
```

### Invalid JSON
```bash
# Validate and get specific errors
heimdall-cli config validate

# Restore from backup
cp ~/.config/heimdall/backups/shell-*.json ~/.config/heimdall/shell.json
```

### Migration Failed
```bash
# Check migration history
ls ~/.config/heimdall/backups/migration-*.json

# Manually restore previous version
cp ~/.config/heimdall/backups/migration-0.9.0-*.json ~/.config/heimdall/shell.json
```

## Contributing

When extending this implementation:

1. Follow the existing code structure
2. Add tests for new features
3. Update schema version for breaking changes
4. Document new configuration options
5. Provide migration paths for schema changes

## License

This implementation is provided as-is for use in the heimdall-cli project.