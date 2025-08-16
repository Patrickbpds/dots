package config

import (
	"fmt"
	"reflect"
	"regexp"
	"strings"
)

// Severity levels for validation errors
const (
	SeverityWarning Severity = iota
	SeverityError
	SeverityCritical
)

// Severity represents the severity of a validation error
type Severity int

// ValidationError represents a validation error
type ValidationError struct {
	Type     ErrorType
	Path     string
	Message  string
	Severity Severity
	Fix      *SuggestedFix
}

// ErrorType represents the type of validation error
type ErrorType int

const (
	ValidationErrorType ErrorType = iota
	MigrationErrorType
	InjectionErrorType
	IOErrorType
	ParseErrorType
)

// SuggestedFix provides a suggested fix for an error
type SuggestedFix struct {
	Description string
	Command     string
	AutoFix     bool
}

// SchemaValidator validates configuration against schema
type SchemaValidator struct {
	rules      []ValidationRule
	required   map[string]bool
	patterns   map[string]*regexp.Regexp
	validators map[string]FieldValidator
}

// ValidationRule defines a validation rule
type ValidationRule struct {
	Path       string
	Validator  func(value interface{}) error
	Required   bool
	Severity   Severity
	FixMessage string
}

// FieldValidator validates a specific field
type FieldValidator func(value interface{}, path string) *ValidationError

// NewSchemaValidator creates a new schema validator
func NewSchemaValidator() *SchemaValidator {
	v := &SchemaValidator{
		rules:      make([]ValidationRule, 0),
		required:   make(map[string]bool),
		patterns:   make(map[string]*regexp.Regexp),
		validators: make(map[string]FieldValidator),
	}

	// Initialize validation rules
	v.initializeRules()
	v.initializePatterns()
	v.initializeValidators()

	return v
}

// Validate validates a configuration
func (v *SchemaValidator) Validate(config *ShellConfig) []ValidationError {
	errors := make([]ValidationError, 0)

	// Check version
	if config.Version == "" {
		errors = append(errors, ValidationError{
			Type:     ValidationErrorType,
			Path:     "version",
			Message:  "Version is required",
			Severity: SeverityError,
			Fix: &SuggestedFix{
				Description: "Set version to current schema version",
				Command:     "heimdall-cli config set version " + CurrentSchemaVersion,
				AutoFix:     true,
			},
		})
	}

	// Validate metadata
	if metaErrors := v.validateMetadata(&config.Metadata); len(metaErrors) > 0 {
		errors = append(errors, metaErrors...)
	}

	// Validate system configuration
	if sysErrors := v.validateSystem(&config.System); len(sysErrors) > 0 {
		errors = append(errors, sysErrors...)
	}

	// Validate appearance
	if appErrors := v.validateAppearance(&config.Appearance); len(appErrors) > 0 {
		errors = append(errors, appErrors...)
	}

	// Validate bar configuration
	if barErrors := v.validateBar(&config.Bar); len(barErrors) > 0 {
		errors = append(errors, barErrors...)
	}

	// Validate modules
	if modErrors := v.validateModules(&config.Modules); len(modErrors) > 0 {
		errors = append(errors, modErrors...)
	}

	// Validate services
	if svcErrors := v.validateServices(&config.Services); len(svcErrors) > 0 {
		errors = append(errors, svcErrors...)
	}

	// Validate commands
	if cmdErrors := v.validateCommands(&config.Commands); len(cmdErrors) > 0 {
		errors = append(errors, cmdErrors...)
	}

	// Validate wallpaper
	if wallErrors := v.validateWallpaper(&config.Wallpaper); len(wallErrors) > 0 {
		errors = append(errors, wallErrors...)
	}

	// Validate hot reload
	if hrErrors := v.validateHotReload(&config.HotReload); len(hrErrors) > 0 {
		errors = append(errors, hrErrors...)
	}

	// Apply custom validation rules
	for _, rule := range v.rules {
		value := v.getValueByPath(config, rule.Path)
		if rule.Required && value == nil {
			errors = append(errors, ValidationError{
				Type:     ValidationErrorType,
				Path:     rule.Path,
				Message:  fmt.Sprintf("%s is required", rule.Path),
				Severity: rule.Severity,
			})
		} else if value != nil && rule.Validator != nil {
			if err := rule.Validator(value); err != nil {
				errors = append(errors, ValidationError{
					Type:     ValidationErrorType,
					Path:     rule.Path,
					Message:  err.Error(),
					Severity: rule.Severity,
					Fix: &SuggestedFix{
						Description: rule.FixMessage,
						AutoFix:     false,
					},
				})
			}
		}
	}

	return errors
}

// validateMetadata validates metadata configuration
func (v *SchemaValidator) validateMetadata(meta *ConfigMetadata) []ValidationError {
	errors := make([]ValidationError, 0)

	if meta.Profile == "" {
		errors = append(errors, ValidationError{
			Type:     ValidationErrorType,
			Path:     "metadata.profile",
			Message:  "Profile name is recommended",
			Severity: SeverityWarning,
			Fix: &SuggestedFix{
				Description: "Set a profile name",
				Command:     "heimdall-cli config set metadata.profile default",
				AutoFix:     true,
			},
		})
	}

	return errors
}

// validateSystem validates system configuration
func (v *SchemaValidator) validateSystem(sys *SystemConfig) []ValidationError {
	errors := make([]ValidationError, 0)

	// Validate shell
	if sys.Shell == "" {
		errors = append(errors, ValidationError{
			Type:     ValidationErrorType,
			Path:     "system.shell",
			Message:  "Shell is required",
			Severity: SeverityError,
		})
	}

	// Validate terminal
	if sys.Terminal == "" {
		errors = append(errors, ValidationError{
			Type:     ValidationErrorType,
			Path:     "system.terminal",
			Message:  "Terminal is required",
			Severity: SeverityError,
		})
	}

	// Validate font
	if sys.Font.Family == "" {
		errors = append(errors, ValidationError{
			Type:     ValidationErrorType,
			Path:     "system.font.family",
			Message:  "Font family is required",
			Severity: SeverityWarning,
		})
	}

	if sys.Font.Size <= 0 {
		errors = append(errors, ValidationError{
			Type:     ValidationErrorType,
			Path:     "system.font.size",
			Message:  "Font size must be positive",
			Severity: SeverityError,
		})
	}

	return errors
}

// validateAppearance validates appearance configuration
func (v *SchemaValidator) validateAppearance(app *AppearanceConfig) []ValidationError {
	errors := make([]ValidationError, 0)

	// Validate transparency
	if app.Transparency < 0 || app.Transparency > 1 {
		errors = append(errors, ValidationError{
			Type:     ValidationErrorType,
			Path:     "appearance.transparency",
			Message:  "Transparency must be between 0 and 1",
			Severity: SeverityError,
		})
	}

	// Validate blur radius
	if app.BlurRadius < 0 {
		errors = append(errors, ValidationError{
			Type:     ValidationErrorType,
			Path:     "appearance.blurRadius",
			Message:  "Blur radius must be non-negative",
			Severity: SeverityError,
		})
	}

	// Validate colors
	if colorErrors := v.validateColors(&app.Colors); len(colorErrors) > 0 {
		errors = append(errors, colorErrors...)
	}

	return errors
}

// validateColors validates color configuration
func (v *SchemaValidator) validateColors(colors *ColorConfig) []ValidationError {
	errors := make([]ValidationError, 0)

	colorFields := map[string]string{
		"background": colors.Background,
		"foreground": colors.Foreground,
		"primary":    colors.Primary,
		"secondary":  colors.Secondary,
		"success":    colors.Success,
		"warning":    colors.Warning,
		"error":      colors.Error,
		"info":       colors.Info,
		"surface":    colors.Surface,
		"border":     colors.Border,
	}

	hexPattern := v.patterns["hex_color"]
	for field, value := range colorFields {
		if value != "" && !hexPattern.MatchString(value) {
			errors = append(errors, ValidationError{
				Type:     ValidationErrorType,
				Path:     fmt.Sprintf("appearance.colors.%s", field),
				Message:  fmt.Sprintf("Invalid color format: %s", value),
				Severity: SeverityError,
				Fix: &SuggestedFix{
					Description: "Use hex color format (#RRGGBB or #RRGGBBAA)",
					AutoFix:     false,
				},
			})
		}
	}

	return errors
}

// validateBar validates bar configuration
func (v *SchemaValidator) validateBar(bar *BarConfig) []ValidationError {
	errors := make([]ValidationError, 0)

	// Validate position
	validPositions := []string{"top", "bottom", "left", "right"}
	if !contains(validPositions, bar.Position) {
		errors = append(errors, ValidationError{
			Type:     ValidationErrorType,
			Path:     "bar.position",
			Message:  fmt.Sprintf("Invalid bar position: %s", bar.Position),
			Severity: SeverityError,
			Fix: &SuggestedFix{
				Description: fmt.Sprintf("Use one of: %s", strings.Join(validPositions, ", ")),
				AutoFix:     false,
			},
		})
	}

	// Validate height
	if bar.Height <= 0 {
		errors = append(errors, ValidationError{
			Type:     ValidationErrorType,
			Path:     "bar.height",
			Message:  "Bar height must be positive",
			Severity: SeverityError,
		})
	}

	// Validate layer
	validLayers := []string{"background", "bottom", "top", "overlay"}
	if bar.Layer != "" && !contains(validLayers, bar.Layer) {
		errors = append(errors, ValidationError{
			Type:     ValidationErrorType,
			Path:     "bar.layer",
			Message:  fmt.Sprintf("Invalid layer: %s", bar.Layer),
			Severity: SeverityWarning,
		})
	}

	return errors
}

// validateModules validates modules configuration
func (v *SchemaValidator) validateModules(modules *ModulesConfig) []ValidationError {
	errors := make([]ValidationError, 0)

	// Check for duplicate modules
	seen := make(map[string]bool)
	for _, module := range modules.Enabled {
		if seen[module] {
			errors = append(errors, ValidationError{
				Type:     ValidationErrorType,
				Path:     "modules.enabled",
				Message:  fmt.Sprintf("Duplicate module: %s", module),
				Severity: SeverityWarning,
			})
		}
		seen[module] = true
	}

	// Check for conflicts between enabled and disabled
	for _, module := range modules.Disabled {
		if seen[module] {
			errors = append(errors, ValidationError{
				Type:     ValidationErrorType,
				Path:     "modules",
				Message:  fmt.Sprintf("Module %s is both enabled and disabled", module),
				Severity: SeverityError,
			})
		}
	}

	return errors
}

// validateServices validates services configuration
func (v *SchemaValidator) validateServices(services *ServicesConfig) []ValidationError {
	errors := make([]ValidationError, 0)

	// Validate notification settings
	if services.Notifications.Timeout < 0 {
		errors = append(errors, ValidationError{
			Type:     ValidationErrorType,
			Path:     "services.notifications.timeout",
			Message:  "Notification timeout must be non-negative",
			Severity: SeverityError,
		})
	}

	// Validate audio settings
	if services.Audio.Volume < 0 || services.Audio.Volume > services.Audio.MaxVolume {
		errors = append(errors, ValidationError{
			Type:     ValidationErrorType,
			Path:     "services.audio.volume",
			Message:  fmt.Sprintf("Volume must be between 0 and %d", services.Audio.MaxVolume),
			Severity: SeverityError,
		})
	}

	// Validate power settings
	if services.Power.BatteryLowThreshold <= services.Power.BatteryCriticalThreshold {
		errors = append(errors, ValidationError{
			Type:     ValidationErrorType,
			Path:     "services.power",
			Message:  "Battery low threshold must be higher than critical threshold",
			Severity: SeverityWarning,
		})
	}

	return errors
}

// validateCommands validates commands configuration
func (v *SchemaValidator) validateCommands(commands *CommandsConfig) []ValidationError {
	errors := make([]ValidationError, 0)

	for name, cmd := range commands.Custom {
		if cmd.Command == "" {
			errors = append(errors, ValidationError{
				Type:     ValidationErrorType,
				Path:     fmt.Sprintf("commands.custom.%s.command", name),
				Message:  "Command cannot be empty",
				Severity: SeverityError,
			})
		}
	}

	return errors
}

// validateWallpaper validates wallpaper configuration
func (v *SchemaValidator) validateWallpaper(wallpaper *WallpaperConfig) []ValidationError {
	errors := make([]ValidationError, 0)

	// Validate mode
	validModes := []string{"static", "slideshow", "video", "color"}
	if !contains(validModes, wallpaper.Mode) {
		errors = append(errors, ValidationError{
			Type:     ValidationErrorType,
			Path:     "wallpaper.mode",
			Message:  fmt.Sprintf("Invalid wallpaper mode: %s", wallpaper.Mode),
			Severity: SeverityError,
		})
	}

	// Validate fill mode
	validFillModes := []string{"fill", "contain", "cover", "scale-down", "none"}
	if wallpaper.FillMode != "" && !contains(validFillModes, wallpaper.FillMode) {
		errors = append(errors, ValidationError{
			Type:     ValidationErrorType,
			Path:     "wallpaper.fillMode",
			Message:  fmt.Sprintf("Invalid fill mode: %s", wallpaper.FillMode),
			Severity: SeverityWarning,
		})
	}

	// Validate interval for slideshow mode
	if wallpaper.Mode == "slideshow" && wallpaper.Interval <= 0 {
		errors = append(errors, ValidationError{
			Type:     ValidationErrorType,
			Path:     "wallpaper.interval",
			Message:  "Slideshow interval must be positive",
			Severity: SeverityError,
		})
	}

	return errors
}

// validateHotReload validates hot reload configuration
func (v *SchemaValidator) validateHotReload(hotReload *HotReloadConfig) []ValidationError {
	errors := make([]ValidationError, 0)

	if hotReload.Debounce < 0 {
		errors = append(errors, ValidationError{
			Type:     ValidationErrorType,
			Path:     "hotReload.debounce",
			Message:  "Debounce time must be non-negative",
			Severity: SeverityError,
		})
	}

	if hotReload.MaxRetries < 0 {
		errors = append(errors, ValidationError{
			Type:     ValidationErrorType,
			Path:     "hotReload.maxRetries",
			Message:  "Max retries must be non-negative",
			Severity: SeverityError,
		})
	}

	return errors
}

// initializeRules initializes validation rules
func (v *SchemaValidator) initializeRules() {
	// Add custom validation rules
	v.rules = append(v.rules, ValidationRule{
		Path:     "version",
		Required: true,
		Severity: SeverityError,
		Validator: func(value interface{}) error {
			version, ok := value.(string)
			if !ok || version == "" {
				return fmt.Errorf("version must be a non-empty string")
			}
			return nil
		},
	})

	v.rules = append(v.rules, ValidationRule{
		Path:     "system.shell",
		Required: true,
		Severity: SeverityError,
		Validator: func(value interface{}) error {
			shell, ok := value.(string)
			if !ok || shell == "" {
				return fmt.Errorf("shell must be specified")
			}
			return nil
		},
	})
}

// initializePatterns initializes regex patterns
func (v *SchemaValidator) initializePatterns() {
	v.patterns["hex_color"] = regexp.MustCompile(`^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$`)
	v.patterns["version"] = regexp.MustCompile(`^\d+\.\d+\.\d+(-[a-zA-Z0-9]+)?$`)
	v.patterns["path"] = regexp.MustCompile(`^[a-zA-Z0-9/_\-\.~]+$`)
}

// initializeValidators initializes field validators
func (v *SchemaValidator) initializeValidators() {
	// Add field-specific validators
	v.validators["color"] = func(value interface{}, path string) *ValidationError {
		color, ok := value.(string)
		if !ok {
			return &ValidationError{
				Type:     ValidationErrorType,
				Path:     path,
				Message:  "Value must be a string",
				Severity: SeverityError,
			}
		}

		if !v.patterns["hex_color"].MatchString(color) {
			return &ValidationError{
				Type:     ValidationErrorType,
				Path:     path,
				Message:  fmt.Sprintf("Invalid color format: %s", color),
				Severity: SeverityError,
			}
		}

		return nil
	}
}

// getValueByPath retrieves a value from the config by path
func (v *SchemaValidator) getValueByPath(config *ShellConfig, path string) interface{} {
	parts := strings.Split(path, ".")
	value := reflect.ValueOf(*config)

	for _, part := range parts {
		if value.Kind() == reflect.Ptr {
			value = value.Elem()
		}

		if value.Kind() != reflect.Struct {
			return nil
		}

		// Convert path part to field name (e.g., "system.shell" -> "System", "Shell")
		fieldName := strings.Title(part)
		field := value.FieldByName(fieldName)
		if !field.IsValid() {
			return nil
		}

		value = field
	}

	if !value.IsValid() {
		return nil
	}

	return value.Interface()
}

// contains checks if a slice contains a value
func contains(slice []string, value string) bool {
	for _, v := range slice {
		if v == value {
			return true
		}
	}
	return false
}
