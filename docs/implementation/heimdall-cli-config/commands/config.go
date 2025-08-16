package commands

import (
	"encoding/json"
	"fmt"
	"os"
	"strings"

	"github.com/spf13/cobra"
	"heimdall-cli/config"
)

// ConfigCmd represents the config command
var ConfigCmd = &cobra.Command{
	Use:   "config",
	Short: "Manage shell configuration",
	Long: `Manage the Heimdall shell configuration at ~/.config/heimdall/shell.json.
This command provides tools for creating, validating, migrating, and managing
your shell configuration.`,
}

// initCmd initializes a new configuration
var initCmd = &cobra.Command{
	Use:   "init [profile]",
	Short: "Initialize a new configuration",
	Long: `Initialize a new shell configuration with default values.
You can optionally specify a profile (default, minimal, gaming, productivity, development).`,
	Args: cobra.MaximumNArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		profile := "default"
		if len(args) > 0 {
			profile = args[0]
		}

		force, _ := cmd.Flags().GetBool("force")

		// Create config manager
		logger := NewLogger()
		manager, err := config.NewConfigManager(logger)
		if err != nil {
			return fmt.Errorf("failed to create config manager: %w", err)
		}

		// Check if config already exists
		configPath := config.GetConfigPath()
		if _, err := os.Stat(configPath); err == nil && !force {
			return fmt.Errorf("configuration already exists at %s. Use --force to overwrite", configPath)
		}

		// Get profile configuration
		cfg := config.GetProfileConfig(profile)

		// Save configuration
		if err := manager.Save(cfg); err != nil {
			return fmt.Errorf("failed to save configuration: %w", err)
		}

		fmt.Printf("✓ Configuration initialized at %s with profile '%s'\n", configPath, profile)
		return nil
	},
}

// validateCmd validates the configuration
var validateCmd = &cobra.Command{
	Use:   "validate",
	Short: "Validate the current configuration",
	Long:  `Validate the shell configuration for errors and warnings.`,
	RunE: func(cmd *cobra.Command, args []string) error {
		logger := NewLogger()
		manager, err := config.NewConfigManager(logger)
		if err != nil {
			return fmt.Errorf("failed to create config manager: %w", err)
		}

		// Load configuration
		cfg, err := manager.Load()
		if err != nil {
			return fmt.Errorf("failed to load configuration: %w", err)
		}

		// Validate configuration
		errors := manager.Validate(cfg)

		if len(errors) == 0 {
			fmt.Println("✓ Configuration is valid")
			return nil
		}

		// Display errors
		fmt.Printf("Found %d validation issues:\n\n", len(errors))

		criticalCount := 0
		errorCount := 0
		warningCount := 0

		for _, e := range errors {
			icon := "⚠"
			switch e.Severity {
			case config.SeverityCritical:
				icon = "✗"
				criticalCount++
			case config.SeverityError:
				icon = "✗"
				errorCount++
			case config.SeverityWarning:
				icon = "⚠"
				warningCount++
			}

			fmt.Printf("%s %s: %s\n", icon, e.Path, e.Message)

			if e.Fix != nil && e.Fix.Description != "" {
				fmt.Printf("  → %s\n", e.Fix.Description)
				if e.Fix.Command != "" {
					fmt.Printf("  → Run: %s\n", e.Fix.Command)
				}
			}
		}

		fmt.Println()
		fmt.Printf("Summary: %d critical, %d errors, %d warnings\n",
			criticalCount, errorCount, warningCount)

		if criticalCount > 0 || errorCount > 0 {
			return fmt.Errorf("validation failed with errors")
		}

		return nil
	},
}

// migrateCmd migrates the configuration
var migrateCmd = &cobra.Command{
	Use:   "migrate [version]",
	Short: "Migrate configuration to a new version",
	Long: `Migrate the shell configuration to a new schema version.
If no version is specified, migrates to the latest version.`,
	Args: cobra.MaximumNArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		logger := NewLogger()
		manager, err := config.NewConfigManager(logger)
		if err != nil {
			return fmt.Errorf("failed to create config manager: %w", err)
		}

		// Load configuration
		cfg, err := manager.Load()
		if err != nil {
			return fmt.Errorf("failed to load configuration: %w", err)
		}

		currentVersion := cfg.Version
		targetVersion := config.CurrentSchemaVersion
		if len(args) > 0 {
			targetVersion = args[0]
		}

		if currentVersion == targetVersion {
			fmt.Printf("Configuration is already at version %s\n", targetVersion)
			return nil
		}

		fmt.Printf("Migrating configuration from %s to %s...\n", currentVersion, targetVersion)

		// Perform migration
		if err := manager.Migrate(cfg); err != nil {
			return fmt.Errorf("migration failed: %w", err)
		}

		fmt.Printf("✓ Configuration migrated successfully to version %s\n", targetVersion)
		fmt.Println("  A backup has been created in ~/.config/heimdall/backups/")

		return nil
	},
}

// injectCmd injects default properties
var injectCmd = &cobra.Command{
	Use:   "inject",
	Short: "Inject missing default properties",
	Long:  `Inject missing default properties into the configuration without overwriting existing values.`,
	RunE: func(cmd *cobra.Command, args []string) error {
		logger := NewLogger()
		manager, err := config.NewConfigManager(logger)
		if err != nil {
			return fmt.Errorf("failed to create config manager: %w", err)
		}

		// Load configuration
		cfg, err := manager.Load()
		if err != nil {
			return fmt.Errorf("failed to load configuration: %w", err)
		}

		// Inject defaults
		if err := manager.InjectDefaults(cfg); err != nil {
			return fmt.Errorf("failed to inject defaults: %w", err)
		}

		fmt.Println("✓ Default properties injected successfully")
		fmt.Println("  User-customized values have been preserved")

		return nil
	},
}

// getCmd gets a configuration value
var getCmd = &cobra.Command{
	Use:   "get <path>",
	Short: "Get a configuration value",
	Long: `Get a specific configuration value by its path.
Example: heimdall-cli config get system.shell`,
	Args: cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		logger := NewLogger()
		manager, err := config.NewConfigManager(logger)
		if err != nil {
			return fmt.Errorf("failed to create config manager: %w", err)
		}

		// Load configuration
		cfg, err := manager.Load()
		if err != nil {
			return fmt.Errorf("failed to load configuration: %w", err)
		}

		// Convert to map for easy access
		configMap, err := structToMap(cfg)
		if err != nil {
			return fmt.Errorf("failed to process configuration: %w", err)
		}

		// Get value by path
		value := getValueByPath(configMap, args[0])
		if value == nil {
			return fmt.Errorf("path not found: %s", args[0])
		}

		// Output format
		outputJSON, _ := cmd.Flags().GetBool("json")
		if outputJSON {
			data, err := json.MarshalIndent(value, "", "  ")
			if err != nil {
				return fmt.Errorf("failed to format output: %w", err)
			}
			fmt.Println(string(data))
		} else {
			fmt.Printf("%v\n", value)
		}

		return nil
	},
}

// setCmd sets a configuration value
var setCmd = &cobra.Command{
	Use:   "set <path> <value>",
	Short: "Set a configuration value",
	Long: `Set a specific configuration value by its path.
Example: heimdall-cli config set system.shell zsh`,
	Args: cobra.ExactArgs(2),
	RunE: func(cmd *cobra.Command, args []string) error {
		logger := NewLogger()
		manager, err := config.NewConfigManager(logger)
		if err != nil {
			return fmt.Errorf("failed to create config manager: %w", err)
		}

		// Load configuration
		cfg, err := manager.Load()
		if err != nil {
			return fmt.Errorf("failed to load configuration: %w", err)
		}

		// Convert to map for manipulation
		configMap, err := structToMap(cfg)
		if err != nil {
			return fmt.Errorf("failed to process configuration: %w", err)
		}

		// Parse value
		var value interface{}
		if err := json.Unmarshal([]byte(args[1]), &value); err != nil {
			// If JSON parsing fails, treat as string
			value = args[1]
		}

		// Set value by path
		if err := setValueByPath(configMap, args[0], value); err != nil {
			return fmt.Errorf("failed to set value: %w", err)
		}

		// Convert back to struct
		if err := mapToStruct(configMap, cfg); err != nil {
			return fmt.Errorf("failed to update configuration: %w", err)
		}

		// Save configuration
		if err := manager.Save(cfg); err != nil {
			return fmt.Errorf("failed to save configuration: %w", err)
		}

		fmt.Printf("✓ Set %s = %v\n", args[0], value)

		return nil
	},
}

// lockCmd locks a configuration path
var lockCmd = &cobra.Command{
	Use:   "lock <path>",
	Short: "Lock a configuration path from automatic updates",
	Long: `Lock a configuration path to prevent it from being modified by automatic updates.
Locked paths will be preserved during property injection and migrations.`,
	Args: cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		logger := NewLogger()
		manager, err := config.NewConfigManager(logger)
		if err != nil {
			return fmt.Errorf("failed to create config manager: %w", err)
		}

		// Load configuration
		cfg, err := manager.Load()
		if err != nil {
			return fmt.Errorf("failed to load configuration: %w", err)
		}

		// Get injector
		injector := config.NewPropertyInjector()
		injector.SetUserLock(cfg, args[0])

		// Save configuration
		if err := manager.Save(cfg); err != nil {
			return fmt.Errorf("failed to save configuration: %w", err)
		}

		fmt.Printf("✓ Locked path: %s\n", args[0])
		fmt.Println("  This path will be preserved during automatic updates")

		return nil
	},
}

// unlockCmd unlocks a configuration path
var unlockCmd = &cobra.Command{
	Use:   "unlock <path>",
	Short: "Unlock a configuration path",
	Long:  `Unlock a previously locked configuration path to allow automatic updates.`,
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		logger := NewLogger()
		manager, err := config.NewConfigManager(logger)
		if err != nil {
			return fmt.Errorf("failed to create config manager: %w", err)
		}

		// Load configuration
		cfg, err := manager.Load()
		if err != nil {
			return fmt.Errorf("failed to load configuration: %w", err)
		}

		// Get injector
		injector := config.NewPropertyInjector()
		injector.RemoveUserLock(cfg, args[0])

		// Save configuration
		if err := manager.Save(cfg); err != nil {
			return fmt.Errorf("failed to save configuration: %w", err)
		}

		fmt.Printf("✓ Unlocked path: %s\n", args[0])

		return nil
	},
}

// exportCmd exports the configuration
var exportCmd = &cobra.Command{
	Use:   "export [file]",
	Short: "Export configuration to a file",
	Long:  `Export the current configuration to a file or stdout.`,
	Args:  cobra.MaximumNArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		logger := NewLogger()
		manager, err := config.NewConfigManager(logger)
		if err != nil {
			return fmt.Errorf("failed to create config manager: %w", err)
		}

		// Load configuration
		cfg, err := manager.Load()
		if err != nil {
			return fmt.Errorf("failed to load configuration: %w", err)
		}

		// Marshal configuration
		data, err := json.MarshalIndent(cfg, "", "  ")
		if err != nil {
			return fmt.Errorf("failed to marshal configuration: %w", err)
		}

		// Output to file or stdout
		if len(args) > 0 {
			outputFile := args[0]
			if err := os.WriteFile(outputFile, data, 0644); err != nil {
				return fmt.Errorf("failed to write file: %w", err)
			}
			fmt.Printf("✓ Configuration exported to %s\n", outputFile)
		} else {
			fmt.Println(string(data))
		}

		return nil
	},
}

// importCmd imports a configuration
var importCmd = &cobra.Command{
	Use:   "import <file>",
	Short: "Import configuration from a file",
	Long:  `Import configuration from a JSON file.`,
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		logger := NewLogger()
		manager, err := config.NewConfigManager(logger)
		if err != nil {
			return fmt.Errorf("failed to create config manager: %w", err)
		}

		// Read input file
		data, err := os.ReadFile(args[0])
		if err != nil {
			return fmt.Errorf("failed to read file: %w", err)
		}

		// Parse configuration
		cfg := &config.ShellConfig{}
		if err := json.Unmarshal(data, cfg); err != nil {
			return fmt.Errorf("failed to parse configuration: %w", err)
		}

		// Validate configuration
		if errors := manager.Validate(cfg); len(errors) > 0 {
			for _, e := range errors {
				if e.Severity == config.SeverityError || e.Severity == config.SeverityCritical {
					return fmt.Errorf("imported configuration has validation errors")
				}
			}
		}

		// Save configuration
		if err := manager.Save(cfg); err != nil {
			return fmt.Errorf("failed to save configuration: %w", err)
		}

		fmt.Printf("✓ Configuration imported from %s\n", args[0])

		return nil
	},
}

// Helper functions

// structToMap converts struct to map
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

// mapToStruct converts map to struct
func mapToStruct(m map[string]interface{}, v interface{}) error {
	data, err := json.Marshal(m)
	if err != nil {
		return err
	}

	return json.Unmarshal(data, v)
}

// getValueByPath gets value from map by path
func getValueByPath(data map[string]interface{}, path string) interface{} {
	parts := strings.Split(path, ".")
	current := data

	for i, part := range parts {
		if i == len(parts)-1 {
			return current[part]
		}

		if next, ok := current[part].(map[string]interface{}); ok {
			current = next
		} else {
			return nil
		}
	}

	return nil
}

// setValueByPath sets value in map by path
func setValueByPath(data map[string]interface{}, path string, value interface{}) error {
	parts := strings.Split(path, ".")
	current := data

	for i := 0; i < len(parts)-1; i++ {
		part := parts[i]

		if next, ok := current[part].(map[string]interface{}); ok {
			current = next
		} else {
			// Create missing intermediate objects
			newMap := make(map[string]interface{})
			current[part] = newMap
			current = newMap
		}
	}

	current[parts[len(parts)-1]] = value
	return nil
}

// NewLogger creates a simple logger implementation
func NewLogger() config.Logger {
	return &SimpleLogger{}
}

// SimpleLogger is a simple logger implementation
type SimpleLogger struct{}

func (l *SimpleLogger) Debug(msg string, fields ...config.Field) {
	if os.Getenv("DEBUG") != "" {
		fmt.Printf("[DEBUG] %s", msg)
		for _, f := range fields {
			fmt.Printf(" %s=%v", f.Key, f.Value)
		}
		fmt.Println()
	}
}

func (l *SimpleLogger) Info(msg string, fields ...config.Field) {
	fmt.Printf("[INFO] %s", msg)
	for _, f := range fields {
		fmt.Printf(" %s=%v", f.Key, f.Value)
	}
	fmt.Println()
}

func (l *SimpleLogger) Warn(msg string, fields ...config.Field) {
	fmt.Printf("[WARN] %s", msg)
	for _, f := range fields {
		fmt.Printf(" %s=%v", f.Key, f.Value)
	}
	fmt.Println()
}

func (l *SimpleLogger) Error(msg string, fields ...config.Field) {
	fmt.Printf("[ERROR] %s", msg)
	for _, f := range fields {
		fmt.Printf(" %s=%v", f.Key, f.Value)
	}
	fmt.Println()
}

func init() {
	// Add flags
	initCmd.Flags().BoolP("force", "f", false, "Force overwrite existing configuration")
	getCmd.Flags().BoolP("json", "j", false, "Output in JSON format")

	// Add subcommands
	ConfigCmd.AddCommand(initCmd)
	ConfigCmd.AddCommand(validateCmd)
	ConfigCmd.AddCommand(migrateCmd)
	ConfigCmd.AddCommand(injectCmd)
	ConfigCmd.AddCommand(getCmd)
	ConfigCmd.AddCommand(setCmd)
	ConfigCmd.AddCommand(lockCmd)
	ConfigCmd.AddCommand(unlockCmd)
	ConfigCmd.AddCommand(exportCmd)
	ConfigCmd.AddCommand(importCmd)
}
