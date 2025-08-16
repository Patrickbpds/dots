pragma Singleton

import qs.utils
import Quickshell
import Quickshell.Io

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
    
    // Signal for configuration changes
    signal configurationChanged()
    
    // Property to track if external config has been loaded
    property bool externalConfigLoaded: false
    
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
            
            const config = JSON.parse(configText)
            console.log("[Config] Parsing external configuration, version:", config.version || "unknown")
            
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
        }
    }
}