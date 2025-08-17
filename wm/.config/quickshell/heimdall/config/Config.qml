pragma Singleton

import qs.utils
import Quickshell
import Quickshell.Io
import "../utils" as Utils

Singleton {
    id: root

    property alias appearance: adapter.appearance
    property alias general: adapter.general
    property alias background: adapter.background
    property alias bar: adapter.bar
    property alias border: adapter.border
    property alias dashboard: adapter.dashboard
    property alias controlCenter: adapter.controlCenter
    property alias launcher: adapter.launcher
    property alias notifs: adapter.notifs
    property alias osd: adapter.osd
    property alias session: adapter.session
    property alias winfo: adapter.winfo
    property alias lock: adapter.lock
    property alias services: adapter.services
    property alias paths: adapter.paths
    property alias uiComponents: adapter.uiComponents
    property alias animation: adapter.animation
    property alias servicesIntegration: adapter.servicesIntegration
    property alias behavior: adapter.behavior
    
    // Hot reload configuration
    property var hotReload: ({
        enabled: true,
        debounceMs: 500,
        validateSchema: true,
        backupOnChange: true
    })
    
    // Signals for configuration changes
    signal configurationChanged()
    signal configurationSectionChanged(string section)
    signal appearanceUpdated()
    signal barConfigUpdated()
    signal modulesConfigUpdated()
    signal servicesConfigUpdated()
    
    // Property to track if external config has been loaded
    property bool externalConfigLoaded: false
    
    // Track last successful configuration for rollback
    property var lastValidConfig: null
    
    // Configuration version and validation
    property Utils.ConfigVersionManager versionManager: Utils.ConfigVersionManager {}
    property Utils.ConfigValidator validator: Utils.ConfigValidator {}
    
    // Current configuration version
    readonly property string configVersion: versionManager.currentVersion
    
    // Validation state
    property bool configValid: true
    property var validationErrors: []
    property var validationWarnings: []
    
    // Helper function to get nested property value
    function get(path, defaultValue) {
        try {
            const parts = path.split('.')
            let current = root
            
            for (let part of parts) {
                if (current && current.hasOwnProperty(part)) {
                    current = current[part]
                } else {
                    return defaultValue
                }
            }
            
            return current !== undefined ? current : defaultValue
        } catch (error) {
            console.warn(`[Config] Failed to get ${path}:`, error.toString())
            return defaultValue
        }
    }
    
    // Function to merge external config with defaults
    function mergeConfig(external, defaults) {
        if (!external) return defaults
        
        // Deep merge external config into defaults
        for (let key in external) {
            if (defaults.hasOwnProperty(key)) {
                if (typeof external[key] === 'object' && !Array.isArray(external[key])) {
                    // Recursively merge nested objects
                    defaults[key] = mergeConfig(external[key], defaults[key])
                } else {
                    // Override primitive values
                    defaults[key] = external[key]
                }
            }
        }
        return defaults
    }
    
    // Function to apply external configuration
    function applyExternalConfig(configText) {
        try {
            if (!configText || configText.trim() === "" || configText.trim() === "{}") {
                console.log("[Config] No external configuration or empty config, using defaults")
                externalConfigLoaded = true
                return
            }
            
            let config = JSON.parse(configText)
            console.log("[Config] Parsing external configuration, version:", config.version || "unknown")
            
            // Store last valid config for rollback
            if (lastValidConfig === null && configValid) {
                lastValidConfig = JSON.stringify(config)
            }
            
            // Check if migration is needed
            if (versionManager.needsMigration(config)) {
                console.log("[Config] Configuration needs migration")
                const backup = versionManager.createBackup(config)
                config = versionManager.migrateConfiguration(config)
                
                if (!config) {
                    console.error("[Config] Migration failed, using defaults")
                    externalConfigLoaded = true
                    return
                }
                
                console.log("[Config] Migration successful to version", versionManager.currentVersion)
            }
            
            // Validate configuration
            const validationResult = validator.validateConfiguration(config, {
                required: ["version"]
            })
            
            configValid = validationResult.valid
            validationErrors = validationResult.errors
            validationWarnings = validationResult.warnings
            
            if (!validationResult.valid) {
                console.error("[Config] Configuration validation failed:")
                validationResult.errors.forEach(error => console.error("  -", error))
            }
            
            if (validationResult.warnings.length > 0) {
                console.warn("[Config] Configuration warnings:")
                validationResult.warnings.forEach(warning => console.warn("  -", warning))
            }
            
            // Apply hot reload configuration
            if (config.hotReload) {
                console.log("[Config] Applying hot reload configuration")
                for (let key in config.hotReload) {
                    if (hotReload.hasOwnProperty(key)) {
                        hotReload[key] = config.hotReload[key]
                    }
                }
            }
            
            // Apply module configurations with defaults
            if (config.modules) {
                // Launcher config
                if (config.modules.launcher && adapter.launcher) {
                    console.log("[Config] Applying launcher config")
                    for (let key in config.modules.launcher) {
                        if (adapter.launcher.hasOwnProperty(key)) {
                            adapter.launcher[key] = config.modules.launcher[key]
                            console.log("[Config]   - launcher." + key + ":", config.modules.launcher[key])
                        }
                    }
                }
                
                // Session config
                if (config.modules.session && adapter.session) {
                    console.log("[Config] Applying session config")
                    for (let key in config.modules.session) {
                        if (adapter.session.hasOwnProperty(key)) {
                            adapter.session[key] = config.modules.session[key]
                            console.log("[Config]   - session." + key + ":", config.modules.session[key])
                        }
                    }
                }
                
                // Background config
                if (config.modules.background && adapter.background) {
                    console.log("[Config] Applying background config")
                    for (let key in config.modules.background) {
                        if (adapter.background.hasOwnProperty(key)) {
                            adapter.background[key] = config.modules.background[key]
                            console.log("[Config]   - background." + key + ":", config.modules.background[key])
                        }
                    }
                }
                
                // Bar config
                if (config.modules.bar && adapter.bar) {
                    console.log("[Config] Applying bar config")
                    for (let key in config.modules.bar) {
                        if (adapter.bar.hasOwnProperty(key)) {
                            adapter.bar[key] = config.modules.bar[key]
                            console.log("[Config]   - bar." + key + ":", config.modules.bar[key])
                        }
                    }
                    barConfigUpdated()
                    configurationSectionChanged("bar")
                }
                
                // Dashboard config
                if (config.modules.dashboard && adapter.dashboard) {
                    console.log("[Config] Applying dashboard config")
                    for (let key in config.modules.dashboard) {
                        if (adapter.dashboard.hasOwnProperty(key)) {
                            adapter.dashboard[key] = config.modules.dashboard[key]
                            console.log("[Config]   - dashboard." + key + ":", config.modules.dashboard[key])
                        }
                    }
                }
                
                // Control Center config
                if (config.modules.controlCenter && adapter.controlCenter) {
                    console.log("[Config] Applying controlCenter config")
                    for (let key in config.modules.controlCenter) {
                        if (adapter.controlCenter.hasOwnProperty(key)) {
                            adapter.controlCenter[key] = config.modules.controlCenter[key]
                            console.log("[Config]   - controlCenter." + key + ":", config.modules.controlCenter[key])
                        }
                    }
                }
                
                // Add more module configurations as needed
            }
            
            // Apply appearance config
            if (config.appearance && adapter.appearance) {
                console.log("[Config] Applying appearance config")
                for (let key in config.appearance) {
                    if (adapter.appearance.hasOwnProperty(key)) {
                        adapter.appearance[key] = config.appearance[key]
                        console.log("[Config]   - appearance." + key + ":", config.appearance[key])
                    }
                }
                appearanceUpdated()
                configurationSectionChanged("appearance")
            }
            
            // Apply general config
            if (config.general && adapter.general) {
                console.log("[Config] Applying general config")
                for (let key in config.general) {
                    if (adapter.general.hasOwnProperty(key)) {
                        adapter.general[key] = config.general[key]
                        console.log("[Config]   - general." + key + ":", config.general[key])
                    }
                }
            }
            
            externalConfigLoaded = true
            root.configurationChanged()
            console.log("[Config] External configuration applied successfully")
            
        } catch (error) {
            console.error("[Config] Failed to parse external config:", error.toString())
            console.log("[Config] Using default configuration")
            externalConfigLoaded = true
        }
    }

    FileView {
        id: fileView
        path: `${Quickshell.env("HOME")}/.config/heimdall/shell.json`
        watchChanges: true
        
        onFileChanged: {
            console.log("[Config] External config file changed, reloading...")
            reload()
        }
        
        onLoaded: {
            console.log("[Config] External config file loaded successfully")
            if (typeof text === "function") {
                applyExternalConfig(text())
            } else if (typeof text === "string") {
                applyExternalConfig(text)
            } else {
                console.log("[Config] FileView text is neither function nor string, using defaults")
                externalConfigLoaded = true
            }
        }
        

        
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: adapter

            property AppearanceConfig appearance: AppearanceConfig {}
            property GeneralConfig general: GeneralConfig {}
            property BackgroundConfig background: BackgroundConfig {}
            property BarConfig bar: BarConfig {}
            property BorderConfig border: BorderConfig {}
            property DashboardConfig dashboard: DashboardConfig {}
            property ControlCenterConfig controlCenter: ControlCenterConfig {}
            property LauncherConfig launcher: LauncherConfig {}
            property NotifsConfig notifs: NotifsConfig {}
            property OsdConfig osd: OsdConfig {}
            property SessionConfig session: SessionConfig {}
            property WInfoConfig winfo: WInfoConfig {}
            property LockConfig lock: LockConfig {}
            property ServiceConfig services: ServiceConfig {}
            property UserPaths paths: UserPaths {}
            property UIComponentsConfig uiComponents: UIComponentsConfig {}
            property AnimationConfig animation: AnimationConfig {}
            property ServicesIntegrationConfig servicesIntegration: ServicesIntegrationConfig {}
            property BehaviorConfig behavior: BehaviorConfig {}
        }
    }
}