package config

import (
	"time"
)

// CurrentSchemaVersion defines the current configuration schema version
const CurrentSchemaVersion = "1.0.0"

// ShellConfig represents the complete shell configuration
type ShellConfig struct {
	Version    string           `json:"version"`
	Metadata   ConfigMetadata   `json:"metadata"`
	System     SystemConfig     `json:"system"`
	Appearance AppearanceConfig `json:"appearance"`
	Bar        BarConfig        `json:"bar"`
	Modules    ModulesConfig    `json:"modules"`
	Services   ServicesConfig   `json:"services"`
	Commands   CommandsConfig   `json:"commands"`
	Wallpaper  WallpaperConfig  `json:"wallpaper"`
	HotReload  HotReloadConfig  `json:"hotReload"`

	// Preserve unknown fields for forward compatibility
	Extra map[string]interface{} `json:"-"`
}

// ConfigMetadata contains metadata about the configuration
type ConfigMetadata struct {
	Created      time.Time `json:"created"`
	LastModified time.Time `json:"lastModified"`
	Profile      string    `json:"profile"`
	ManagedBy    string    `json:"managedBy,omitempty"`
	UserLocked   []string  `json:"userLocked,omitempty"`
}

// SystemConfig contains system-level settings
type SystemConfig struct {
	Shell              string     `json:"shell"`
	Terminal           string     `json:"terminal"`
	FileManager        string     `json:"fileManager"`
	Editor             string     `json:"editor"`
	Browser            string     `json:"browser"`
	PolkitAgent        string     `json:"polkitAgent"`
	ScreenshotTool     string     `json:"screenshotTool"`
	ColorPicker        string     `json:"colorPicker"`
	ClipboardTool      string     `json:"clipboardTool"`
	Launcher           string     `json:"launcher"`
	PowerMenu          string     `json:"powerMenu"`
	LockScreen         string     `json:"lockScreen"`
	NotificationDaemon string     `json:"notificationDaemon"`
	AudioControl       string     `json:"audioControl"`
	NetworkManager     string     `json:"networkManager"`
	BluetoothManager   string     `json:"bluetoothManager"`
	DisplayManager     string     `json:"displayManager"`
	ThemeManager       string     `json:"themeManager"`
	IconTheme          string     `json:"iconTheme"`
	CursorTheme        string     `json:"cursorTheme"`
	Font               FontConfig `json:"font"`
}

// FontConfig defines font settings
type FontConfig struct {
	Family string `json:"family"`
	Size   int    `json:"size"`
	Weight string `json:"weight"`
}

// AppearanceConfig contains appearance settings
type AppearanceConfig struct {
	Theme          string      `json:"theme"`
	ColorScheme    string      `json:"colorScheme"`
	AccentColor    string      `json:"accentColor"`
	Transparency   float64     `json:"transparency"`
	BlurRadius     int         `json:"blurRadius"`
	BorderRadius   int         `json:"borderRadius"`
	BorderWidth    int         `json:"borderWidth"`
	Shadows        bool        `json:"shadows"`
	Animations     bool        `json:"animations"`
	AnimationSpeed string      `json:"animationSpeed"`
	Colors         ColorConfig `json:"colors"`
}

// ColorConfig defines color settings
type ColorConfig struct {
	Background string `json:"background"`
	Foreground string `json:"foreground"`
	Primary    string `json:"primary"`
	Secondary  string `json:"secondary"`
	Success    string `json:"success"`
	Warning    string `json:"warning"`
	Error      string `json:"error"`
	Info       string `json:"info"`
	Surface    string `json:"surface"`
	Border     string `json:"border"`
}

// BarConfig contains bar/panel settings
type BarConfig struct {
	Position      string        `json:"position"`
	Height        int           `json:"height"`
	Width         string        `json:"width"`
	Margin        MarginConfig  `json:"margin"`
	Padding       PaddingConfig `json:"padding"`
	Spacing       int           `json:"spacing"`
	Background    string        `json:"background"`
	Foreground    string        `json:"foreground"`
	Transparent   bool          `json:"transparent"`
	Blur          bool          `json:"blur"`
	Shadow        bool          `json:"shadow"`
	Rounded       bool          `json:"rounded"`
	Border        bool          `json:"border"`
	AutoHide      bool          `json:"autoHide"`
	Layer         string        `json:"layer"`
	ExclusiveZone bool          `json:"exclusiveZone"`
}

// MarginConfig defines margin settings
type MarginConfig struct {
	Top    int `json:"top"`
	Right  int `json:"right"`
	Bottom int `json:"bottom"`
	Left   int `json:"left"`
}

// PaddingConfig defines padding settings
type PaddingConfig struct {
	Top    int `json:"top"`
	Right  int `json:"right"`
	Bottom int `json:"bottom"`
	Left   int `json:"left"`
}

// ModulesConfig contains module configurations
type ModulesConfig struct {
	Enabled  []string               `json:"enabled"`
	Disabled []string               `json:"disabled"`
	Order    []string               `json:"order"`
	Settings map[string]interface{} `json:"settings"`
}

// ServicesConfig contains service configurations
type ServicesConfig struct {
	Notifications NotificationConfig `json:"notifications"`
	Audio         AudioConfig        `json:"audio"`
	Network       NetworkConfig      `json:"network"`
	Bluetooth     BluetoothConfig    `json:"bluetooth"`
	Power         PowerConfig        `json:"power"`
	Display       DisplayConfig      `json:"display"`
}

// NotificationConfig defines notification settings
type NotificationConfig struct {
	Enabled          bool   `json:"enabled"`
	Position         string `json:"position"`
	Timeout          int    `json:"timeout"`
	MaxVisible       int    `json:"maxVisible"`
	HistorySize      int    `json:"historySize"`
	DoNotDisturb     bool   `json:"doNotDisturb"`
	ShowOnLockScreen bool   `json:"showOnLockScreen"`
}

// AudioConfig defines audio settings
type AudioConfig struct {
	DefaultSink   string `json:"defaultSink"`
	DefaultSource string `json:"defaultSource"`
	Volume        int    `json:"volume"`
	Muted         bool   `json:"muted"`
	StepSize      int    `json:"stepSize"`
	MaxVolume     int    `json:"maxVolume"`
	ShowOSD       bool   `json:"showOSD"`
}

// NetworkConfig defines network settings
type NetworkConfig struct {
	Interface     string `json:"interface"`
	ShowSpeed     bool   `json:"showSpeed"`
	ShowIPAddress bool   `json:"showIPAddress"`
	AutoConnect   bool   `json:"autoConnect"`
}

// BluetoothConfig defines bluetooth settings
type BluetoothConfig struct {
	Enabled        bool     `json:"enabled"`
	Discoverable   bool     `json:"discoverable"`
	AutoConnect    bool     `json:"autoConnect"`
	TrustedDevices []string `json:"trustedDevices"`
}

// PowerConfig defines power management settings
type PowerConfig struct {
	BatteryLowThreshold      int    `json:"batteryLowThreshold"`
	BatteryCriticalThreshold int    `json:"batteryCriticalThreshold"`
	ACAction                 string `json:"acAction"`
	BatteryAction            string `json:"batteryAction"`
	LidCloseAction           string `json:"lidCloseAction"`
	IdleTimeout              int    `json:"idleTimeout"`
	SuspendTimeout           int    `json:"suspendTimeout"`
	HibernateTimeout         int    `json:"hibernateTimeout"`
}

// DisplayConfig defines display settings
type DisplayConfig struct {
	Brightness     int     `json:"brightness"`
	NightLight     bool    `json:"nightLight"`
	NightLightTemp int     `json:"nightLightTemp"`
	AutoBrightness bool    `json:"autoBrightness"`
	DPMS           bool    `json:"dpms"`
	DPMSTimeout    int     `json:"dpmsTimeout"`
	Resolution     string  `json:"resolution"`
	RefreshRate    int     `json:"refreshRate"`
	Scale          float64 `json:"scale"`
}

// CommandsConfig contains custom command definitions
type CommandsConfig struct {
	Custom map[string]CommandDef `json:"custom"`
}

// CommandDef defines a custom command
type CommandDef struct {
	Name        string   `json:"name"`
	Command     string   `json:"command"`
	Args        []string `json:"args"`
	Description string   `json:"description"`
	Icon        string   `json:"icon"`
	Shortcut    string   `json:"shortcut"`
}

// WallpaperConfig contains wallpaper settings
type WallpaperConfig struct {
	Mode         string   `json:"mode"`
	Path         string   `json:"path"`
	Directory    string   `json:"directory"`
	Interval     int      `json:"interval"`
	Random       bool     `json:"random"`
	Blur         bool     `json:"blur"`
	BlurStrength int      `json:"blurStrength"`
	Dim          bool     `json:"dim"`
	DimStrength  float64  `json:"dimStrength"`
	FillMode     string   `json:"fillMode"`
	Monitors     []string `json:"monitors"`
}

// HotReloadConfig contains hot reload settings
type HotReloadConfig struct {
	Enabled        bool     `json:"enabled"`
	WatchPaths     []string `json:"watchPaths"`
	IgnorePatterns []string `json:"ignorePatterns"`
	Debounce       int      `json:"debounce"`
	MaxRetries     int      `json:"maxRetries"`
	RetryDelay     int      `json:"retryDelay"`
}
