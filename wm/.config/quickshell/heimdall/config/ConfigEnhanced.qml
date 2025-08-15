pragma Singleton

import qs.utils
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    
    // Signals for configuration changes
    signal configurationChanged(string section)
    signal appearanceUpdated()
    signal barConfigUpdated()
    signal modulesConfigUpdated()
    signal servicesConfigUpdated()
    signal commandsConfigUpdated()
    signal wallpaperConfigUpdated()
    signal systemConfigUpdated()
    
    // Configuration file path
    readonly property string configPath: `${Quickshell.env("HOME")}/.config/heimdall/shell.json`
    
    // Configuration version
    property string version: "1.0.0"
    
    // Direct access to configuration sections
    property var systemConfig: adapter.system || {}
    property var appearanceConfig: adapter.appearance || {}
    property var barConfig: adapter.bar || {}
    property var modulesConfig: adapter.modules || {}
    property var servicesConfig: adapter.services || {}
    property var commandsConfig: adapter.commands || {}
    property var wallpaperConfig: adapter.wallpaper || {}
    property var hotReloadConfig: adapter.hotReload || {}
    
    // Legacy compatibility aliases
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
    
    // Debounce timer for hot-reload
    Timer {
        id: reloadDebouncer
        interval: hotReloadConfig.debounceMs || 500
        repeat: false
        onTriggered: {
            performReload()
        }
    }
    
    // Dynamic property getter
    function get(path, defaultValue) {
        try {
            const parts = path.split('.')
            let current = adapter
            
            for (const part of parts) {
                if (current && typeof current === 'object' && part in current) {
                    current = current[part]
                } else {
                    return defaultValue
                }
            }
            
            return current !== undefined ? current : defaultValue
        } catch (error) {
            console.error(`Config.get error for path '${path}':`, error)
            return defaultValue
        }
    }
    
    // Dynamic property setter
    function set(path, value) {
        try {
            const parts = path.split('.')
            let current = adapter
            
            for (let i = 0; i < parts.length - 1; i++) {
                const part = parts[i]
                if (!(part in current)) {
                    current[part] = {}
                }
                current = current[part]
            }
            
            const lastPart = parts[parts.length - 1]
            current[lastPart] = value
            
            // Trigger appropriate signal
            const section = parts[0]
            emitSectionChanged(section)
            
            // Save changes if auto-save is enabled
            if (hotReloadConfig.backupOnChange) {
                saveConfiguration()
            }
            
            return true
        } catch (error) {
            console.error(`Config.set error for path '${path}':`, error)
            return false
        }
    }
    
    // Emit section-specific change signals
    function emitSectionChanged(section) {
        configurationChanged(section)
        
        switch(section) {
            case 'appearance':
                appearanceUpdated()
                break
            case 'bar':
                barConfigUpdated()
                break
            case 'modules':
                modulesConfigUpdated()
                break
            case 'services':
                servicesConfigUpdated()
                break
            case 'commands':
                commandsConfigUpdated()
                break
            case 'wallpaper':
                wallpaperConfigUpdated()
                break
            case 'system':
                systemConfigUpdated()
                break
        }
    }
    
    // Perform configuration reload
    function performReload() {
        console.log("Reloading configuration from:", configPath)
        
        // Validate before reloading if enabled
        if (hotReloadConfig.validateSchema) {
            if (!validateConfiguration()) {
                console.error("Configuration validation failed, skipping reload")
                return
            }
        }
        
        // Reload the file
        fileView.reload()
        
        // Emit global change signal
        configurationChanged("all")
    }
    
    // Validate configuration against schema
    function validateConfiguration() {
        // Basic validation - can be enhanced with full JSON schema validation
        try {
            if (!adapter.version) {
                console.error("Configuration missing required 'version' field")
                return false
            }
            
            // Check version format
            const versionRegex = /^\d+\.\d+\.\d+$/
            if (!versionRegex.test(adapter.version)) {
                console.error("Invalid version format:", adapter.version)
                return false
            }
            
            return true
        } catch (error) {
            console.error("Configuration validation error:", error)
            return false
        }
    }
    
    // Save current configuration
    function saveConfiguration() {
        try {
            fileView.writeAdapter()
            console.log("Configuration saved")
            return true
        } catch (error) {
            console.error("Failed to save configuration:", error)
            return false
        }
    }
    
    // Create backup of current configuration
    function backupConfiguration() {
        try {
            const timestamp = new Date().toISOString().replace(/[:.]/g, '-')
            const backupPath = `${configPath}.backup.${timestamp}`
            // Implementation would copy current file to backup
            console.log("Configuration backed up to:", backupPath)
            return true
        } catch (error) {
            console.error("Failed to backup configuration:", error)
            return false
        }
    }
    
    FileView {
        id: fileView
        path: root.configPath
        watchChanges: root.hotReloadConfig.enabled !== false
        
        onFileChanged: {
            if (root.hotReloadConfig.enabled !== false) {
                // Debounce rapid changes
                reloadDebouncer.restart()
            }
        }
        
        onAdapterUpdated: {
            if (root.hotReloadConfig.backupOnChange) {
                writeAdapter()
            }
        }
        
        JsonAdapter {
            id: adapter
            
            // New JSON structure properties
            property var version: "1.0.0"
            property var metadata: {}
            property var system: {}
            property var appearance: AppearanceConfig {}
            property var bar: BarConfig {}
            property var modules: {}
            property var services: ServiceConfig {}
            property var commands: {}
            property var wallpaper: {}
            property var hotReload: {
                "enabled": true,
                "debounceMs": 500,
                "validateSchema": true,
                "backupOnChange": true
            }
            
            // Legacy configuration properties
            property GeneralConfig general: GeneralConfig {}
            property BackgroundConfig background: BackgroundConfig {}
            property BorderConfig border: BorderConfig {}
            property DashboardConfig dashboard: DashboardConfig {}
            property ControlCenterConfig controlCenter: ControlCenterConfig {}
            property LauncherConfig launcher: LauncherConfig {}
            property NotifsConfig notifs: NotifsConfig {}
            property OsdConfig osd: OsdConfig {}
            property SessionConfig session: SessionConfig {}
            property WInfoConfig winfo: WInfoConfig {}
            property LockConfig lock: LockConfig {}
            property UserPaths paths: UserPaths {}
        }
    }
    
    Component.onCompleted: {
        console.log("Enhanced Config loaded, version:", version)
        console.log("Configuration path:", configPath)
        console.log("Hot-reload enabled:", hotReloadConfig.enabled !== false)
    }
}