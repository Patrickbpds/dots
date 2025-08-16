# Heimdall Configuration Refactor Plan

## Executive Summary

This plan outlines the comprehensive refactoring of the Heimdall Quickshell configuration system to centralize configuration management at `~/.config/heimdall/shell.json` while maintaining backward compatibility and enabling heimdall-cli integration.

**Key Changes:**
- Relocate primary configuration from `wm/.config/quickshell/heimdall/shell.json` to `~/.config/heimdall/shell.json`
- Create default bootstrap configuration at `wm/.config/quickshell/heimdall/config/default.json`
- Update all QML components to read from the new location
- Ensure seamless heimdall-cli integration for configuration management

## Architecture Overview

### Current State
```
wm/.config/quickshell/heimdall/
├── shell.json                    # Current configuration (to be moved)
├── config/
│   ├── Config.qml                # Main configuration singleton
│   ├── ConfigEnhanced.qml        # Enhanced configuration loader
│   ├── AppearanceConfig.qml      # Appearance settings
│   ├── BarConfig.qml             # Bar configuration
│   ├── GeneralConfig.qml         # General settings
│   └── [other config modules]
└── modules/
    └── [various QML modules]
```

### Target State
```
~/.config/heimdall/
├── shell.json                     # Primary user configuration
├── backups/                       # Automatic backups
│   └── shell-[timestamp].json
└── profiles/                      # User-defined profiles
    ├── default.json
    ├── minimal.json
    └── gaming.json

wm/.config/quickshell/heimdall/
├── config/
│   ├── default.json              # Bootstrap default configuration
│   ├── Config.qml                # Updated to read from ~/.config/heimdall/
│   └── [other QML modules]       # Updated path references
└── modules/
    └── [unchanged]
```

## Configuration Schema Documentation

### Primary Configuration Structure
```json
{
  "version": "2.0.0",
  "metadata": {
    "created": "ISO-8601 timestamp",
    "lastModified": "ISO-8601 timestamp",
    "profile": "profile-name",
    "locked": false,
    "userLocks": []
  },
  "system": {
    "configPath": "~/.config/heimdall/shell.json",
    "fallbackPath": "wm/.config/quickshell/heimdall/config/default.json",
    "autoReload": true,
    "watchInterval": 1000
  },
  "appearance": { /* existing schema */ },
  "general": { /* existing schema */ },
  "bar": { /* existing schema */ },
  "border": { /* existing schema */ },
  "dashboard": { /* existing schema */ },
  "controlCenter": { /* existing schema */ },
  "launcher": { /* existing schema */ },
  "notifs": { /* existing schema */ },
  "osd": { /* existing schema */ },
  "session": { /* existing schema */ },
  "winfo": { /* existing schema */ },
  "lock": { /* existing schema */ },
  "services": { /* existing schema */ },
  "paths": { /* existing schema */ }
}
```

## Implementation Phases

### Phase 1: Configuration Infrastructure (Week 1)

#### 1.1 Create Default Bootstrap Configuration
**Task:** Generate `wm/.config/quickshell/heimdall/config/default.json`
- [ ] Extract current configuration structure from `shell.json`
- [ ] Create minimal default configuration with essential settings
- [ ] Add version metadata for migration tracking
- [ ] Include fallback values for all required fields
- [ ] Document each configuration section

**Files to create:**
- `wm/.config/quickshell/heimdall/config/default.json`
- `wm/.config/quickshell/heimdall/config/schema.md`

#### 1.2 Setup Configuration Directory Structure
**Task:** Establish new configuration hierarchy
- [ ] Create `~/.config/heimdall/` directory structure
- [ ] Setup `backups/` subdirectory for automatic backups
- [ ] Create `profiles/` subdirectory for user profiles
- [ ] Implement directory permission checks (700)
- [ ] Add `.gitignore` for sensitive data

**Script to create:**
```bash
#!/bin/bash
# setup-heimdall-config.sh
mkdir -p ~/.config/heimdall/{backups,profiles}
chmod 700 ~/.config/heimdall
```

### Phase 2: QML Configuration Loader Updates (Week 1-2)

#### 2.1 Update Config.qml
**Task:** Modify main configuration singleton
- [ ] Update FileView path to `~/.config/heimdall/shell.json`
- [ ] Add fallback mechanism for default configuration
- [ ] Implement configuration validation on load
- [ ] Add error handling for missing/corrupt files
- [ ] Enable hot-reload functionality

**Key changes to `Config.qml`:**
```qml
FileView {
    property string primaryPath: `${Quickshell.env("HOME")}/.config/heimdall/shell.json`
    property string fallbackPath: `${Quickshell.env("HOME")}/dots/wm/.config/quickshell/heimdall/config/default.json`
    
    path: File.exists(primaryPath) ? primaryPath : fallbackPath
    watchChanges: true
    onFileChanged: validateAndReload()
}
```

#### 2.2 Update ConfigEnhanced.qml
**Task:** Enhance configuration loader with migration support
- [ ] Add version checking logic
- [ ] Implement automatic migration triggers
- [ ] Add configuration merge capabilities
- [ ] Create backup before migrations
- [ ] Log configuration changes

#### 2.3 Update Individual Config Modules
**Task:** Update all configuration QML modules
- [ ] AppearanceConfig.qml - Add default value providers
- [ ] BarConfig.qml - Update path references
- [ ] GeneralConfig.qml - Add validation methods
- [ ] BackgroundConfig.qml - Update wallpaper paths
- [ ] BorderConfig.qml - Add fallback values
- [ ] DashboardConfig.qml - Update widget paths
- [ ] ControlCenterConfig.qml - Add default toggles
- [ ] LauncherConfig.qml - Update application paths
- [ ] NotifsConfig.qml - Add notification defaults
- [ ] OsdConfig.qml - Update display settings
- [ ] SessionConfig.qml - Add session defaults
- [ ] WInfoConfig.qml - Update window info paths
- [ ] LockConfig.qml - Add security defaults
- [ ] ServiceConfig.qml - Update service paths
- [ ] UserPaths.qml - Update all path references

### Phase 3: Migration System (Week 2)

#### 3.1 Create Migration Script
**Task:** Develop automated migration tool
- [ ] Detect existing configuration location
- [ ] Validate current configuration structure
- [ ] Create backup of existing configuration
- [ ] Copy configuration to new location
- [ ] Update version metadata
- [ ] Verify migration success
- [ ] Generate migration report

**Migration script structure:**
```bash
#!/bin/bash
# migrate-heimdall-config.sh

# 1. Check for existing configurations
# 2. Backup current state
# 3. Migrate to new location
# 4. Update QML references
# 5. Validate new setup
# 6. Generate report
```

#### 3.2 Implement Rollback Mechanism
**Task:** Create safety net for migrations
- [ ] Create rollback script
- [ ] Implement configuration snapshots
- [ ] Add rollback triggers
- [ ] Create recovery documentation
- [ ] Test rollback scenarios

### Phase 4: Heimdall-CLI Integration (Week 2-3)

#### 4.1 Update heimdall-cli Configuration Manager
**Task:** Ensure CLI compatibility with new structure
- [ ] Update configuration paths in Go code
- [ ] Add support for default.json bootstrap
- [ ] Implement profile management commands
- [ ] Add configuration discovery logic
- [ ] Update validation rules

**CLI commands to update:**
```go
// config/manager.go updates
const (
    DefaultConfigPath = "~/.config/heimdall/shell.json"
    BootstrapConfigPath = "~/dots/wm/.config/quickshell/heimdall/config/default.json"
)
```

#### 4.2 Add Bootstrap Command
**Task:** Create initialization command
- [ ] Implement `heimdall-cli bootstrap` command
- [ ] Copy default.json to user location
- [ ] Apply user preferences
- [ ] Generate initial configuration
- [ ] Create welcome documentation

#### 4.3 Profile Management
**Task:** Add profile support to CLI
- [ ] Implement `heimdall-cli profile list`
- [ ] Add `heimdall-cli profile create <name>`
- [ ] Add `heimdall-cli profile apply <name>`
- [ ] Add `heimdall-cli profile delete <name>`
- [ ] Add `heimdall-cli profile export/import`

### Phase 5: Testing & Validation (Week 3)

#### 5.1 Unit Testing
**Task:** Test individual components
- [ ] Test configuration loading in QML
- [ ] Test fallback mechanisms
- [ ] Test migration scripts
- [ ] Test CLI commands
- [ ] Test validation rules

#### 5.2 Integration Testing
**Task:** Test complete workflow
- [ ] Test fresh installation scenario
- [ ] Test migration from existing setup
- [ ] Test configuration updates via CLI
- [ ] Test hot-reload functionality
- [ ] Test profile switching

#### 5.3 Performance Testing
**Task:** Ensure no performance regression
- [ ] Measure configuration load time
- [ ] Test file watch performance
- [ ] Measure memory usage
- [ ] Test with large configurations
- [ ] Profile hot-reload cycles

### Phase 6: Documentation & Deployment (Week 3-4)

#### 6.1 User Documentation
**Task:** Create comprehensive guides
- [ ] Installation guide
- [ ] Migration guide
- [ ] Configuration reference
- [ ] Troubleshooting guide
- [ ] FAQ section

#### 6.2 Developer Documentation
**Task:** Document technical details
- [ ] API documentation
- [ ] QML component reference
- [ ] CLI integration guide
- [ ] Extension guide
- [ ] Contributing guidelines

## Integration Points with heimdall-cli

### Configuration Discovery
```go
func DiscoverConfig() string {
    // Priority order:
    // 1. $HEIMDALL_CONFIG environment variable
    // 2. ~/.config/heimdall/shell.json
    // 3. $XDG_CONFIG_HOME/heimdall/shell.json
    // 4. Bootstrap from default.json
}
```

### Configuration Management API
```go
type ConfigManager interface {
    Load() (*Config, error)
    Save(config *Config) error
    Validate(config *Config) []ValidationError
    Migrate(from, to string) error
    Bootstrap() error
    Backup() (string, error)
    Restore(backup string) error
}
```

### CLI Command Structure
```
heimdall-cli config
├── init          # Initialize configuration
├── validate      # Validate current config
├── migrate       # Migrate configuration
├── get           # Get configuration value
├── set           # Set configuration value
├── lock          # Lock configuration field
├── unlock        # Unlock configuration field
├── export        # Export configuration
├── import        # Import configuration
└── bootstrap     # Bootstrap from default
```

## Migration Strategy

### Pre-Migration Checklist
1. **Backup Current Configuration**
   - Create timestamped backup
   - Verify backup integrity
   - Document current state

2. **Validate Current Configuration**
   - Check JSON syntax
   - Verify required fields
   - Identify customizations

3. **Prepare Target Environment**
   - Create directory structure
   - Set proper permissions
   - Install dependencies

### Migration Steps

#### Step 1: Automated Migration
```bash
# Run migration script
./migrate-heimdall-config.sh

# Verify migration
heimdall-cli config validate
```

#### Step 2: Update Quickshell
```bash
# Restart Quickshell with new configuration
pkill quickshell
quickshell --config heimdall &
```

#### Step 3: Verify Functionality
- Check all UI components load correctly
- Verify configuration changes apply
- Test hot-reload functionality
- Confirm CLI integration works

### Rollback Procedure
```bash
# If issues occur, rollback
./rollback-heimdall-config.sh

# Or manually restore
cp ~/.config/heimdall/backups/shell-[timestamp].json ~/.config/heimdall/shell.json
```

## Testing and Validation Approach

### Test Scenarios

#### 1. Fresh Installation
- No existing configuration
- Bootstrap from default.json
- Verify all components initialize

#### 2. Existing Installation
- Migrate from current location
- Preserve customizations
- Maintain functionality

#### 3. Configuration Updates
- Modify via heimdall-cli
- Verify QML hot-reload
- Check persistence

#### 4. Error Handling
- Corrupt configuration file
- Missing configuration
- Invalid permissions
- Network issues (if applicable)

### Validation Criteria

#### Configuration Validation
- [ ] JSON syntax valid
- [ ] Required fields present
- [ ] Value types correct
- [ ] Ranges within limits
- [ ] Path references valid

#### Functional Validation
- [ ] UI components render
- [ ] Settings apply correctly
- [ ] Hot-reload works
- [ ] CLI commands succeed
- [ ] Backups created

#### Performance Validation
- [ ] Load time < 100ms
- [ ] Hot-reload < 50ms
- [ ] Memory usage stable
- [ ] No file descriptor leaks
- [ ] CPU usage minimal

## Risk Assessment and Mitigation

### Identified Risks

1. **Data Loss Risk**
   - **Mitigation:** Automatic backups before any changes
   - **Recovery:** Rollback mechanism and manual restore

2. **Breaking Changes**
   - **Mitigation:** Extensive testing and gradual rollout
   - **Recovery:** Version pinning and compatibility mode

3. **Performance Impact**
   - **Mitigation:** Caching and optimized file watching
   - **Recovery:** Fallback to static configuration

4. **User Confusion**
   - **Mitigation:** Clear documentation and migration guides
   - **Recovery:** Support channels and FAQ

### Contingency Plans

1. **Critical Failure**
   - Immediate rollback to previous version
   - Hotfix deployment process
   - User notification system

2. **Partial Failure**
   - Feature flags for gradual enablement
   - Selective rollback capability
   - Debug mode for troubleshooting

## Success Metrics

### Technical Metrics
- Zero data loss during migration
- < 5% performance impact
- 100% backward compatibility
- All tests passing

### User Experience Metrics
- Seamless migration process
- No visible changes to UI
- Improved configuration management
- Positive user feedback

### Operational Metrics
- Reduced support tickets
- Faster configuration updates
- Easier troubleshooting
- Improved maintainability

## Timeline

### Week 1: Foundation
- Days 1-2: Configuration infrastructure
- Days 3-4: QML loader updates
- Day 5: Initial testing

### Week 2: Core Implementation
- Days 1-2: Complete QML updates
- Days 3-4: Migration system
- Day 5: CLI integration begins

### Week 3: Integration & Testing
- Days 1-2: Complete CLI integration
- Days 3-4: Comprehensive testing
- Day 5: Bug fixes

### Week 4: Documentation & Release
- Days 1-2: Documentation
- Days 3-4: Final testing
- Day 5: Release preparation

## Appendices

### A. Configuration Field Reference
[Detailed field documentation to be added]

### B. Migration Script Examples
[Complete script examples to be added]

### C. Troubleshooting Guide
[Common issues and solutions to be added]

### D. API Documentation
[Detailed API reference to be added]

## Conclusion

This refactoring plan provides a comprehensive approach to modernizing the Heimdall configuration system while maintaining stability and enhancing functionality. The phased implementation ensures minimal disruption while delivering improved configuration management capabilities through heimdall-cli integration.

The key benefits include:
- Centralized configuration management
- Improved CLI integration
- Better backup and recovery
- Enhanced user experience
- Future-proof architecture

Success depends on careful execution of each phase, thorough testing, and clear communication with users throughout the migration process.