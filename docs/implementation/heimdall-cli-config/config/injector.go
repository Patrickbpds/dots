package config

import (
	"encoding/json"
	"fmt"
	"reflect"
	"strings"
	"time"
)

// InjectionStrategy defines how properties are injected
type InjectionStrategy int

const (
	// MergeDeep performs recursive merge
	MergeDeep InjectionStrategy = iota
	// MergeShallow performs top-level merge only
	MergeShallow
	// ReplaceIfMissing only replaces if property doesn't exist
	ReplaceIfMissing
	// ReplaceIfDefault only replaces if property matches default
	ReplaceIfDefault
	// NeverReplace never replaces (user-locked)
	NeverReplace
)

// PropertyInjector handles property injection
type PropertyInjector struct {
	defaults  map[string]interface{}
	rules     []InjectionRule
	preserves []string // Paths to never modify
	logger    Logger
}

// InjectionRule defines an injection rule
type InjectionRule struct {
	Path      string
	Condition func(current interface{}) bool
	Value     interface{}
	Strategy  InjectionStrategy
}

// NewPropertyInjector creates a new property injector
func NewPropertyInjector() *PropertyInjector {
	injector := &PropertyInjector{
		defaults:  make(map[string]interface{}),
		rules:     make([]InjectionRule, 0),
		preserves: make([]string, 0),
	}

	// Initialize default values
	injector.loadDefaults()

	// Initialize injection rules
	injector.initializeRules()

	return injector
}

// InjectDefaults injects default values into configuration
func (i *PropertyInjector) InjectDefaults(config *ShellConfig) error {
	// Convert config to map for easier manipulation
	configMap, err := i.structToMap(config)
	if err != nil {
		return fmt.Errorf("failed to convert config to map: %w", err)
	}

	// Load current defaults
	defaults := i.defaults

	// Identify missing properties
	missing := i.findMissingProperties(configMap, defaults)

	// Check user locks
	locked := i.getUserLocks(config)

	// Apply injection rules
	for path, value := range missing {
		if i.isUserLocked(path, locked) {
			if i.logger != nil {
				i.logger.Debug("Skipping user-locked property",
					Field{"path", path})
			}
			continue
		}

		rule := i.findRule(path)
		if rule != nil && rule.Condition != nil {
			currentValue := i.getValueByPath(configMap, path)
			if !rule.Condition(currentValue) {
				continue
			}
		}

		strategy := ReplaceIfMissing
		if rule != nil {
			strategy = rule.Strategy
		}

		if err := i.injectProperty(configMap, path, value, strategy); err != nil {
			if i.logger != nil {
				i.logger.Warn("Failed to inject property",
					Field{"path", path},
					Field{"error", err.Error()})
			}
		}
	}

	// Convert map back to struct
	if err := i.mapToStruct(configMap, config); err != nil {
		return fmt.Errorf("failed to convert map to config: %w", err)
	}

	// Update metadata
	i.updateMetadata(config)

	return nil
}

// InjectProperty injects a single property
func (i *PropertyInjector) InjectProperty(config *ShellConfig, path string, value interface{}) error {
	configMap, err := i.structToMap(config)
	if err != nil {
		return fmt.Errorf("failed to convert config to map: %w", err)
	}

	if err := i.injectProperty(configMap, path, value, ReplaceIfMissing); err != nil {
		return err
	}

	if err := i.mapToStruct(configMap, config); err != nil {
		return fmt.Errorf("failed to convert map to config: %w", err)
	}

	return nil
}

// SetUserLock sets a user lock on a property path
func (i *PropertyInjector) SetUserLock(config *ShellConfig, path string) {
	if !contains(config.Metadata.UserLocked, path) {
		config.Metadata.UserLocked = append(config.Metadata.UserLocked, path)
	}
}

// RemoveUserLock removes a user lock from a property path
func (i *PropertyInjector) RemoveUserLock(config *ShellConfig, path string) {
	filtered := make([]string, 0)
	for _, p := range config.Metadata.UserLocked {
		if p != path {
			filtered = append(filtered, p)
		}
	}
	config.Metadata.UserLocked = filtered
}

// loadDefaults loads default configuration values
func (i *PropertyInjector) loadDefaults() {
	i.defaults = map[string]interface{}{
		"version": CurrentSchemaVersion,
		"metadata": map[string]interface{}{
			"profile":   "default",
			"managedBy": "heimdall-cli",
		},
		"system": map[string]interface{}{
			"shell":              "bash",
			"terminal":           "kitty",
			"fileManager":        "nemo",
			"editor":             "nvim",
			"browser":            "firefox",
			"polkitAgent":        "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
			"screenshotTool":     "grim",
			"colorPicker":        "hyprpicker",
			"clipboardTool":      "wl-clipboard",
			"launcher":           "fuzzel",
			"powerMenu":          "wlogout",
			"lockScreen":         "hyprlock",
			"notificationDaemon": "dunst",
			"audioControl":       "pavucontrol",
			"networkManager":     "nm-applet",
			"bluetoothManager":   "blueman-applet",
			"displayManager":     "wdisplays",
			"themeManager":       "nwg-look",
			"iconTheme":          "Papirus-Dark",
			"cursorTheme":        "Bibata-Modern-Classic",
			"font": map[string]interface{}{
				"family": "JetBrainsMono Nerd Font",
				"size":   11,
				"weight": "Regular",
			},
		},
		"appearance": map[string]interface{}{
			"theme":          "dark",
			"colorScheme":    "catppuccin-mocha",
			"accentColor":    "#89b4fa",
			"transparency":   0.8,
			"blurRadius":     10,
			"borderRadius":   10,
			"borderWidth":    2,
			"shadows":        true,
			"animations":     true,
			"animationSpeed": "normal",
			"colors": map[string]interface{}{
				"background": "#1e1e2e",
				"foreground": "#cdd6f4",
				"primary":    "#89b4fa",
				"secondary":  "#f5c2e7",
				"success":    "#a6e3a1",
				"warning":    "#f9e2af",
				"error":      "#f38ba8",
				"info":       "#89dceb",
				"surface":    "#313244",
				"border":     "#45475a",
			},
		},
		"bar": map[string]interface{}{
			"position": "top",
			"height":   30,
			"width":    "100%",
			"margin": map[string]interface{}{
				"top":    5,
				"right":  5,
				"bottom": 0,
				"left":   5,
			},
			"padding": map[string]interface{}{
				"top":    5,
				"right":  10,
				"bottom": 5,
				"left":   10,
			},
			"spacing":       10,
			"transparent":   true,
			"blur":          true,
			"shadow":        true,
			"rounded":       true,
			"border":        true,
			"autoHide":      false,
			"layer":         "top",
			"exclusiveZone": true,
		},
		"modules": map[string]interface{}{
			"enabled": []string{
				"workspaces",
				"taskbar",
				"systray",
				"clock",
				"battery",
				"network",
				"audio",
				"bluetooth",
			},
			"disabled": []string{},
			"order": []string{
				"workspaces",
				"taskbar",
				"systray",
				"clock",
				"battery",
				"network",
				"audio",
				"bluetooth",
			},
			"settings": map[string]interface{}{},
		},
		"services": map[string]interface{}{
			"notifications": map[string]interface{}{
				"enabled":          true,
				"position":         "top-right",
				"timeout":          5000,
				"maxVisible":       5,
				"historySize":      50,
				"doNotDisturb":     false,
				"showOnLockScreen": false,
			},
			"audio": map[string]interface{}{
				"defaultSink":   "",
				"defaultSource": "",
				"volume":        50,
				"muted":         false,
				"stepSize":      5,
				"maxVolume":     100,
				"showOSD":       true,
			},
			"network": map[string]interface{}{
				"interface":     "",
				"showSpeed":     true,
				"showIPAddress": false,
				"autoConnect":   true,
			},
			"bluetooth": map[string]interface{}{
				"enabled":        true,
				"discoverable":   false,
				"autoConnect":    true,
				"trustedDevices": []string{},
			},
			"power": map[string]interface{}{
				"batteryLowThreshold":      20,
				"batteryCriticalThreshold": 10,
				"acAction":                 "performance",
				"batteryAction":            "balanced",
				"lidCloseAction":           "suspend",
				"idleTimeout":              600,
				"suspendTimeout":           1800,
				"hibernateTimeout":         3600,
			},
			"display": map[string]interface{}{
				"brightness":     100,
				"nightLight":     false,
				"nightLightTemp": 4500,
				"autoBrightness": false,
				"dpms":           true,
				"dpmsTimeout":    600,
				"resolution":     "auto",
				"refreshRate":    60,
				"scale":          1.0,
			},
		},
		"commands": map[string]interface{}{
			"custom": map[string]interface{}{},
		},
		"wallpaper": map[string]interface{}{
			"mode":         "static",
			"path":         "",
			"directory":    "~/Pictures/Wallpapers",
			"interval":     300,
			"random":       false,
			"blur":         false,
			"blurStrength": 10,
			"dim":          false,
			"dimStrength":  0.3,
			"fillMode":     "cover",
			"monitors":     []string{},
		},
		"hotReload": map[string]interface{}{
			"enabled": true,
			"watchPaths": []string{
				"~/.config/heimdall/shell.json",
			},
			"ignorePatterns": []string{
				"*.tmp",
				"*.swp",
				"*.bak",
			},
			"debounce":   100,
			"maxRetries": 3,
			"retryDelay": 1000,
		},
	}
}

// initializeRules initializes injection rules
func (i *PropertyInjector) initializeRules() {
	// Add rules for critical properties
	i.rules = append(i.rules, InjectionRule{
		Path: "version",
		Condition: func(current interface{}) bool {
			return current == nil || current == ""
		},
		Value:    CurrentSchemaVersion,
		Strategy: ReplaceIfMissing,
	})

	i.rules = append(i.rules, InjectionRule{
		Path: "metadata.managedBy",
		Condition: func(current interface{}) bool {
			return current == nil || current == ""
		},
		Value:    "heimdall-cli",
		Strategy: ReplaceIfMissing,
	})

	// Add rules for system defaults
	i.rules = append(i.rules, InjectionRule{
		Path: "system.shell",
		Condition: func(current interface{}) bool {
			return current == nil || current == ""
		},
		Value:    "bash",
		Strategy: ReplaceIfMissing,
	})

	i.rules = append(i.rules, InjectionRule{
		Path: "system.terminal",
		Condition: func(current interface{}) bool {
			return current == nil || current == ""
		},
		Value:    "kitty",
		Strategy: ReplaceIfMissing,
	})
}

// findMissingProperties finds properties that exist in defaults but not in config
func (i *PropertyInjector) findMissingProperties(config, defaults map[string]interface{}) map[string]interface{} {
	missing := make(map[string]interface{})
	i.findMissingPropertiesRecursive("", config, defaults, missing)
	return missing
}

// findMissingPropertiesRecursive recursively finds missing properties
func (i *PropertyInjector) findMissingPropertiesRecursive(prefix string, config, defaults, missing map[string]interface{}) {
	for key, defaultValue := range defaults {
		path := key
		if prefix != "" {
			path = prefix + "." + key
		}

		configValue, exists := config[key]
		if !exists {
			missing[path] = defaultValue
			continue
		}

		// Recursively check nested objects
		if defaultMap, ok := defaultValue.(map[string]interface{}); ok {
			if configMap, ok := configValue.(map[string]interface{}); ok {
				i.findMissingPropertiesRecursive(path, configMap, defaultMap, missing)
			} else {
				missing[path] = defaultValue
			}
		}
	}
}

// getUserLocks gets user-locked paths from configuration
func (i *PropertyInjector) getUserLocks(config *ShellConfig) []string {
	return config.Metadata.UserLocked
}

// isUserLocked checks if a path is user-locked
func (i *PropertyInjector) isUserLocked(path string, locked []string) bool {
	for _, lock := range locked {
		// Support wildcards
		if strings.HasSuffix(lock, "*") {
			prefix := strings.TrimSuffix(lock, "*")
			if strings.HasPrefix(path, prefix) {
				return true
			}
		} else if lock == path {
			return true
		}
	}
	return false
}

// findRule finds an injection rule for a path
func (i *PropertyInjector) findRule(path string) *InjectionRule {
	for _, rule := range i.rules {
		if rule.Path == path {
			return &rule
		}
	}
	return nil
}

// injectProperty injects a property into the configuration
func (i *PropertyInjector) injectProperty(config map[string]interface{}, path string, value interface{}, strategy InjectionStrategy) error {
	parts := strings.Split(path, ".")

	// Navigate to the parent object
	current := config
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

	// Apply injection strategy
	key := parts[len(parts)-1]

	switch strategy {
	case ReplaceIfMissing:
		if _, exists := current[key]; !exists {
			current[key] = value
		}
	case ReplaceIfDefault:
		if currentValue, exists := current[key]; exists {
			if i.isDefaultValue(path, currentValue) {
				current[key] = value
			}
		} else {
			current[key] = value
		}
	case MergeDeep:
		if currentMap, ok := current[key].(map[string]interface{}); ok {
			if valueMap, ok := value.(map[string]interface{}); ok {
				i.mergeDeep(currentMap, valueMap)
			} else {
				current[key] = value
			}
		} else {
			current[key] = value
		}
	case MergeShallow:
		if currentMap, ok := current[key].(map[string]interface{}); ok {
			if valueMap, ok := value.(map[string]interface{}); ok {
				for k, v := range valueMap {
					if _, exists := currentMap[k]; !exists {
						currentMap[k] = v
					}
				}
			} else {
				current[key] = value
			}
		} else {
			current[key] = value
		}
	case NeverReplace:
		// Do nothing
	}

	return nil
}

// mergeDeep performs deep merge of two maps
func (i *PropertyInjector) mergeDeep(dst, src map[string]interface{}) {
	for key, srcValue := range src {
		if dstValue, exists := dst[key]; exists {
			if dstMap, ok := dstValue.(map[string]interface{}); ok {
				if srcMap, ok := srcValue.(map[string]interface{}); ok {
					i.mergeDeep(dstMap, srcMap)
					continue
				}
			}
		}
		dst[key] = srcValue
	}
}

// isDefaultValue checks if a value matches the default
func (i *PropertyInjector) isDefaultValue(path string, value interface{}) bool {
	defaultValue := i.getValueByPath(i.defaults, path)
	return reflect.DeepEqual(value, defaultValue)
}

// getValueByPath gets a value from a map by path
func (i *PropertyInjector) getValueByPath(data map[string]interface{}, path string) interface{} {
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

// updateMetadata updates configuration metadata
func (i *PropertyInjector) updateMetadata(config *ShellConfig) {
	config.Metadata.LastModified = time.Now()
	if config.Metadata.ManagedBy == "" {
		config.Metadata.ManagedBy = "heimdall-cli"
	}
}

// structToMap converts a struct to a map
func (i *PropertyInjector) structToMap(v interface{}) (map[string]interface{}, error) {
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

// mapToStruct converts a map to a struct
func (i *PropertyInjector) mapToStruct(m map[string]interface{}, v interface{}) error {
	data, err := json.Marshal(m)
	if err != nil {
		return err
	}

	return json.Unmarshal(data, v)
}
