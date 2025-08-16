import Quickshell
import Quickshell.Io
import QtQuick

// Enhanced SessionConfig that reads vim-keybinds from JSON configuration
JsonObject {
    id: root
    
    // Core properties with defaults
    property bool enabled: true
    property int dragThreshold: 30
    
    // Vim keybinds - default to true, can be overridden by JSON config
    property bool vimKeybinds: true
    
    // Commands configuration
    property Commands commands: Commands {}
    
    // Size settings
    property Sizes sizes: Sizes {}
    
    // Function to update from JSON config
    function updateFromJson(jsonConfig) {
        if (!jsonConfig) return
        
        if (jsonConfig.enabled !== undefined) enabled = jsonConfig.enabled
        if (jsonConfig.vimKeybinds !== undefined) vimKeybinds = jsonConfig.vimKeybinds
        if (jsonConfig.dragThreshold !== undefined) dragThreshold = jsonConfig.dragThreshold
        
        // Update commands
        if (jsonConfig.commands) {
            commands.updateFromJson(jsonConfig.commands)
        }
        
        // Update sizes
        if (jsonConfig.sizes) {
            sizes.updateFromJson(jsonConfig.sizes)
        }
    }

    component Commands: JsonObject {
        property list<string> logout: ["hyprctl", "dispatch", "exit"]
        property list<string> shutdown: ["systemctl", "poweroff"]
        property list<string> hibernate: ["systemctl", "hibernate"]
        property list<string> reboot: ["systemctl", "reboot"]
        
        function updateFromJson(jsonConfig) {
            if (!jsonConfig) return
            
            if (jsonConfig.logout !== undefined) logout = jsonConfig.logout
            if (jsonConfig.shutdown !== undefined) shutdown = jsonConfig.shutdown
            if (jsonConfig.hibernate !== undefined) hibernate = jsonConfig.hibernate
            if (jsonConfig.reboot !== undefined) reboot = jsonConfig.reboot
        }
    }

    component Sizes: JsonObject {
        property int button: 80
        
        function updateFromJson(jsonConfig) {
            if (!jsonConfig) return
            
            if (jsonConfig.button !== undefined) button = jsonConfig.button
        }
    }
    
    Component.onCompleted: {
        console.log("SessionConfig initialized with vimKeybinds:", vimKeybinds)
    }
}