pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root
    
    // Debounce timers for different configuration sections
    property var debouncers: ({})
    
    // Registered handlers for configuration changes
    property var handlers: ({})
    
    // Register a handler for configuration changes
    function registerHandler(section, callback) {
        if (!handlers[section]) {
            handlers[section] = []
        }
        handlers[section].push(callback)
        console.log(`Registered handler for section: ${section}`)
    }
    
    // Unregister a handler
    function unregisterHandler(section, callback) {
        if (handlers[section]) {
            const index = handlers[section].indexOf(callback)
            if (index > -1) {
                handlers[section].splice(index, 1)
                console.log(`Unregistered handler for section: ${section}`)
            }
        }
    }
    
    // Handle configuration change with debouncing
    function handleChange(section, immediate = false) {
        const debounceMs = Config.get("hotReload.debounceMs", 500)
        
        if (immediate) {
            propagateChange(section)
        } else {
            // Create debouncer if it doesn't exist
            if (!debouncers[section]) {
                debouncers[section] = Qt.createQmlObject(`
                    import QtQuick
                    Timer {
                        interval: ${debounceMs}
                        repeat: false
                        onTriggered: {
                            ConfigChangeHandler.propagateChange("${section}")
                        }
                    }
                `, root, `debouncer_${section}`)
            }
            
            // Restart the debouncer
            debouncers[section].restart()
        }
    }
    
    // Propagate changes to registered handlers
    function propagateChange(section) {
        console.log(`Propagating changes for section: ${section}`)
        
        // Call section-specific handlers
        if (handlers[section]) {
            handlers[section].forEach(handler => {
                try {
                    handler(section)
                } catch (error) {
                    console.error(`Error in handler for ${section}:`, error)
                }
            })
        }
        
        // Call global handlers
        if (handlers["*"]) {
            handlers["*"].forEach(handler => {
                try {
                    handler(section)
                } catch (error) {
                    console.error(`Error in global handler:`, error)
                }
            })
        }
        
        // Emit specific refresh signals based on section
        switch(section) {
            case "appearance":
                refreshAppearance()
                break
            case "bar":
                refreshBar()
                break
            case "modules":
                refreshModules()
                break
            case "services":
                refreshServices()
                break
            case "wallpaper":
                refreshWallpaper()
                break
            case "commands":
                refreshCommands()
                break
            case "all":
                refreshAll()
                break
        }
    }
    
    // Refresh functions for different components
    function refreshAppearance() {
        console.log("Refreshing appearance...")
        // Update all appearance-related properties
        const components = ["rounding", "spacing", "padding", "font", "animation", "transparency"]
        components.forEach(comp => {
            const value = Config.get(`appearance.${comp}`, {})
            // Notify components about the change
            appearanceRefreshed(comp, value)
        })
    }
    
    function refreshBar() {
        console.log("Refreshing bar configuration...")
        // Update bar properties
        const barConfig = Config.get("bar", {})
        barRefreshed(barConfig)
    }
    
    function refreshModules() {
        console.log("Refreshing modules...")
        const modules = Config.get("modules", {})
        Object.keys(modules).forEach(moduleName => {
            moduleRefreshed(moduleName, modules[moduleName])
        })
    }
    
    function refreshServices() {
        console.log("Refreshing services...")
        const services = Config.get("services", {})
        servicesRefreshed(services)
    }
    
    function refreshWallpaper() {
        console.log("Refreshing wallpaper...")
        const wallpaper = Config.get("wallpaper", {})
        wallpaperRefreshed(wallpaper)
    }
    
    function refreshCommands() {
        console.log("Refreshing commands...")
        const commands = Config.get("commands", {})
        commandsRefreshed(commands)
    }
    
    function refreshAll() {
        console.log("Refreshing all components...")
        refreshAppearance()
        refreshBar()
        refreshModules()
        refreshServices()
        refreshWallpaper()
        refreshCommands()
    }
    
    // Signals emitted when specific sections are refreshed
    signal appearanceRefreshed(string component, var value)
    signal barRefreshed(var config)
    signal moduleRefreshed(string moduleName, var config)
    signal servicesRefreshed(var config)
    signal wallpaperRefreshed(var config)
    signal commandsRefreshed(var config)
    
    // Connect to Config signals
    Connections {
        target: Config
        
        function onConfigurationChanged(section) {
            handleChange(section)
        }
        
        function onAppearanceUpdated() {
            handleChange("appearance")
        }
        
        function onBarConfigUpdated() {
            handleChange("bar")
        }
        
        function onModulesConfigUpdated() {
            handleChange("modules")
        }
        
        function onServicesConfigUpdated() {
            handleChange("services")
        }
        
        function onWallpaperConfigUpdated() {
            handleChange("wallpaper")
        }
        
        function onCommandsConfigUpdated() {
            handleChange("commands")
        }
    }
    
    Component.onCompleted: {
        console.log("ConfigChangeHandler initialized")
        console.log("Debounce time:", Config.get("hotReload.debounceMs", 500), "ms")
    }
}