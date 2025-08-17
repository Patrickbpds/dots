import QtQuick

QtObject {
    id: root
    
    // API Configuration
    property QtObject api: QtObject {
        property string baseUrl: "http://localhost:8080"
        property int timeout: 30000  // Request timeout in ms
        property int retryCount: 3
        property int retryDelay: 1000  // Delay between retries in ms
        property bool enableCache: true
        property int cacheExpiry: 300000  // Cache expiry in ms (5 minutes)
        
        // Authentication
        property QtObject auth: QtObject {
            property string type: "none"  // "none", "bearer", "api-key", "basic"
            property string token: ""
            property string apiKey: ""
            property string username: ""
            property string password: ""
        }
    }
    
    // Weather service configuration
    property QtObject weather: QtObject {
        property bool enabled: true
        property string provider: "openweathermap"  // "openweathermap", "weatherapi", "meteo"
        property string apiKey: ""
        property string location: "auto"  // "auto" or specific location
        property string units: "metric"  // "metric", "imperial"
        property int updateInterval: 1800000  // 30 minutes
        property int retryInterval: 60000  // 1 minute on error
        property bool showAlerts: true
        property int maxForecastDays: 5
    }
    
    // Network monitoring configuration
    property QtObject network: QtObject {
        property bool enabled: true
        property int pingInterval: 5000  // Network check interval in ms
        property string pingTarget: "8.8.8.8"
        property int pingTimeout: 3000
        property bool monitorBandwidth: true
        property int bandwidthUpdateInterval: 1000
        property bool showIPAddress: true
        property bool showHostname: true
    }
    
    // System monitoring configuration
    property QtObject systemMonitor: QtObject {
        property bool enabled: true
        property int updateInterval: 1000  // Update interval in ms
        property bool monitorCPU: true
        property bool monitorMemory: true
        property bool monitorDisk: true
        property bool monitorGPU: false
        property bool monitorTemperature: true
        property bool monitorBattery: true
        property int historySize: 60  // Number of data points to keep
        property real cpuWarningThreshold: 80  // Percentage
        property real memoryWarningThreshold: 90  // Percentage
        property real temperatureWarningThreshold: 80  // Celsius
    }
    
    // Media player integration
    property QtObject mediaPlayer: QtObject {
        property bool enabled: true
        property string preferredPlayer: "auto"  // "auto", "spotify", "mpd", "vlc", etc.
        property bool showAlbumArt: true
        property int albumArtSize: 64
        property bool showProgress: true
        property int updateInterval: 500
        property bool enableControls: true
        property bool enableGestures: true
        property int seekStep: 5000  // Seek step in ms
    }
    
    // Notification service configuration
    property QtObject notifications: QtObject {
        property bool enabled: true
        property int maxNotifications: 10
        property int defaultTimeout: 5000  // Default notification timeout in ms
        property bool groupByApp: true
        property bool showActions: true
        property bool playSound: true
        property string soundFile: ""
        property bool showOnLockScreen: false
        property string position: "top-right"  // "top-left", "top-right", "bottom-left", "bottom-right"
        property int spacing: 8
        property int width: 350
        property bool persistentHistory: true
        property int historySize: 50
    }
    
    // Bluetooth service configuration
    property QtObject bluetooth: QtObject {
        property bool enabled: true
        property int scanInterval: 10000  // Device scan interval in ms
        property int scanDuration: 5000  // Scan duration in ms
        property bool autoConnect: true
        property var trustedDevices: []  // List of MAC addresses
        property bool showBatteryLevel: true
        property bool notifyOnConnect: true
        property bool notifyOnDisconnect: true
    }
    
    // Audio service configuration
    property QtObject audio: QtObject {
        property bool enabled: true
        property string defaultSink: "@DEFAULT_SINK@"
        property string defaultSource: "@DEFAULT_SOURCE@"
        property int volumeStep: 5  // Volume change step percentage
        property bool showVolumeOSD: true
        property int osdTimeout: 1500
        property bool muteOnLock: false
        property bool pauseOnLock: true
        property int updateInterval: 100
    }
    
    // Calendar service configuration
    property QtObject calendar: QtObject {
        property bool enabled: true
        property string provider: "local"  // "local", "google", "outlook", "caldav"
        property string calendarUrl: ""
        property string username: ""
        property string password: ""
        property int syncInterval: 300000  // 5 minutes
        property int eventLookahead: 7  // Days to look ahead
        property bool showAllDayEvents: true
        property bool showDeclinedEvents: false
        property bool notifyUpcoming: true
        property int notifyMinutesBefore: 15
    }
    
    // Email service configuration
    property QtObject email: QtObject {
        property bool enabled: false
        property string provider: "imap"  // "imap", "gmail", "outlook"
        property string server: ""
        property int port: 993
        property bool ssl: true
        property string username: ""
        property string password: ""
        property int checkInterval: 300000  // 5 minutes
        property bool notifyNewMail: true
        property int maxPreviewLength: 100
        property var folders: ["INBOX"]
    }
    
    // File watcher configuration
    property QtObject fileWatcher: QtObject {
        property bool enabled: true
        property var watchPaths: []  // Paths to watch
        property bool recursive: true
        property bool notifyOnChange: true
        property int debounceDelay: 500  // Debounce file change events
        property var ignorePatterns: ["*.tmp", "*.swp", ".git/*"]
    }
    
    // Command execution configuration
    property QtObject commands: QtObject {
        property bool enabled: true
        property int defaultTimeout: 10000  // Default command timeout in ms
        property string shell: "/bin/sh"
        property bool logOutput: false
        property bool notifyOnError: true
        property var environment: {}  // Additional environment variables
    }
    
    // WebSocket configuration
    property QtObject websocket: QtObject {
        property bool enabled: false
        property string url: "ws://localhost:8080/ws"
        property bool autoReconnect: true
        property int reconnectInterval: 5000
        property int pingInterval: 30000
        property int pingTimeout: 5000
        property int maxReconnectAttempts: 10
    }
    
    // Database configuration
    property QtObject database: QtObject {
        property bool enabled: true
        property string type: "sqlite"  // "sqlite", "mysql", "postgresql"
        property string path: "~/.config/quickshell/heimdall/data.db"
        property string host: "localhost"
        property int port: 3306
        property string name: "heimdall"
        property string username: ""
        property string password: ""
        property int connectionPoolSize: 5
        property int queryTimeout: 5000
    }
    
    // Backup service configuration
    property QtObject backup: QtObject {
        property bool enabled: true
        property bool autoBackup: true
        property int backupInterval: 86400000  // 24 hours
        property string backupPath: "~/.config/quickshell/heimdall/backups"
        property int maxBackups: 10
        property bool compressBackups: true
        property bool encryptBackups: false
        property string encryptionKey: ""
    }
    
    // Helper functions
    function getServiceConfig(serviceName) {
        if (root.hasOwnProperty(serviceName)) {
            return root[serviceName]
        }
        return null
    }
    
    function isServiceEnabled(serviceName) {
        const config = getServiceConfig(serviceName)
        return config && config.enabled
    }
}