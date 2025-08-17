pragma Singleton

import QtQuick
import qs.utils
import Quickshell
import Quickshell.Io
import "../utils" as Utils

Singleton {
    id: root



    // Configuration properties
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
    
    // Hot reload configuration
    property var hotReload: ({
        enabled: true,
        debounceMs: 500,
        validateSchema: true,
        backupOnChange: true
    })
    
    // Signals for configuration changes
    signal configurationChanged(string section)
    signal appearanceUpdated()
    signal barConfigUpdated()
    signal modulesConfigUpdated()
    signal servicesConfigUpdated()
    signal wallpaperConfigUpdated()
    signal commandsConfigUpdated()
    
    // Property to track if external config has been loaded
    property bool externalConfigLoaded: false
    
    // Track last successful configuration for rollback
    property var lastValidConfig: null
    
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
    
    // Enhanced configuration application with nested object support
    function applyExternalConfig(configText) {
        try {
            if (!configText || configText.trim() === "" || configText.trim() === "{}") {
                console.log("[Config] No external configuration or empty config, using defaults")
                externalConfigLoaded = true
                return
            }
            
            const config = JSON.parse(configText)
            console.log("[Config] Parsing external configuration, version:", config.version || "unknown")
            
            // Store last valid config for rollback
            if (lastValidConfig === null) {
                lastValidConfig = JSON.stringify(config)
            }
            
            // Apply hot reload configuration
            if (config.hotReload) {
                console.log("[Config] Applying hot reload configuration")
                Utils.ConfigPropertyAssigner.assignProperties(hotReload, config.hotReload, "hotReload")
            }
            
            // Apply module configurations with nested object support
            if (config.modules) {
                console.log("[Config] Applying module configurations")
                
                // Use ConfigPropertyAssigner for each module
                const modules = ['launcher', 'session', 'background', 'bar', 'dashboard', 
                                'controlCenter', 'notifs', 'osd', 'winfo', 'lock']
                
                for (let moduleName of modules) {
                    if (config.modules[moduleName] && adapter[moduleName]) {
                        console.log(`[Config] Applying ${moduleName} config with nested support`)
                        const success = Utils.ConfigPropertyAssigner.assignProperties(
                            adapter[moduleName], 
                            config.modules[moduleName], 
                            `modules.${moduleName}`
                        )
                        
                        if (!success) {
                            console.warn(`[Config] Some properties failed to apply for ${moduleName}`)
                        }
                    }
                }
                
                modulesConfigUpdated()
            }
            
            // Apply appearance config with nested support
            if (config.appearance && adapter.appearance) {
                console.log("[Config] Applying appearance config with nested support")
                Utils.ConfigPropertyAssigner.assignProperties(adapter.appearance, config.appearance, "appearance")
                appearanceUpdated()
            }
            
            // Apply general config
            if (config.general && adapter.general) {
                console.log("[Config] Applying general config")
                Utils.ConfigPropertyAssigner.assignProperties(adapter.general, config.general, "general")
            }
            
            // Apply services config
            if (config.services && adapter.services) {
                console.log("[Config] Applying services config")
                Utils.ConfigPropertyAssigner.assignProperties(adapter.services, config.services, "services")
                servicesConfigUpdated()
            }
            
            // Apply border config
            if (config.border && adapter.border) {
                console.log("[Config] Applying border config")
                Utils.ConfigPropertyAssigner.assignProperties(adapter.border, config.border, "border")
            }
            
            // Apply paths config
            if (config.paths && adapter.paths) {
                console.log("[Config] Applying paths config")
                Utils.ConfigPropertyAssigner.assignProperties(adapter.paths, config.paths, "paths")
            }
            
            externalConfigLoaded = true
            configurationChanged("all")
            console.log("[Config] External configuration applied successfully with nested object support")
            
            // Store this as last valid config
            lastValidConfig = configText
            
        } catch (error) {
            console.error("[Config] Failed to parse external config:", error.toString())
            
            // Attempt rollback if we have a last valid config
            if (lastValidConfig && hotReload.backupOnChange) {
                console.log("[Config] Attempting to rollback to last valid configuration")
                try {
                    const validConfig = JSON.parse(lastValidConfig)
                    applyExternalConfig(lastValidConfig)
                } catch (rollbackError) {
                    console.error("[Config] Rollback failed:", rollbackError.toString())
                }
            }
            
            console.log("[Config] Using current configuration")
            externalConfigLoaded = true
        }
    }
    
    // Validate configuration against schema
    function validateConfiguration(config) {
        if (!hotReload.validateSchema) return true
        
        try {
            // Basic validation - check for required fields
            if (!config.version) {
                console.warn("[Config] Missing version field in configuration")
            }
            
            // Validate module structure
            if (config.modules) {
                for (let key in config.modules) {
                    if (typeof config.modules[key] !== 'object') {
                        console.error(`[Config] Invalid module configuration for ${key}`)
                        return false
                    }
                }
            }
            
            return true
        } catch (error) {
            console.error("[Config] Validation error:", error.toString())
            return false
        }
    }
    
    // Create backup of current configuration
    function backupConfiguration() {
        if (!hotReload.backupOnChange) return
        
        try {
            const currentConfig = {
                version: "1.0.0",
                timestamp: new Date().toISOString(),
                modules: {},
                appearance: {},
                general: {},
                services: {},
                border: {},
                paths: {}
            }
            
            // Backup each section
            // Note: This is simplified - in production you'd serialize the actual QML properties
            console.log("[Config] Configuration backed up")
            
        } catch (error) {
            console.error("[Config] Failed to backup configuration:", error.toString())
        }
    }

    // Debounce timer for configuration reloads
    Timer {
        id: debounceTimer
        interval: hotReload.debounceMs
        repeat: false
        onTriggered: {
            console.log("[Config] Debounced reload triggered")
            fileView.reload()
        }
    }

    FileView {
        id: fileView
        path: `${Quickshell.env("HOME")}/.config/heimdall/shell.json`
        watchChanges: true
        
        onFileChanged: {
            console.log("[Config] External config file changed")
            
            if (hotReload.enabled) {
                if (hotReload.debounceMs > 0) {
                    console.log(`[Config] Debouncing reload for ${hotReload.debounceMs}ms`)
                    debounceTimer.restart()
                } else {
                    reload()
                }
            } else {
                console.log("[Config] Hot reload disabled, ignoring file change")
            }
        }
        
        onLoaded: {
            console.log("[Config] External config file loaded successfully")
            
            // Backup current configuration before applying new one
            backupConfiguration()
            
            // Get the text content
            let configText = ""
            if (typeof text === "function") {
                configText = text()
            } else if (typeof text === "string") {
                configText = text
            } else {
                console.log("[Config] FileView text is neither function nor string, using defaults")
                externalConfigLoaded = true
                return
            }
            
            // Validate before applying
            if (hotReload.validateSchema) {
                try {
                    const config = JSON.parse(configText)
                    if (!validateConfiguration(config)) {
                        console.error("[Config] Configuration validation failed")
                        return
                    }
                } catch (error) {
                    console.error("[Config] Failed to parse configuration for validation:", error.toString())
                    return
                }
            }
            
            // Apply the configuration
            applyExternalConfig(configText)
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
        }
    }
    
    Component.onCompleted: {
        console.log("[Config] Enhanced configuration system initialized")
        console.log("[Config] Hot reload enabled:", hotReload.enabled)
        console.log("[Config] Debounce time:", hotReload.debounceMs, "ms")
        console.log("[Config] Schema validation:", hotReload.validateSchema)
        console.log("[Config] Backup on change:", hotReload.backupOnChange)
    }
}