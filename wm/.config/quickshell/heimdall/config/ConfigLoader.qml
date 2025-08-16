pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Configuration loader that properly reads vim-keybinds from shell.json
Singleton {
    id: root
    
    // Configuration file path
    readonly property string configPath: `${Quickshell.env("HOME")}/.config/heimdall/shell.json`
    
    // Loaded configuration
    property var jsonConfig: null
    
    // Module configurations
    property var launcherConfig: null
    property var sessionConfig: null
    
    // Load configuration from JSON file
    function loadConfiguration() {
        try {
            // Read the JSON file
            const file = Qt.createQmlObject(`
                import Quickshell.Io
                FileView {
                    path: "${configPath}"
                }
            `, root)
            
            if (file && file.text) {
                jsonConfig = JSON.parse(file.text)
                console.log("Loaded configuration from:", configPath)
                
                // Update module configurations
                updateModuleConfigs()
                
                return true
            }
        } catch (error) {
            console.error("Failed to load configuration:", error)
        }
        
        return false
    }
    
    // Update module configurations from JSON
    function updateModuleConfigs() {
        if (!jsonConfig) return
        
        // Update launcher config
        if (jsonConfig.modules && jsonConfig.modules.launcher) {
            launcherConfig = jsonConfig.modules.launcher
            console.log("Launcher vim-keybinds:", launcherConfig.vimKeybinds)
        }
        
        // Update session config
        if (jsonConfig.modules && jsonConfig.modules.session) {
            sessionConfig = jsonConfig.modules.session
            console.log("Session vim-keybinds:", sessionConfig.vimKeybinds)
        }
    }
    
    // Get configuration value with fallback
    function getConfigValue(path, defaultValue) {
        try {
            const parts = path.split('.')
            let current = jsonConfig
            
            for (const part of parts) {
                if (current && typeof current === 'object' && part in current) {
                    current = current[part]
                } else {
                    return defaultValue
                }
            }
            
            return current !== undefined ? current : defaultValue
        } catch (error) {
            console.error(`Error getting config value for '${path}':`, error)
            return defaultValue
        }
    }
    
    // Check if vim keybinds are enabled for launcher
    function isLauncherVimEnabled() {
        return getConfigValue('modules.launcher.vimKeybinds', true)
    }
    
    // Check if vim keybinds are enabled for session
    function isSessionVimEnabled() {
        return getConfigValue('modules.session.vimKeybinds', true)
    }
    
    Component.onCompleted: {
        loadConfiguration()
    }
}