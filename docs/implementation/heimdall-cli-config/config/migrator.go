package config

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"
)

// VersionMigrator handles configuration version migrations
type VersionMigrator struct {
	migrations map[string]Migration
	history    []MigrationRecord
	backupDir  string
	logger     Logger
	lastBackup string
}

// Migration defines a migration between versions
type Migration interface {
	FromVersion() string
	ToVersion() string
	Migrate(config map[string]interface{}) error
	Rollback(config map[string]interface{}) error
	Validate(config map[string]interface{}) error
}

// MigrationRecord records a migration operation
type MigrationRecord struct {
	From      string    `json:"from"`
	To        string    `json:"to"`
	Timestamp time.Time `json:"timestamp"`
	Backup    string    `json:"backup"`
	Success   bool      `json:"success"`
}

// NewVersionMigrator creates a new version migrator
func NewVersionMigrator(backupDir string, logger Logger) *VersionMigrator {
	migrator := &VersionMigrator{
		migrations: make(map[string]Migration),
		history:    make([]MigrationRecord, 0),
		backupDir:  backupDir,
		logger:     logger,
	}

	// Register migrations
	migrator.registerMigrations()

	// Load migration history
	migrator.loadHistory()

	return migrator
}

// Migrate performs migration to the latest version
func (m *VersionMigrator) Migrate(config *ShellConfig) (*ShellConfig, error) {
	currentVersion := config.Version
	targetVersion := CurrentSchemaVersion

	if currentVersion == targetVersion {
		m.logger.Info("Configuration is already at latest version",
			Field{"version", currentVersion})
		return config, nil
	}

	// Find migration path
	path := m.findMigrationPath(currentVersion, targetVersion)
	if len(path) == 0 {
		return nil, fmt.Errorf("no migration path from %s to %s", currentVersion, targetVersion)
	}

	// Create backup before migration
	backupPath, err := m.createBackup(config)
	if err != nil {
		return nil, fmt.Errorf("failed to create pre-migration backup: %w", err)
	}
	m.lastBackup = backupPath

	// Convert to map for migration
	configMap, err := structToMap(config)
	if err != nil {
		return nil, fmt.Errorf("failed to convert config to map: %w", err)
	}

	// Apply migrations
	for _, migration := range path {
		m.logger.Info("Applying migration",
			Field{"from", migration.FromVersion()},
			Field{"to", migration.ToVersion()})

		// Validate pre-conditions
		if err := migration.Validate(configMap); err != nil {
			return nil, fmt.Errorf("migration validation failed: %w", err)
		}

		// Apply migration
		if err := migration.Migrate(configMap); err != nil {
			// Record failed migration
			m.recordMigration(migration.FromVersion(), migration.ToVersion(), backupPath, false)
			return nil, fmt.Errorf("migration failed: %w", err)
		}

		// Update version in config
		configMap["version"] = migration.ToVersion()

		// Record successful migration
		m.recordMigration(migration.FromVersion(), migration.ToVersion(), backupPath, true)
	}

	// Convert back to struct
	migratedConfig := &ShellConfig{}
	if err := mapToStruct(configMap, migratedConfig); err != nil {
		return nil, fmt.Errorf("failed to convert map to config: %w", err)
	}

	m.logger.Info("Migration completed successfully",
		Field{"fromVersion", currentVersion},
		Field{"toVersion", targetVersion})

	return migratedConfig, nil
}

// Rollback rolls back the last migration
func (m *VersionMigrator) Rollback() error {
	if m.lastBackup == "" {
		return fmt.Errorf("no backup available for rollback")
	}

	// Read backup file
	data, err := os.ReadFile(m.lastBackup)
	if err != nil {
		return fmt.Errorf("failed to read backup: %w", err)
	}

	// Get config path
	configPath := GetConfigPath()

	// Restore backup
	if err := os.WriteFile(configPath, data, 0644); err != nil {
		return fmt.Errorf("failed to restore backup: %w", err)
	}

	m.logger.Info("Rollback completed successfully",
		Field{"backup", m.lastBackup})

	return nil
}

// MigrateToVersion migrates to a specific version
func (m *VersionMigrator) MigrateToVersion(config *ShellConfig, targetVersion string) (*ShellConfig, error) {
	currentVersion := config.Version

	if currentVersion == targetVersion {
		return config, nil
	}

	// Find migration path
	path := m.findMigrationPath(currentVersion, targetVersion)
	if len(path) == 0 {
		return nil, fmt.Errorf("no migration path from %s to %s", currentVersion, targetVersion)
	}

	// Create backup
	backupPath, err := m.createBackup(config)
	if err != nil {
		return nil, fmt.Errorf("failed to create backup: %w", err)
	}
	m.lastBackup = backupPath

	// Convert to map
	configMap, err := structToMap(config)
	if err != nil {
		return nil, fmt.Errorf("failed to convert config: %w", err)
	}

	// Apply migrations
	for _, migration := range path {
		if err := migration.Migrate(configMap); err != nil {
			m.recordMigration(migration.FromVersion(), migration.ToVersion(), backupPath, false)
			return nil, err
		}
		configMap["version"] = migration.ToVersion()
		m.recordMigration(migration.FromVersion(), migration.ToVersion(), backupPath, true)
	}

	// Convert back
	migratedConfig := &ShellConfig{}
	if err := mapToStruct(configMap, migratedConfig); err != nil {
		return nil, err
	}

	return migratedConfig, nil
}

// GetAvailableVersions returns all available versions
func (m *VersionMigrator) GetAvailableVersions() []string {
	versions := make(map[string]bool)

	for _, migration := range m.migrations {
		versions[migration.FromVersion()] = true
		versions[migration.ToVersion()] = true
	}

	// Convert to sorted slice
	result := make([]string, 0, len(versions))
	for version := range versions {
		result = append(result, version)
	}
	sort.Strings(result)

	return result
}

// GetMigrationHistory returns migration history
func (m *VersionMigrator) GetMigrationHistory() []MigrationRecord {
	return m.history
}

// registerMigrations registers all available migrations
func (m *VersionMigrator) registerMigrations() {
	// Register migration from 0.9.0 to 1.0.0
	m.registerMigration(&Migration_0_9_0_to_1_0_0{})

	// Add more migrations as needed
}

// registerMigration registers a single migration
func (m *VersionMigrator) registerMigration(migration Migration) {
	key := fmt.Sprintf("%s->%s", migration.FromVersion(), migration.ToVersion())
	m.migrations[key] = migration
}

// findMigrationPath finds the migration path between versions
func (m *VersionMigrator) findMigrationPath(from, to string) []Migration {
	// Build migration graph
	graph := m.buildMigrationGraph()

	// Find shortest path using BFS
	path := m.findShortestPath(graph, from, to)

	// Convert path to migrations
	migrations := make([]Migration, 0)
	for i := 0; i < len(path)-1; i++ {
		key := fmt.Sprintf("%s->%s", path[i], path[i+1])
		if migration, ok := m.migrations[key]; ok {
			migrations = append(migrations, migration)
		}
	}

	return migrations
}

// buildMigrationGraph builds a graph of migrations
func (m *VersionMigrator) buildMigrationGraph() map[string][]string {
	graph := make(map[string][]string)

	for _, migration := range m.migrations {
		from := migration.FromVersion()
		to := migration.ToVersion()

		if _, ok := graph[from]; !ok {
			graph[from] = make([]string, 0)
		}
		graph[from] = append(graph[from], to)
	}

	return graph
}

// findShortestPath finds shortest path in migration graph using BFS
func (m *VersionMigrator) findShortestPath(graph map[string][]string, from, to string) []string {
	if from == to {
		return []string{from}
	}

	// BFS queue
	type node struct {
		version string
		path    []string
	}

	queue := []node{{version: from, path: []string{from}}}
	visited := make(map[string]bool)
	visited[from] = true

	for len(queue) > 0 {
		current := queue[0]
		queue = queue[1:]

		// Check neighbors
		if neighbors, ok := graph[current.version]; ok {
			for _, neighbor := range neighbors {
				if neighbor == to {
					// Found target
					return append(current.path, to)
				}

				if !visited[neighbor] {
					visited[neighbor] = true
					newPath := make([]string, len(current.path))
					copy(newPath, current.path)
					newPath = append(newPath, neighbor)
					queue = append(queue, node{version: neighbor, path: newPath})
				}
			}
		}
	}

	return nil // No path found
}

// createBackup creates a backup of the configuration
func (m *VersionMigrator) createBackup(config *ShellConfig) (string, error) {
	// Generate backup filename
	timestamp := time.Now().Format("20060102-150405")
	filename := fmt.Sprintf("migration-%s-%s.json", config.Version, timestamp)
	backupPath := filepath.Join(m.backupDir, filename)

	// Marshal config
	data, err := json.MarshalIndent(config, "", "  ")
	if err != nil {
		return "", fmt.Errorf("failed to marshal config: %w", err)
	}

	// Write backup
	if err := os.WriteFile(backupPath, data, 0600); err != nil {
		return "", fmt.Errorf("failed to write backup: %w", err)
	}

	m.logger.Debug("Created migration backup",
		Field{"path", backupPath})

	return backupPath, nil
}

// recordMigration records a migration in history
func (m *VersionMigrator) recordMigration(from, to, backup string, success bool) {
	record := MigrationRecord{
		From:      from,
		To:        to,
		Timestamp: time.Now(),
		Backup:    backup,
		Success:   success,
	}

	m.history = append(m.history, record)
	m.saveHistory()
}

// loadHistory loads migration history
func (m *VersionMigrator) loadHistory() {
	historyPath := filepath.Join(m.backupDir, "migration-history.json")

	data, err := os.ReadFile(historyPath)
	if err != nil {
		if !os.IsNotExist(err) {
			m.logger.Warn("Failed to load migration history",
				Field{"error", err.Error()})
		}
		return
	}

	if err := json.Unmarshal(data, &m.history); err != nil {
		m.logger.Warn("Failed to parse migration history",
			Field{"error", err.Error()})
	}
}

// saveHistory saves migration history
func (m *VersionMigrator) saveHistory() {
	historyPath := filepath.Join(m.backupDir, "migration-history.json")

	data, err := json.MarshalIndent(m.history, "", "  ")
	if err != nil {
		m.logger.Warn("Failed to marshal migration history",
			Field{"error", err.Error()})
		return
	}

	if err := os.WriteFile(historyPath, data, 0600); err != nil {
		m.logger.Warn("Failed to save migration history",
			Field{"error", err.Error()})
	}
}

// structToMap converts struct to map (helper function)
func structToMap(v interface{}) (map[string]interface{}, error) {
	data, err := json.Marshal(v)
	if err != nil {
		return nil, err
	}

	var result map[string]interface{}
	if err := json.Unmarshal(data, &result); err != nil {
		return nil, err
	}

	return result, nil
}

// mapToStruct converts map to struct (helper function)
func mapToStruct(m map[string]interface{}, v interface{}) error {
	data, err := json.Marshal(m)
	if err != nil {
		return err
	}

	return json.Unmarshal(data, v)
}

// Migration_0_9_0_to_1_0_0 migrates from version 0.9.0 to 1.0.0
type Migration_0_9_0_to_1_0_0 struct{}

func (m *Migration_0_9_0_to_1_0_0) FromVersion() string { return "0.9.0" }
func (m *Migration_0_9_0_to_1_0_0) ToVersion() string   { return "1.0.0" }

func (m *Migration_0_9_0_to_1_0_0) Migrate(config map[string]interface{}) error {
	// Example migration: rename old fields to new structure

	// Migrate old "panel" to new "bar"
	if panel, ok := config["panel"]; ok {
		config["bar"] = panel
		delete(config, "panel")
	}

	// Migrate old "theme" structure
	if theme, ok := config["theme"].(map[string]interface{}); ok {
		if appearance, ok := config["appearance"].(map[string]interface{}); ok {
			// Merge theme into appearance
			for k, v := range theme {
				appearance[k] = v
			}
		} else {
			config["appearance"] = theme
		}
		delete(config, "theme")
	}

	// Add new required fields
	if _, ok := config["hotReload"]; !ok {
		config["hotReload"] = map[string]interface{}{
			"enabled": true,
			"watchPaths": []string{
				"~/.config/heimdall/shell.json",
			},
			"debounce": 100,
		}
	}

	// Update metadata
	if metadata, ok := config["metadata"].(map[string]interface{}); ok {
		metadata["migrated"] = time.Now().Format(time.RFC3339)
		metadata["migrationVersion"] = "1.0.0"
	}

	return nil
}

func (m *Migration_0_9_0_to_1_0_0) Rollback(config map[string]interface{}) error {
	// Reverse the migration

	// Restore "bar" to "panel"
	if bar, ok := config["bar"]; ok {
		config["panel"] = bar
		delete(config, "bar")
	}

	// Remove new fields
	delete(config, "hotReload")

	// Clean up metadata
	if metadata, ok := config["metadata"].(map[string]interface{}); ok {
		delete(metadata, "migrated")
		delete(metadata, "migrationVersion")
	}

	return nil
}

func (m *Migration_0_9_0_to_1_0_0) Validate(config map[string]interface{}) error {
	// Validate that the config can be migrated
	version, ok := config["version"].(string)
	if !ok {
		return fmt.Errorf("missing version field")
	}

	if !strings.HasPrefix(version, "0.9") {
		return fmt.Errorf("invalid source version: %s", version)
	}

	return nil
}
