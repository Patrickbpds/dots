package config

import (
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sync"
	"time"
)

const (
	// DefaultConfigPath is the primary configuration location
	DefaultConfigPath = "heimdall/shell.json"
	// BackupDirPath is the backup directory location
	BackupDirPath = "heimdall/backups"
	// LegacyConfigPath is the old quickshell location for migration
	LegacyConfigPath = "quickshell/heimdall/shell.json"
)

// ConfigManager manages the shell configuration lifecycle
type ConfigManager struct {
	configPath    string
	backupDir     string
	schemaVersion string
	validator     *SchemaValidator
	migrator      *VersionMigrator
	injector      *PropertyInjector
	mu            sync.RWMutex
	cache         *ConfigCache
	logger        Logger
}

// ConfigCache stores cached configuration data
type ConfigCache struct {
	config   *ShellConfig
	checksum string
	loadTime time.Time
	ttl      time.Duration
}

// Logger interface for structured logging
type Logger interface {
	Debug(msg string, fields ...Field)
	Info(msg string, fields ...Field)
	Warn(msg string, fields ...Field)
	Error(msg string, fields ...Field)
}

// Field represents a log field
type Field struct {
	Key   string
	Value interface{}
}

// NewConfigManager creates a new configuration manager
func NewConfigManager(logger Logger) (*ConfigManager, error) {
	configPath := GetConfigPath()
	backupDir := GetBackupDir()

	// Ensure directories exist
	if err := os.MkdirAll(filepath.Dir(configPath), 0755); err != nil {
		return nil, fmt.Errorf("failed to create config directory: %w", err)
	}
	if err := os.MkdirAll(backupDir, 0755); err != nil {
		return nil, fmt.Errorf("failed to create backup directory: %w", err)
	}

	cm := &ConfigManager{
		configPath:    configPath,
		backupDir:     backupDir,
		schemaVersion: CurrentSchemaVersion,
		validator:     NewSchemaValidator(),
		migrator:      NewVersionMigrator(backupDir, logger),
		injector:      NewPropertyInjector(),
		logger:        logger,
		cache: &ConfigCache{
			ttl: 5 * time.Second,
		},
	}

	return cm, nil
}

// Initialize sets up the configuration system
func (cm *ConfigManager) Initialize() error {
	cm.mu.Lock()
	defer cm.mu.Unlock()

	cm.logger.Info("Initializing configuration manager",
		Field{"configPath", cm.configPath},
		Field{"backupDir", cm.backupDir})

	// Check for migration from legacy location
	if err := cm.migrateFromLegacyLocation(); err != nil {
		cm.logger.Warn("Failed to migrate from legacy location",
			Field{"error", err.Error()})
	}

	// Check if config exists
	if _, err := os.Stat(cm.configPath); os.IsNotExist(err) {
		cm.logger.Info("No configuration found, creating default")
		// Create default configuration
		config := GetDefaultConfig()
		if err := cm.saveInternal(config); err != nil {
			return fmt.Errorf("failed to create default config: %w", err)
		}
	}

	// Validate existing configuration
	config, err := cm.loadInternal()
	if err != nil {
		return fmt.Errorf("failed to load configuration: %w", err)
	}

	// Run validation
	if errors := cm.validator.Validate(config); len(errors) > 0 {
		cm.logger.Warn("Configuration validation warnings",
			Field{"errors", errors})
	}

	return nil
}

// Load reads and returns the current configuration
func (cm *ConfigManager) Load() (*ShellConfig, error) {
	cm.mu.RLock()
	defer cm.mu.RUnlock()

	// Check cache
	if cm.cache.IsValid(cm.configPath) {
		cm.logger.Debug("Returning cached configuration")
		return cm.cache.config, nil
	}

	config, err := cm.loadInternal()
	if err != nil {
		return nil, err
	}

	// Update cache
	cm.cache.config = config
	cm.cache.loadTime = time.Now()

	return config, nil
}

// Save writes the configuration to disk
func (cm *ConfigManager) Save(config *ShellConfig) error {
	cm.mu.Lock()
	defer cm.mu.Unlock()

	// Validate before saving
	if errors := cm.validator.Validate(config); len(errors) > 0 {
		for _, err := range errors {
			if err.Severity == SeverityError || err.Severity == SeverityCritical {
				return fmt.Errorf("validation failed: %v", errors)
			}
		}
	}

	// Create backup before saving
	if err := cm.createBackup(); err != nil {
		cm.logger.Warn("Failed to create backup",
			Field{"error", err.Error()})
	}

	// Update metadata
	config.Metadata.LastModified = time.Now()
	config.Metadata.ManagedBy = "heimdall-cli"

	// Save configuration
	if err := cm.saveInternal(config); err != nil {
		return fmt.Errorf("failed to save configuration: %w", err)
	}

	// Invalidate cache
	cm.cache.config = nil

	cm.logger.Info("Configuration saved successfully",
		Field{"path", cm.configPath})

	return nil
}

// Validate checks the configuration for errors
func (cm *ConfigManager) Validate(config *ShellConfig) []ValidationError {
	return cm.validator.Validate(config)
}

// Migrate upgrades the configuration to the latest version
func (cm *ConfigManager) Migrate(config *ShellConfig) error {
	cm.mu.Lock()
	defer cm.mu.Unlock()

	// Create backup before migration
	if err := cm.createBackup(); err != nil {
		return fmt.Errorf("failed to create pre-migration backup: %w", err)
	}

	// Perform migration
	migrated, err := cm.migrator.Migrate(config)
	if err != nil {
		return fmt.Errorf("migration failed: %w", err)
	}

	// Save migrated configuration
	if err := cm.saveInternal(migrated); err != nil {
		// Attempt rollback
		cm.logger.Error("Failed to save migrated config, attempting rollback",
			Field{"error", err.Error()})
		if rollbackErr := cm.migrator.Rollback(); rollbackErr != nil {
			return fmt.Errorf("migration failed and rollback failed: %v, %v", err, rollbackErr)
		}
		return fmt.Errorf("migration failed (rolled back): %w", err)
	}

	cm.logger.Info("Configuration migrated successfully",
		Field{"fromVersion", config.Version},
		Field{"toVersion", migrated.Version})

	return nil
}

// InjectDefaults adds missing properties with default values
func (cm *ConfigManager) InjectDefaults(config *ShellConfig) error {
	cm.mu.Lock()
	defer cm.mu.Unlock()

	// Create backup before injection
	if err := cm.createBackup(); err != nil {
		cm.logger.Warn("Failed to create pre-injection backup",
			Field{"error", err.Error()})
	}

	// Perform injection
	if err := cm.injector.InjectDefaults(config); err != nil {
		return fmt.Errorf("property injection failed: %w", err)
	}

	// Save updated configuration
	if err := cm.saveInternal(config); err != nil {
		return fmt.Errorf("failed to save injected config: %w", err)
	}

	cm.logger.Info("Default properties injected successfully")

	return nil
}

// GetConfigPath returns the configuration file path
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
	return filepath.Join(configHome, DefaultConfigPath)
}

// GetBackupDir returns the backup directory path
func GetBackupDir() string {
	// Check environment variable first
	if envPath := os.Getenv("HEIMDALL_BACKUP_DIR"); envPath != "" {
		return envPath
	}

	// Use XDG_CONFIG_HOME if set
	configHome := os.Getenv("XDG_CONFIG_HOME")
	if configHome == "" {
		home, _ := os.UserHomeDir()
		configHome = filepath.Join(home, ".config")
	}

	return filepath.Join(configHome, BackupDirPath)
}

// loadInternal loads configuration from disk (must be called with lock)
func (cm *ConfigManager) loadInternal() (*ShellConfig, error) {
	file, err := os.Open(cm.configPath)
	if err != nil {
		return nil, fmt.Errorf("failed to open config file: %w", err)
	}
	defer file.Close()

	// Read file content
	data, err := io.ReadAll(file)
	if err != nil {
		return nil, fmt.Errorf("failed to read config file: %w", err)
	}

	// Parse JSON with comment preservation
	config := &ShellConfig{}
	if err := json.Unmarshal(data, config); err != nil {
		return nil, fmt.Errorf("failed to parse config JSON: %w", err)
	}

	return config, nil
}

// saveInternal saves configuration to disk (must be called with lock)
func (cm *ConfigManager) saveInternal(config *ShellConfig) error {
	// Marshal to JSON with indentation
	data, err := json.MarshalIndent(config, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal config: %w", err)
	}

	// Write to temporary file first (atomic operation)
	tempFile := cm.configPath + ".tmp"
	if err := os.WriteFile(tempFile, data, 0644); err != nil {
		return fmt.Errorf("failed to write temp file: %w", err)
	}

	// Atomic rename
	if err := os.Rename(tempFile, cm.configPath); err != nil {
		os.Remove(tempFile) // Clean up temp file
		return fmt.Errorf("failed to rename temp file: %w", err)
	}

	return nil
}

// createBackup creates a backup of the current configuration
func (cm *ConfigManager) createBackup() error {
	// Check if config exists
	if _, err := os.Stat(cm.configPath); os.IsNotExist(err) {
		return nil // Nothing to backup
	}

	// Read current config
	data, err := os.ReadFile(cm.configPath)
	if err != nil {
		return fmt.Errorf("failed to read config for backup: %w", err)
	}

	// Generate backup filename with timestamp
	timestamp := time.Now().Format("20060102-150405")
	backupFile := filepath.Join(cm.backupDir, fmt.Sprintf("shell-%s.json", timestamp))

	// Write backup
	if err := os.WriteFile(backupFile, data, 0600); err != nil {
		return fmt.Errorf("failed to write backup: %w", err)
	}

	cm.logger.Debug("Created configuration backup",
		Field{"backup", backupFile})

	return nil
}

// migrateFromLegacyLocation migrates config from old quickshell location
func (cm *ConfigManager) migrateFromLegacyLocation() error {
	// Check if already migrated
	if _, err := os.Stat(cm.configPath); err == nil {
		return nil // Already exists at new location
	}

	// Check for legacy config
	configHome := os.Getenv("XDG_CONFIG_HOME")
	if configHome == "" {
		home, _ := os.UserHomeDir()
		configHome = filepath.Join(home, ".config")
	}
	legacyPath := filepath.Join(configHome, LegacyConfigPath)

	if _, err := os.Stat(legacyPath); os.IsNotExist(err) {
		return nil // No legacy config to migrate
	}

	cm.logger.Info("Migrating configuration from legacy location",
		Field{"from", legacyPath},
		Field{"to", cm.configPath})

	// Read legacy config
	data, err := os.ReadFile(legacyPath)
	if err != nil {
		return fmt.Errorf("failed to read legacy config: %w", err)
	}

	// Create migration backup
	backupFile := filepath.Join(cm.backupDir, "migrated-from-quickshell.json")
	if err := os.WriteFile(backupFile, data, 0600); err != nil {
		cm.logger.Warn("Failed to create migration backup",
			Field{"error", err.Error()})
	}

	// Parse and update config
	config := &ShellConfig{}
	if err := json.Unmarshal(data, config); err != nil {
		return fmt.Errorf("failed to parse legacy config: %w", err)
	}

	// Update metadata
	config.Metadata.LastModified = time.Now()
	config.Metadata.ManagedBy = "heimdall-cli"

	// Save to new location
	if err := cm.saveInternal(config); err != nil {
		return fmt.Errorf("failed to save migrated config: %w", err)
	}

	cm.logger.Info("Configuration migrated successfully")

	return nil
}

// IsValid checks if the cache is still valid
func (c *ConfigCache) IsValid(configPath string) bool {
	if c.config == nil {
		return false
	}

	// Check TTL
	if time.Since(c.loadTime) > c.ttl {
		return false
	}

	// Check file modification time
	info, err := os.Stat(configPath)
	if err != nil {
		return false
	}

	return info.ModTime().Before(c.loadTime) || info.ModTime().Equal(c.loadTime)
}
