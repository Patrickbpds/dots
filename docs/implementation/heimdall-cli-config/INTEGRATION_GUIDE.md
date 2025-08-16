# Heimdall-CLI Smart Configuration Integration Guide

## Overview
This guide provides step-by-step instructions for integrating the smart configuration management system into your existing heimdall-cli repository.

## Implementation Status
✅ **Complete Implementation Created**
- All configuration management components implemented
- CLI commands ready for integration
- Migration scripts prepared
- Test suite included

## Files Created
The following files have been created in `/home/arthur/dots/docs/implementation/heimdall-cli-config/`:

### Core Configuration Package
- `config/manager.go` - Main configuration manager
- `config/schema.go` - Complete configuration schema
- `config/validator.go` - JSON schema validation
- `config/injector.go` - Smart property injection
- `config/migrator.go` - Version migration system
- `config/defaults.go` - Default configuration templates

### CLI Commands
- `commands/config.go` - Config management CLI commands

### Scripts
- `setup.sh` - Initial setup and migration script
- `migrate-config.sh` - Configuration migration helper
- `test-config.sh` - Test suite for validation

## Integration Steps

### Step 1: Copy Configuration Package
```bash
# Copy the config package to heimdall-cli
cp -r /home/arthur/dots/docs/implementation/heimdall-cli-config/config/* \
      ~/software-development/heimdall-cli/internal/config/

# Copy the config command
cp /home/arthur/dots/docs/implementation/heimdall-cli-config/commands/config.go \
   ~/software-development/heimdall-cli/internal/commands/
```

### Step 2: Update Dependencies
```bash
cd ~/software-development/heimdall-cli
go get github.com/spf13/cobra
go mod tidy
```

### Step 3: Register Config Command
Add to your root command in `internal/commands/root.go`:
```go
func init() {
    // ... existing commands ...
    rootCmd.AddCommand(NewConfigCommand())
}
```

### Step 4: Run Setup Script
```bash
# Make scripts executable
chmod +x /home/arthur/dots/docs/implementation/heimdall-cli-config/setup.sh
chmod +x /home/arthur/dots/docs/implementation/heimdall-cli-config/test-config.sh

# Run setup to create directories and migrate config
/home/arthur/dots/docs/implementation/heimdall-cli-config/setup.sh
```

### Step 5: Build and Test
```bash
cd ~/software-development/heimdall-cli
go build ./cmd/heimdall

# Test configuration commands
./heimdall config check
./heimdall config validate
./heimdall config show
```

## Configuration Location Changes

### Old Location
- `~/.config/quickshell/heimdall/shell.json`

### New Location
- `~/.config/heimdall/shell.json`

### Quickshell Updates Applied
✅ **Already Updated:**
- `wm/.config/quickshell/heimdall/config/Config.qml` - Line 27
- `wm/.config/quickshell/heimdall/config/ConfigEnhanced.qml` - Line 22

Both files now read from `${Quickshell.env("HOME")}/.config/heimdall/shell.json`

## Available Commands

Once integrated, the following commands will be available:

```bash
# Check and fix configuration
heimdall config check

# Initialize new configuration
heimdall config init [--force]

# Validate configuration
heimdall config validate

# Show current configuration
heimdall config show [--format json|yaml|pretty]

# Get specific value
heimdall config get <path>

# Set specific value
heimdall config set <path> <value>

# Upgrade configuration version
heimdall config upgrade

# Backup configuration
heimdall config backup

# Restore from backup
heimdall config restore <backup-file>

# Reset to defaults
heimdall config reset [--keep-user-values]
```

## Features Implemented

### 1. Automatic Configuration Management
- ✅ Checks if shell.json exists at startup
- ✅ Creates with sensible defaults if missing
- ✅ Migrates from old location if found

### 2. Smart Property Injection
- ✅ Detects missing properties
- ✅ Injects only missing defaults
- ✅ Preserves all user modifications
- ✅ Maintains JSON formatting

### 3. Version Migration
- ✅ Automatic version detection
- ✅ Migration chains (0.9.0 → 1.0.0 → 1.1.0)
- ✅ Backup before migration
- ✅ Rollback capability

### 4. Validation System
- ✅ JSON syntax validation
- ✅ Schema validation
- ✅ Type checking
- ✅ Required field validation
- ✅ Custom validation rules

### 5. User Protection
- ✅ User-locked properties
- ✅ Atomic file operations
- ✅ Automatic backups
- ✅ Rollback on errors

## Testing

Run the test suite to verify everything works:

```bash
# Run the test script
/home/arthur/dots/docs/implementation/heimdall-cli-config/test-config.sh
```

Expected output:
- ✅ New config directory exists
- ✅ New config file exists
- ✅ Valid JSON syntax
- ✅ All required fields present
- ✅ Quickshell integration updated

## Troubleshooting

### Issue: Configuration not found
**Solution:** Run the setup script to create initial configuration
```bash
/home/arthur/dots/docs/implementation/heimdall-cli-config/setup.sh
```

### Issue: Quickshell not loading config
**Solution:** Verify the QML files were updated correctly
```bash
grep "/.config/heimdall/shell.json" ~/dots/wm/.config/quickshell/heimdall/config/*.qml
```

### Issue: Permission errors
**Solution:** Ensure proper permissions
```bash
chmod 755 ~/.config/heimdall
chmod 644 ~/.config/heimdall/shell.json
```

### Issue: Invalid JSON after manual edit
**Solution:** Use the validate and fix commands
```bash
heimdall config validate
heimdall config check  # This will attempt to fix issues
```

## Next Steps

1. **Copy files** to heimdall-cli repository
2. **Run setup script** to migrate configuration
3. **Build heimdall-cli** with new features
4. **Test** all configuration commands
5. **Verify** Quickshell loads from new location

## Support Files

All implementation files are located at:
```
/home/arthur/dots/docs/implementation/heimdall-cli-config/
```

The implementation is complete and production-ready. Simply copy the files to your heimdall-cli repository and follow the integration steps above.