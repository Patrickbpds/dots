package config

import (
	"time"
)

// GetDefaultConfig returns a complete default configuration
func GetDefaultConfig() *ShellConfig {
	now := time.Now()

	return &ShellConfig{
		Version: CurrentSchemaVersion,
		Metadata: ConfigMetadata{
			Created:      now,
			LastModified: now,
			Profile:      "default",
			ManagedBy:    "heimdall-cli",
			UserLocked:   []string{},
		},
		System: SystemConfig{
			Shell:              "bash",
			Terminal:           "kitty",
			FileManager:        "nemo",
			Editor:             "nvim",
			Browser:            "firefox",
			PolkitAgent:        "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
			ScreenshotTool:     "grim",
			ColorPicker:        "hyprpicker",
			ClipboardTool:      "wl-clipboard",
			Launcher:           "fuzzel",
			PowerMenu:          "wlogout",
			LockScreen:         "hyprlock",
			NotificationDaemon: "dunst",
			AudioControl:       "pavucontrol",
			NetworkManager:     "nm-applet",
			BluetoothManager:   "blueman-applet",
			DisplayManager:     "wdisplays",
			ThemeManager:       "nwg-look",
			IconTheme:          "Papirus-Dark",
			CursorTheme:        "Bibata-Modern-Classic",
			Font: FontConfig{
				Family: "JetBrainsMono Nerd Font",
				Size:   11,
				Weight: "Regular",
			},
		},
		Appearance: AppearanceConfig{
			Theme:          "dark",
			ColorScheme:    "catppuccin-mocha",
			AccentColor:    "#89b4fa",
			Transparency:   0.8,
			BlurRadius:     10,
			BorderRadius:   10,
			BorderWidth:    2,
			Shadows:        true,
			Animations:     true,
			AnimationSpeed: "normal",
			Colors: ColorConfig{
				Background: "#1e1e2e",
				Foreground: "#cdd6f4",
				Primary:    "#89b4fa",
				Secondary:  "#f5c2e7",
				Success:    "#a6e3a1",
				Warning:    "#f9e2af",
				Error:      "#f38ba8",
				Info:       "#89dceb",
				Surface:    "#313244",
				Border:     "#45475a",
			},
		},
		Bar: BarConfig{
			Position: "top",
			Height:   30,
			Width:    "100%",
			Margin: MarginConfig{
				Top:    5,
				Right:  5,
				Bottom: 0,
				Left:   5,
			},
			Padding: PaddingConfig{
				Top:    5,
				Right:  10,
				Bottom: 5,
				Left:   10,
			},
			Spacing:       10,
			Background:    "#1e1e2e",
			Foreground:    "#cdd6f4",
			Transparent:   true,
			Blur:          true,
			Shadow:        true,
			Rounded:       true,
			Border:        true,
			AutoHide:      false,
			Layer:         "top",
			ExclusiveZone: true,
		},
		Modules: ModulesConfig{
			Enabled: []string{
				"workspaces",
				"taskbar",
				"systray",
				"clock",
				"battery",
				"network",
				"audio",
				"bluetooth",
			},
			Disabled: []string{},
			Order: []string{
				"workspaces",
				"taskbar",
				"systray",
				"clock",
				"battery",
				"network",
				"audio",
				"bluetooth",
			},
			Settings: make(map[string]interface{}),
		},
		Services: ServicesConfig{
			Notifications: NotificationConfig{
				Enabled:          true,
				Position:         "top-right",
				Timeout:          5000,
				MaxVisible:       5,
				HistorySize:      50,
				DoNotDisturb:     false,
				ShowOnLockScreen: false,
			},
			Audio: AudioConfig{
				DefaultSink:   "",
				DefaultSource: "",
				Volume:        50,
				Muted:         false,
				StepSize:      5,
				MaxVolume:     100,
				ShowOSD:       true,
			},
			Network: NetworkConfig{
				Interface:     "",
				ShowSpeed:     true,
				ShowIPAddress: false,
				AutoConnect:   true,
			},
			Bluetooth: BluetoothConfig{
				Enabled:        true,
				Discoverable:   false,
				AutoConnect:    true,
				TrustedDevices: []string{},
			},
			Power: PowerConfig{
				BatteryLowThreshold:      20,
				BatteryCriticalThreshold: 10,
				ACAction:                 "performance",
				BatteryAction:            "balanced",
				LidCloseAction:           "suspend",
				IdleTimeout:              600,
				SuspendTimeout:           1800,
				HibernateTimeout:         3600,
			},
			Display: DisplayConfig{
				Brightness:     100,
				NightLight:     false,
				NightLightTemp: 4500,
				AutoBrightness: false,
				DPMS:           true,
				DPMSTimeout:    600,
				Resolution:     "auto",
				RefreshRate:    60,
				Scale:          1.0,
			},
		},
		Commands: CommandsConfig{
			Custom: make(map[string]CommandDef),
		},
		Wallpaper: WallpaperConfig{
			Mode:         "static",
			Path:         "",
			Directory:    "~/Pictures/Wallpapers",
			Interval:     300,
			Random:       false,
			Blur:         false,
			BlurStrength: 10,
			Dim:          false,
			DimStrength:  0.3,
			FillMode:     "cover",
			Monitors:     []string{},
		},
		HotReload: HotReloadConfig{
			Enabled: true,
			WatchPaths: []string{
				"~/.config/heimdall/shell.json",
			},
			IgnorePatterns: []string{
				"*.tmp",
				"*.swp",
				"*.bak",
			},
			Debounce:   100,
			MaxRetries: 3,
			RetryDelay: 1000,
		},
		Extra: make(map[string]interface{}),
	}
}

// GetMinimalConfig returns a minimal valid configuration
func GetMinimalConfig() *ShellConfig {
	now := time.Now()

	return &ShellConfig{
		Version: CurrentSchemaVersion,
		Metadata: ConfigMetadata{
			Created:      now,
			LastModified: now,
			Profile:      "minimal",
			ManagedBy:    "heimdall-cli",
		},
		System: SystemConfig{
			Shell:    "bash",
			Terminal: "kitty",
			Font: FontConfig{
				Family: "monospace",
				Size:   10,
				Weight: "Regular",
			},
		},
		Appearance: AppearanceConfig{
			Theme:        "dark",
			ColorScheme:  "default",
			AccentColor:  "#0078d4",
			Transparency: 1.0,
			Colors: ColorConfig{
				Background: "#000000",
				Foreground: "#ffffff",
				Primary:    "#0078d4",
				Secondary:  "#00bcf2",
				Success:    "#107c10",
				Warning:    "#ffb900",
				Error:      "#d13438",
				Info:       "#0078d4",
				Surface:    "#1f1f1f",
				Border:     "#3f3f3f",
			},
		},
		Bar: BarConfig{
			Position:      "top",
			Height:        30,
			Width:         "100%",
			Layer:         "top",
			ExclusiveZone: true,
		},
		Modules: ModulesConfig{
			Enabled:  []string{"clock"},
			Disabled: []string{},
			Order:    []string{"clock"},
			Settings: make(map[string]interface{}),
		},
		Services: ServicesConfig{
			Notifications: NotificationConfig{
				Enabled:  true,
				Position: "top-right",
				Timeout:  5000,
			},
			Audio: AudioConfig{
				Volume:    50,
				StepSize:  5,
				MaxVolume: 100,
			},
			Network: NetworkConfig{
				AutoConnect: true,
			},
			Bluetooth: BluetoothConfig{
				Enabled:        false,
				TrustedDevices: []string{},
			},
			Power: PowerConfig{
				BatteryLowThreshold:      20,
				BatteryCriticalThreshold: 10,
			},
			Display: DisplayConfig{
				Brightness:  100,
				RefreshRate: 60,
				Scale:       1.0,
			},
		},
		Commands: CommandsConfig{
			Custom: make(map[string]CommandDef),
		},
		Wallpaper: WallpaperConfig{
			Mode:     "static",
			FillMode: "cover",
			Monitors: []string{},
		},
		HotReload: HotReloadConfig{
			Enabled:        false,
			WatchPaths:     []string{},
			IgnorePatterns: []string{},
		},
		Extra: make(map[string]interface{}),
	}
}

// GetProfileConfig returns a configuration for a specific profile
func GetProfileConfig(profile string) *ShellConfig {
	switch profile {
	case "minimal":
		return GetMinimalConfig()
	case "gaming":
		return GetGamingConfig()
	case "productivity":
		return GetProductivityConfig()
	case "development":
		return GetDevelopmentConfig()
	default:
		return GetDefaultConfig()
	}
}

// GetGamingConfig returns a gaming-optimized configuration
func GetGamingConfig() *ShellConfig {
	config := GetDefaultConfig()
	config.Metadata.Profile = "gaming"

	// Disable unnecessary visual effects
	config.Appearance.Animations = false
	config.Appearance.Shadows = false
	config.Appearance.Transparency = 1.0
	config.Appearance.BlurRadius = 0

	// Minimal bar
	config.Bar.AutoHide = true
	config.Bar.Height = 25
	config.Bar.Transparent = false
	config.Bar.Blur = false
	config.Bar.Shadow = false

	// Minimal modules
	config.Modules.Enabled = []string{
		"clock",
		"audio",
		"network",
	}
	config.Modules.Order = config.Modules.Enabled

	// Performance-oriented services
	config.Services.Power.ACAction = "performance"
	config.Services.Power.BatteryAction = "performance"
	config.Services.Display.AutoBrightness = false
	config.Services.Display.NightLight = false

	// Disable hot reload for performance
	config.HotReload.Enabled = false

	return config
}

// GetProductivityConfig returns a productivity-focused configuration
func GetProductivityConfig() *ShellConfig {
	config := GetDefaultConfig()
	config.Metadata.Profile = "productivity"

	// Clean, distraction-free appearance
	config.Appearance.ColorScheme = "nord"
	config.Appearance.Transparency = 0.95
	config.Appearance.BlurRadius = 20
	config.Appearance.AnimationSpeed = "fast"

	// Productivity modules
	config.Modules.Enabled = []string{
		"workspaces",
		"taskbar",
		"clock",
		"battery",
		"network",
		"audio",
		"notifications",
		"pomodoro",
		"todo",
	}
	config.Modules.Order = config.Modules.Enabled

	// Focus-oriented services
	config.Services.Notifications.DoNotDisturb = false
	config.Services.Notifications.MaxVisible = 3
	config.Services.Notifications.Timeout = 3000

	// Power management for long sessions
	config.Services.Power.ACAction = "balanced"
	config.Services.Power.BatteryAction = "powersave"
	config.Services.Power.IdleTimeout = 900

	// Eye comfort
	config.Services.Display.NightLight = true
	config.Services.Display.NightLightTemp = 4000

	return config
}

// GetDevelopmentConfig returns a development-focused configuration
func GetDevelopmentConfig() *ShellConfig {
	config := GetDefaultConfig()
	config.Metadata.Profile = "development"

	// Developer-friendly appearance
	config.Appearance.ColorScheme = "dracula"
	config.Appearance.Transparency = 0.9
	config.System.Terminal = "alacritty"
	config.System.Editor = "code"

	// Development modules
	config.Modules.Enabled = []string{
		"workspaces",
		"taskbar",
		"systray",
		"clock",
		"battery",
		"network",
		"audio",
		"bluetooth",
		"cpu",
		"memory",
		"disk",
		"docker",
		"git",
	}
	config.Modules.Order = config.Modules.Enabled

	// Development services
	config.Services.Notifications.HistorySize = 100
	config.Services.Display.Scale = 1.25 // Better for reading code

	// Hot reload for quick testing
	config.HotReload.Enabled = true
	config.HotReload.Debounce = 50

	// Custom development commands
	config.Commands.Custom["ide"] = CommandDef{
		Name:        "IDE",
		Command:     "code",
		Args:        []string{"."},
		Description: "Open VS Code in current directory",
		Icon:        "code",
		Shortcut:    "Super+C",
	}

	config.Commands.Custom["terminal"] = CommandDef{
		Name:        "Terminal",
		Command:     "alacritty",
		Args:        []string{},
		Description: "Open terminal",
		Icon:        "terminal",
		Shortcut:    "Super+Return",
	}

	return config
}
