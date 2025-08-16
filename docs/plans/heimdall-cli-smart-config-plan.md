# Heimdall-CLI Smart Configuration Management Plan

## Executive Summary

This plan outlines the implementation of intelligent shell.json configuration management for heimdall-cli, a Go-based command-line tool that owns and manages the Heimdall shell configuration. The configuration file is stored at `~/.config/heimdall/shell.json` and is read by Quickshell's Heimdall implementation. The system will provide automatic configuration discovery, creation, property injection, version migration, and preservation of user modifications while maintaining backward compatibility and data integrity.

### Key Objectives
- Zero-configuration startup with automatic shell.json creation at `~/.config/heimdall/shell.json`
- Non-destructive property injection for new Quickshell features
- Intelligent version migration with rollback capabilities
- Preservation of user customizations and comments
- Real-time validation and error recovery
- Atomic file operations to prevent corruption
- Clear ownership: heimdall-cli manages the configuration, Quickshell consumes it

### Success Metrics
- 100% backward compatibility with existing configurations
- < 50ms configuration validation time
- Zero data loss during migrations
- Automatic recovery from 95% of configuration errors
- Full preservation of user modifications and formatting

## Architecture

### Configuration Location and Ownership
- **Primary config path**: `~/.config/heimdall/shell.json`
- **Backup directory**: `~/.config/heimdall/backups/`
- **Ownership**: Configuration is owned and managed by heimdall-cli
- **Consumer**: Quickshell reads from this location via updated Config.qml
- **Migration**: Automatic migration from old location if found

### Configuration Migration Strategy
When heimdall-cli starts, it will:
1. Check for config at `~/.config/heimdall/shell.json`
2. If not found, check for legacy config at `~/.config/quickshell/heimdall/shell.json`
3. If legacy config exists:
   - Copy to new location `~/.config/heimdall/shell.json`
   - Create backup of original at `~/.config/heimdall/backups/migrated-from-quickshell.json`
   - Add migration metadata to track the move
4. Update Quickshell's Config.qml to read from new location

### Core Components

#### 1. Configuration Manager
```go
package config

const (
    DefaultConfigPath = "~/.config/heimdall/shell.json"
    BackupDirPath    = "~/.config/heimdall/backups"
)

type ConfigManager struct {
    configPath     string  // Default: ~/.config/heimdall/shell.json
    backupDir      string  // Default: ~/.config/heimdall/backups
    schemaVersion  string
    validator      *SchemaValidator
    migrator       *VersionMigrator
    injector       *PropertyInjector
    watcher        *FileWatcher
}

// Primary operations
func (cm *ConfigManager) Initialize() error
func (cm *ConfigManager) Load() (*ShellConfig, error)
func (cm *ConfigManager) Save(config *ShellConfig) error
func (cm *ConfigManager) Validate(config *ShellConfig) []ValidationError
func (cm *ConfigManager) Migrate(config *ShellConfig) error
func (cm *ConfigManager) InjectDefaults(config *ShellConfig) error
```

#### 2. Schema Definition
```go
package schema

type ShellConfig struct {
    Version  string                 `json:"version"`
    Metadata ConfigMetadata         `json:"metadata"`
    System   SystemConfig           `json:"system"`
    Appearance AppearanceConfig     `json:"appearance"`
    Bar      BarConfig              `json:"bar"`
    Modules  ModulesConfig          `json:"modules"`
    Services ServicesConfig         `json:"services"`
    Commands CommandsConfig         `json:"commands"`
    Wallpaper WallpaperConfig       `json:"wallpaper"`
    HotReload HotReloadConfig       `json:"hotReload"`
    
    // Preserve unknown fields for forward compatibility
    Extra map[string]interface{}   `json:"-"`
}

type ConfigMetadata struct {
    Created      time.Time `json:"created"`
    LastModified time.Time `json:"lastModified"`
    Profile      string    `json:"profile"`
    ManagedBy    string    `json:"managedBy,omitempty"`
    UserLocked   []string  `json:"userLocked,omitempty"`
}
```

#### 3. Property Injection System
```go
package injection

type PropertyInjector struct {
    defaults  map[string]interface{}
    rules     []InjectionRule
    preserves []string // Paths to never modify
}

type InjectionRule struct {
    Path      string
    Condition func(current interface{}) bool
    Value     interface{}
    Strategy  InjectionStrategy
}

type InjectionStrategy int
const (
    MergeDeep InjectionStrategy = iota  // Recursive merge
    MergeShallow                         // Top-level merge only
    ReplaceIfMissing                     // Only if not exists
    ReplaceIfDefault                     // Only if matches default
    NeverReplace                         // User-locked
)
```

#### 4. Version Migration Engine
```go
package migration

type VersionMigrator struct {
    migrations map[string]Migration
    history    []MigrationRecord
}

type Migration interface {
    FromVersion() string
    ToVersion() string
    Migrate(config map[string]interface{}) error
    Rollback(config map[string]interface{}) error
    Validate(config map[string]interface{}) error
}

type MigrationRecord struct {
    From      string
    To        string
    Timestamp time.Time
    Backup    string
    Success   bool
}
```

## Implementation Phases

### Phase 1: Core Infrastructure (Week 1-2)

#### Tasks
- [ ] Set up Go project structure with proper module organization
  - Acceptance: Clean module boundaries, testable components
  - Tests: Unit tests for each module

- [ ] Implement configuration path discovery
  - Acceptance: Finds config at `~/.config/heimdall/shell.json` or via env vars
  - Tests: Path resolution, XDG compliance
  - Note: Ensure directory `~/.config/heimdall/` is created if it doesn't exist

- [ ] Create JSON parser with comment preservation
  - Acceptance: Maintains formatting and comments
  - Tests: Round-trip parsing without data loss

- [ ] Build atomic file operations wrapper
  - Acceptance: Safe writes with automatic backup to `~/.config/heimdall/backups/`
  - Tests: Corruption recovery, concurrent access

- [ ] Update Quickshell Config.qml integration
  - Acceptance: Quickshell reads from new location `~/.config/heimdall/shell.json`
  - Tests: Verify Quickshell can load configuration from new path

#### Deliverables
- Core config package with basic I/O operations
- Path resolution with heimdall-specific directory (`~/.config/heimdall/`)
- JSON handling with format preservation
- File operation safety layer
- Documentation for updating Quickshell's Config.qml

### Phase 2: Schema and Validation (Week 2-3)

#### Tasks
- [ ] Define complete schema structures in Go
  - Acceptance: Full representation of shell.json at `~/.config/heimdall/shell.json`
  - Tests: Marshaling/unmarshaling accuracy

- [ ] Implement schema validator
  - Acceptance: Detects all schema violations
  - Tests: Edge cases, partial configs

- [ ] Create default configuration generator
  - Acceptance: Produces valid, complete config at `~/.config/heimdall/shell.json`
  - Tests: All required fields present

- [ ] Build configuration differ
  - Acceptance: Identifies changes between configs
  - Tests: Deep comparison, array handling

#### Deliverables
- Complete Go structs for configuration
- Schema validation with detailed error reporting
- Default configuration templates written to `~/.config/heimdall/shell.json`
- Configuration comparison utilities

### Phase 3: Property Injection System (Week 3-4)

#### Tasks
- [ ] Implement deep merge algorithm
  - Acceptance: Correctly merges nested structures
  - Tests: Complex nesting, array handling

- [ ] Create injection rule engine
  - Acceptance: Applies rules based on conditions
  - Tests: Rule precedence, conflicts

- [ ] Build user preference preservation
  - Acceptance: Never overwrites user changes
  - Tests: Modification detection

- [ ] Develop property discovery system
  - Acceptance: Identifies missing properties
  - Tests: Schema comparison, new fields

#### Deliverables
- Smart property injection without data loss
- User modification detection
- Conditional injection rules
- Missing property identification

### Phase 4: Version Migration (Week 4-5)

#### Tasks
- [ ] Design migration interface
  - Acceptance: Clean migration API
  - Tests: Mock migrations

- [ ] Implement version comparison
  - Acceptance: Semantic versioning support
  - Tests: Version ordering, ranges

- [ ] Create migration chain resolver
  - Acceptance: Finds optimal migration path
  - Tests: Multi-step migrations

- [ ] Build rollback mechanism
  - Acceptance: Reverts failed migrations
  - Tests: Rollback scenarios

#### Deliverables
- Version-aware migration system
- Migration path planning
- Automatic backup before migration
- Rollback capability

### Phase 5: CLI Integration (Week 5-6)

#### Tasks
- [ ] Create CLI command structure
  - Acceptance: Intuitive command hierarchy
  - Tests: Command parsing, help text

- [ ] Implement config commands
  - Acceptance: init, validate, migrate, inject
  - Tests: Command execution, error handling

- [ ] Add interactive mode
  - Acceptance: Guided configuration editing
  - Tests: User input validation

- [ ] Build status reporting
  - Acceptance: Clear feedback on operations
  - Tests: Progress indicators, error display

#### Deliverables
- heimdall-cli config subcommands
- Interactive configuration wizard
- Detailed operation logging
- User-friendly error messages

### Phase 6: Advanced Features (Week 6-7)

#### Tasks
- [ ] Implement configuration profiles
  - Acceptance: Multiple config management
  - Tests: Profile switching, isolation

- [ ] Add configuration templates
  - Acceptance: Preset configurations
  - Tests: Template application

- [ ] Create configuration linting
  - Acceptance: Best practice suggestions
  - Tests: Performance warnings

- [ ] Build configuration export/import
  - Acceptance: Portable configurations
  - Tests: Format conversions

#### Deliverables
- Profile management system
- Configuration templates
- Linting and suggestions
- Import/export functionality

## Configuration Path Management

### Path Resolution and Migration
```go
package config

import (
    "os"
    "path/filepath"
)

func GetConfigPath() string {
    // Check environment variable first
    if envPath := os.Getenv("HEIMDALL_CONFIG_PATH"); envPath != "" {
        return envPath
    }
    
    // Use XDG_CONFIG_HOME if set
    configHome := os.Getenv("XDG_CONFIG_HOME")
    if configHome == "" {
        home, _ := os.UserHomeDir()
        configHome = filepath.Join(home, ".config")
    }
    
    // Return heimdall-owned config path
    return filepath.Join(configHome, "heimdall", "shell.json")
}

func MigrateFromLegacyLocation() error {
    newPath := GetConfigPath()
    legacyPath := filepath.Join(os.Getenv("HOME"), ".config", "quickshell", "heimdall", "shell.json")
    
    // Check if migration is needed
    if _, err := os.Stat(newPath); err == nil {
        return nil // Already migrated
    }
    
    if _, err := os.Stat(legacyPath); os.IsNotExist(err) {
        return nil // No legacy config to migrate
    }
    
    // Perform migration
    // 1. Create new directory
    os.MkdirAll(filepath.Dir(newPath), 0755)
    
    // 2. Copy config to new location
    // 3. Create backup
    // 4. Add migration metadata
    
    return nil
}
```

## Property Injection Strategy

### Injection Algorithm
```go
func (i *PropertyInjector) InjectDefaults(config map[string]interface{}) error {
    // 1. Load current schema defaults
    defaults := i.loadDefaults()
    
    // 2. Identify missing properties
    missing := i.findMissingProperties(config, defaults)
    
    // 3. Check user locks
    locked := i.getUserLocks(config)
    
    // 4. Apply injection rules
    for path, value := range missing {
        if i.isUserLocked(path, locked) {
            continue
        }
        
        rule := i.findRule(path)
        if rule.ShouldInject(config, path) {
            i.injectProperty(config, path, value, rule.Strategy)
        }
    }
    
    // 5. Update metadata
    i.updateMetadata(config)
    
    return nil
}
```

### Preservation Rules
1. **Never modify user-customized values**
   - Track original defaults
   - Compare against current values
   - Skip if different from default

2. **Respect user locks**
   - Honor `metadata.userLocked` array
   - Allow explicit preservation markers
   - Support path wildcards

3. **Maintain structural integrity**
   - Preserve object key order
   - Maintain array element order
   - Keep formatting preferences

4. **Handle special cases**
   - Preserve comments (via special parser)
   - Maintain custom properties
   - Keep unknown fields for forward compatibility

## Version Migration Strategy

### Migration Path Resolution
```go
func (m *VersionMigrator) FindMigrationPath(from, to string) []Migration {
    // Build migration graph
    graph := m.buildMigrationGraph()
    
    // Find shortest path
    path := graph.ShortestPath(from, to)
    
    // Validate path
    for _, migration := range path {
        if err := migration.Validate(); err != nil {
            return m.findAlternatePath(from, to)
        }
    }
    
    return path
}
```

### Migration Safety
1. **Pre-migration validation**
   - Schema compatibility check
   - Data integrity verification
   - Dependency resolution

2. **Atomic operations**
   - Create backup before migration
   - Use temporary files
   - Atomic rename on success

3. **Rollback capability**
   - Keep migration history
   - Store rollback information
   - Automatic rollback on failure

4. **Post-migration verification**
   - Validate migrated config
   - Test critical paths
   - Verify data integrity

## Testing Procedures

### Unit Tests
```go
// config_test.go
func TestConfigCreation(t *testing.T) {
    // Test automatic creation at ~/.config/heimdall/shell.json
    // Test default values
    // Test path resolution
    // Test directory creation if missing
}

func TestPropertyInjection(t *testing.T) {
    // Test missing property detection
    // Test injection strategies
    // Test user lock respect
}

func TestVersionMigration(t *testing.T) {
    // Test version comparison
    // Test migration path finding
    // Test rollback mechanism
    // Test backup creation in ~/.config/heimdall/backups/
}
```

### Integration Tests
```go
// integration_test.go
func TestFullConfigLifecycle(t *testing.T) {
    // Create config
    // Modify config
    // Inject properties
    // Migrate version
    // Validate result
}

func TestConcurrentAccess(t *testing.T) {
    // Multiple readers
    // Single writer
    // Lock contention
}
```

### Scenario Tests
1. **Fresh Installation**
   - No existing config at `~/.config/heimdall/shell.json`
   - Create from defaults
   - Verify completeness
   - Ensure Quickshell can read from new location

2. **Upgrade Scenario**
   - Old version config
   - Apply migrations
   - Preserve customizations
   - Backup to `~/.config/heimdall/backups/`

3. **Corruption Recovery**
   - Malformed JSON at `~/.config/heimdall/shell.json`
   - Missing required fields
   - Automatic repair
   - Restore from `~/.config/heimdall/backups/` if needed

4. **Feature Addition**
   - New properties in schema
   - Inject without disruption
   - Maintain user changes

5. **Quickshell Integration**
   - Verify Quickshell Config.qml reads from `~/.config/heimdall/shell.json`
   - Test hot-reload functionality
   - Ensure no conflicts with heimdall-cli writes

## Error Handling

### Error Categories
```go
type ConfigError struct {
    Type     ErrorType
    Path     string
    Message  string
    Severity Severity
    Fix      *SuggestedFix
}

type ErrorType int
const (
    ValidationError ErrorType = iota
    MigrationError
    InjectionError
    IOError
    ParseError
)

type Severity int
const (
    Warning Severity = iota
    Error
    Critical
)
```

### Recovery Strategies
1. **Automatic fixes**
   - Missing required fields → inject defaults
   - Invalid types → type coercion
   - Malformed JSON → format recovery

2. **User intervention**
   - Conflicting values → prompt user
   - Ambiguous migrations → user choice
   - Data loss risk → user confirmation

3. **Fallback mechanisms**
   - Use previous backup
   - Load minimal config
   - Start with defaults

## Performance Considerations

### Optimization Targets
- Config load time: < 10ms
- Validation time: < 50ms
- Migration time: < 100ms per version
- Property injection: < 20ms

### Caching Strategy
```go
type ConfigCache struct {
    config    *ShellConfig
    checksum  string
    loadTime  time.Time
    ttl       time.Duration
}

func (c *ConfigCache) IsValid() bool {
    // Check file modification time
    // Verify checksum
    // Check TTL
}
```

## Security Considerations

### File Permissions
- Config file (`~/.config/heimdall/shell.json`): 0644 (user read/write, others read)
- Backup files (`~/.config/heimdall/backups/*`): 0600 (user only)
- State files: 0600 (user only)
- Directory (`~/.config/heimdall/`): 0755 (user full, others read/execute)

### Input Validation
- Sanitize all user inputs
- Validate JSON structure
- Check path traversal attempts
- Limit file sizes

### Sensitive Data
- Never log sensitive values
- Mask credentials in output
- Secure backup storage
- Clear memory after use

## Monitoring and Logging

### Logging Levels
```go
type Logger interface {
    Debug(msg string, fields ...Field)
    Info(msg string, fields ...Field)
    Warn(msg string, fields ...Field)
    Error(msg string, fields ...Field)
}

// Structured logging
log.Info("Config loaded", 
    Field("path", configPath),
    Field("version", config.Version),
    Field("profile", config.Metadata.Profile))
```

### Metrics Collection
- Configuration operations count
- Migration success rate
- Injection frequency
- Error occurrence patterns
- Performance metrics

## Documentation Requirements

### User Documentation
- Installation guide
- Configuration reference for `~/.config/heimdall/shell.json`
- Migration guide (including Quickshell Config.qml update instructions)
- Troubleshooting guide
- Best practices

### Developer Documentation
- API reference
- Architecture overview
- Contributing guide
- Testing guide
- Release process

### Quickshell Integration Documentation
- Instructions for updating Config.qml to read from `~/.config/heimdall/shell.json`
- Example Config.qml modifications:
  ```qml
  // File: ~/.config/quickshell/heimdall/Config.qml
  // Update to read from heimdall-cli managed location
  
  import QtQuick
  import Qt.labs.platform
  
  QtObject {
      // OLD: property string configPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/quickshell/heimdall/shell.json"
      // NEW: Configuration now managed by heimdall-cli
      property string configPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/heimdall/shell.json"
      
      // Alternative: Support both locations during transition
      property string primaryPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/heimdall/shell.json"
      property string legacyPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/quickshell/heimdall/shell.json"
      
      function getConfigPath() {
          // Check new location first
          if (FileInfo.exists(primaryPath)) {
              return primaryPath;
          }
          // Fall back to legacy location
          return legacyPath;
      }
  }
  ```
- Migration path from old location (`~/.config/quickshell/heimdall/shell.json`)
- Hot-reload compatibility with heimdall-cli writes

## Quickshell Configuration Updates Required

This section provides step-by-step instructions for updating the Quickshell configuration files to read from the new heimdall-cli managed location at `~/.config/heimdall/shell.json`.

### 1. Update Config.qml (Line 27)

**File:** `~/.config/quickshell/heimdall/Config.qml`  
**Line:** 27  
**Current Code:**
```qml
path: `${Paths.stringify(Paths.config)}/shell.json`
```

**Change To:**
```qml
path: `${Quickshell.env("HOME")}/.config/heimdall/shell.json`
```

**Explanation:** This change updates the configuration path to read from the heimdall-cli managed location instead of the Quickshell config directory.

### 2. Update ConfigEnhanced.qml (Line 22)

**File:** `~/.config/quickshell/heimdall/ConfigEnhanced.qml`  
**Line:** 22  
**Current Code:**
```qml
readonly property string configPath: `${Paths.stringify(Paths.config)}/shell.json`
```

**Change To:**
```qml
readonly property string configPath: `${Quickshell.env("HOME")}/.config/heimdall/shell.json`
```

**Explanation:** This ensures the enhanced configuration also reads from the new centralized location.

### 3. Migration Strategy with Fallback Logic

To ensure a smooth transition without breaking existing setups, implement the following migration strategy:

#### Option A: Simple Direct Update (Recommended for Clean Migration)
If you're ready to fully migrate to heimdall-cli management, use the direct updates shown above.

#### Option B: Graceful Fallback Implementation
For a more gradual transition, modify both files to check both locations:

**Config.qml Enhanced Migration:**
```qml
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    // Define both paths
    readonly property string newConfigPath: `${Quickshell.env("HOME")}/.config/heimdall/shell.json`
    readonly property string legacyConfigPath: `${Paths.stringify(Paths.config)}/shell.json`
    
    // Dynamic path selection
    property string actualPath: {
        // Check if new location exists
        let newFile = Qt.createQmlObject(`
            import Quickshell.Io
            FileInfo { path: "${newConfigPath}" }
        `, this);
        
        if (newFile.exists) {
            console.log("Using heimdall-cli managed config at:", newConfigPath);
            return newConfigPath;
        }
        
        // Fall back to legacy location
        console.log("Falling back to legacy config at:", legacyConfigPath);
        return legacyConfigPath;
    }
    
    // Use the selected path
    property var config: JsonFile {
        path: actualPath
        // ... rest of configuration
    }
}
```

**ConfigEnhanced.qml Migration with Logging:**
```qml
QtObject {
    // Check both locations
    readonly property string heimdallPath: `${Quickshell.env("HOME")}/.config/heimdall/shell.json`
    readonly property string quickshellPath: `${Paths.stringify(Paths.config)}/shell.json`
    
    // Select appropriate path with logging
    readonly property string configPath: {
        // Try heimdall-cli location first
        if (FileInfo.exists(heimdallPath)) {
            console.log("[ConfigEnhanced] Using heimdall-cli config:", heimdallPath);
            return heimdallPath;
        }
        
        // Warn about using legacy location
        console.warn("[ConfigEnhanced] Heimdall config not found, using legacy:", quickshellPath);
        console.warn("[ConfigEnhanced] Run 'heimdall-cli config migrate' to update");
        return quickshellPath;
    }
}
```

### 4. Testing Steps

After making the changes, follow these steps to verify everything works correctly:

#### Step 1: Backup Current Configuration
```bash
# Create backup of existing config
cp ~/.config/quickshell/heimdall/shell.json ~/.config/quickshell/heimdall/shell.json.backup
```

#### Step 2: Create New Configuration Location
```bash
# Ensure heimdall directory exists
mkdir -p ~/.config/heimdall

# Copy existing config to new location (if migrating manually)
cp ~/.config/quickshell/heimdall/shell.json ~/.config/heimdall/shell.json
```

#### Step 3: Update Quickshell Files
Apply the changes to Config.qml and ConfigEnhanced.qml as described above.

#### Step 4: Test Configuration Loading
```bash
# Restart Quickshell to test changes
quickshell --reload

# Or if using systemd
systemctl --user restart quickshell
```

#### Step 5: Verify Configuration Path
Check Quickshell logs to confirm it's reading from the correct location:
```bash
# Check journal logs
journalctl --user -u quickshell -n 50 | grep -i config

# Or check Quickshell output directly
quickshell --verbose 2>&1 | grep -i "config\|heimdall"
```

#### Step 6: Test Hot Reload
```bash
# Make a small change to the config
echo '{"test": "value"}' | jq '.' >> ~/.config/heimdall/shell.json

# Verify Quickshell picks up the change
# (Check if hot reload triggers)
```

#### Step 7: Validate Both Tools Work
```bash
# Test heimdall-cli can read/write
heimdall-cli config validate
heimdall-cli config get system.shell

# Test Quickshell still functions
# (Visual check of bar/modules working)
```

### 5. Troubleshooting Common Issues

#### Issue: Quickshell Can't Find Configuration
**Symptom:** Quickshell fails to start or shows default configuration  
**Solution:** 
1. Verify the file exists at `~/.config/heimdall/shell.json`
2. Check file permissions: `ls -la ~/.config/heimdall/shell.json`
3. Ensure the JSON is valid: `jq '.' ~/.config/heimdall/shell.json`

#### Issue: Permission Denied Errors
**Symptom:** Quickshell can't read the configuration file  
**Solution:**
```bash
# Fix permissions
chmod 644 ~/.config/heimdall/shell.json
chmod 755 ~/.config/heimdall
```

#### Issue: Hot Reload Not Working
**Symptom:** Changes to shell.json don't reflect in Quickshell  
**Solution:**
1. Verify the FileWatcher in Config.qml is monitoring the correct path
2. Check if the file's modification time is updating: `stat ~/.config/heimdall/shell.json`
3. Manually trigger reload: `quickshell --reload`

#### Issue: Conflicting Configurations
**Symptom:** Unexpected behavior or settings not applying  
**Solution:**
1. Ensure only one config file is being used
2. Remove or rename the old config: `mv ~/.config/quickshell/heimdall/shell.json ~/.config/quickshell/heimdall/shell.json.old`
3. Check logs for which path is being loaded

### 6. Rollback Procedure

If issues arise, you can quickly rollback to the original configuration:

```bash
# Restore original Quickshell files
cd ~/.config/quickshell/heimdall
git checkout Config.qml ConfigEnhanced.qml

# Or manually revert the path changes
# In Config.qml line 27, change back to:
# path: `${Paths.stringify(Paths.config)}/shell.json`

# In ConfigEnhanced.qml line 22, change back to:
# readonly property string configPath: `${Paths.stringify(Paths.config)}/shell.json`

# Restart Quickshell
quickshell --reload
```

## Rollout Strategy

### Phase 1: Alpha Release
- Internal testing
- Core functionality only
- Limited user group
- Feedback collection

### Phase 2: Beta Release
- Extended testing
- All features enabled
- Wider user base
- Bug fixes and refinements

### Phase 3: Production Release
- Full feature set
- Stable API
- Complete documentation
- Support channels

## Risk Mitigation

### Technical Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| Data loss during migration | High | Automatic backups, rollback capability |
| Breaking changes in Quickshell | Medium | Version detection, compatibility layer |
| Performance degradation | Low | Caching, lazy loading |
| Concurrent modification | Medium | File locking, atomic operations |

### Operational Risks
| Risk | Impact | Mitigation |
|------|--------|------------|
| User adoption resistance | Medium | Backward compatibility, gradual rollout |
| Support burden | Medium | Comprehensive docs, self-healing |
| Feature creep | Low | Strict scope management |

## Success Metrics

### Technical Metrics
- Zero data loss incidents
- < 1% migration failure rate
- < 100ms operation latency
- 99.9% backward compatibility

### User Metrics
- 90% successful auto-configurations
- < 5% support tickets
- 80% feature adoption rate
- 95% user satisfaction

## Timeline

### Development Schedule
- Week 1-2: Core Infrastructure
- Week 2-3: Schema and Validation
- Week 3-4: Property Injection
- Week 4-5: Version Migration
- Week 5-6: CLI Integration
- Week 6-7: Advanced Features
- Week 7-8: Testing and Documentation
- Week 8-9: Beta Testing
- Week 9-10: Production Release

### Milestones
- [ ] M1: Core functionality complete
- [ ] M2: Property injection working
- [ ] M3: Version migration implemented
- [ ] M4: CLI fully integrated
- [ ] M5: Beta release ready
- [ ] M6: Production release

## Dev Log

### Session: 2025-08-12 (Initial)
- Created comprehensive implementation plan
- Defined architecture with Go-specific components
- Established property injection strategy
- Designed version migration system
- Set up testing procedures
- Created rollout strategy

### Session: 2025-08-12 (Update)
- **CRITICAL CHANGE**: Updated configuration location from `~/.config/quickshell/heimdall/shell.json` to `~/.config/heimdall/shell.json`
- Clarified ownership: heimdall-cli owns and manages the configuration
- Updated all path references throughout the document
- Added architecture diagram notes about new location
- Added Quickshell Config.qml update requirements
- Updated testing scenarios to reflect new paths
- Added backup directory location: `~/.config/heimdall/backups/`
- Added documentation requirements for Quickshell integration

### Next Steps
1. Set up Go project structure with new path constants
2. Implement core ConfigManager with `~/.config/heimdall/` directory creation
3. Create schema definitions
4. Build property injection system
5. Develop version migration engine
6. Create migration tool for existing configs at old location
7. Document Quickshell Config.qml changes needed