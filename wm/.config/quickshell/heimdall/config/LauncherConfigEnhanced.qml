import Quickshell.Io
import QtQuick

// Enhanced LauncherConfig that reads vim-keybinds from JSON configuration
JsonObject {
    id: root
    
    // Core properties with defaults
    property bool enabled: true
    property int maxShown: 8
    property int maxWallpapers: 9 // Warning: even numbers look bad
    property string actionPrefix: ">"
    property bool enableDangerousActions: false // Allow actions that can cause losing data, like shutdown, reboot and logout
    property int dragThreshold: 50
    
    // Vim keybinds - default to true, can be overridden by JSON config
    property bool vimKeybinds: true
    
    // Fuzzy search settings
    property UseFuzzy useFuzzy: UseFuzzy {}
    
    // Size settings
    property Sizes sizes: Sizes {}
    
    // Function to update from JSON config
    function updateFromJson(jsonConfig) {
        if (!jsonConfig) return
        
        if (jsonConfig.enabled !== undefined) enabled = jsonConfig.enabled
        if (jsonConfig.vimKeybinds !== undefined) vimKeybinds = jsonConfig.vimKeybinds
        if (jsonConfig.maxShown !== undefined) maxShown = jsonConfig.maxShown
        if (jsonConfig.maxWallpapers !== undefined) maxWallpapers = jsonConfig.maxWallpapers
        if (jsonConfig.actionPrefix !== undefined) actionPrefix = jsonConfig.actionPrefix
        if (jsonConfig.enableDangerousActions !== undefined) enableDangerousActions = jsonConfig.enableDangerousActions
        if (jsonConfig.dragThreshold !== undefined) dragThreshold = jsonConfig.dragThreshold
        
        // Update fuzzy settings
        if (jsonConfig.useFuzzy) {
            useFuzzy.updateFromJson(jsonConfig.useFuzzy)
        }
        
        // Update size settings
        if (jsonConfig.sizes) {
            sizes.updateFromJson(jsonConfig.sizes)
        }
    }

    component UseFuzzy: JsonObject {
        property bool apps: false
        property bool actions: false
        property bool schemes: false
        property bool variants: false
        property bool wallpapers: false
        
        function updateFromJson(jsonConfig) {
            if (!jsonConfig) return
            
            if (jsonConfig.apps !== undefined) apps = jsonConfig.apps
            if (jsonConfig.actions !== undefined) actions = jsonConfig.actions
            if (jsonConfig.schemes !== undefined) schemes = jsonConfig.schemes
            if (jsonConfig.variants !== undefined) variants = jsonConfig.variants
            if (jsonConfig.wallpapers !== undefined) wallpapers = jsonConfig.wallpapers
        }
    }

    component Sizes: JsonObject {
        property int itemWidth: 600
        property int itemHeight: 57
        property int wallpaperWidth: 280
        property int wallpaperHeight: 200
        
        function updateFromJson(jsonConfig) {
            if (!jsonConfig) return
            
            if (jsonConfig.itemWidth !== undefined) itemWidth = jsonConfig.itemWidth
            if (jsonConfig.itemHeight !== undefined) itemHeight = jsonConfig.itemHeight
            if (jsonConfig.wallpaperWidth !== undefined) wallpaperWidth = jsonConfig.wallpaperWidth
            if (jsonConfig.wallpaperHeight !== undefined) wallpaperHeight = jsonConfig.wallpaperHeight
        }
    }
    
    Component.onCompleted: {
        console.log("LauncherConfig initialized with vimKeybinds:", vimKeybinds)
    }
}