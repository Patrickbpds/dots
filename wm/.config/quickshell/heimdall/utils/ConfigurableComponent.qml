import QtQuick
import Quickshell

// Mixin component for making QML components configuration-aware
// Components can inherit from this to automatically receive configuration updates
Item {
    id: root
    
    // Configuration section this component is interested in
    property string configSection: ""
    
    // Auto-refresh when configuration changes
    property bool autoRefresh: true
    
    // Custom refresh handler
    property var onConfigChanged: null
    
    // Get configuration value with automatic binding
    function configValue(path, defaultValue) {
        return Config.get(path, defaultValue)
    }
    
    // Refresh the component with new configuration
    function refresh() {
        if (onConfigChanged && typeof onConfigChanged === 'function') {
            onConfigChanged()
        } else {
            // Default refresh behavior
            refreshFromConfig()
        }
    }
    
    // Override this in derived components
    function refreshFromConfig() {
        console.log(`${root} refreshing from configuration`)
    }
    
    // Connect to configuration changes
    Connections {
        target: ConfigChangeHandler
        enabled: root.autoRefresh && root.configSection !== ""
        
        function onAppearanceRefreshed(component, value) {
            if (root.configSection === "appearance" || root.configSection === "*") {
                root.refresh()
            }
        }
        
        function onBarRefreshed(config) {
            if (root.configSection === "bar" || root.configSection === "*") {
                root.refresh()
            }
        }
        
        function onModuleRefreshed(moduleName, config) {
            if (root.configSection === `modules.${moduleName}` || 
                root.configSection === "modules" || 
                root.configSection === "*") {
                root.refresh()
            }
        }
        
        function onServicesRefreshed(config) {
            if (root.configSection === "services" || root.configSection === "*") {
                root.refresh()
            }
        }
        
        function onWallpaperRefreshed(config) {
            if (root.configSection === "wallpaper" || root.configSection === "*") {
                root.refresh()
            }
        }
        
        function onCommandsRefreshed(config) {
            if (root.configSection === "commands" || root.configSection === "*") {
                root.refresh()
            }
        }
    }
    
    Component.onCompleted: {
        if (configSection) {
            console.log(`ConfigurableComponent registered for section: ${configSection}`)
        }
    }
}