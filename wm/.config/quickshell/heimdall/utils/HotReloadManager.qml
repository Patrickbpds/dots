pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    // Configuration properties
    property int debounceMs: 500
    property bool validateSchema: true
    property bool backupOnChange: true
    property bool enabled: true
    property int maxBackups: 10
    
    // State tracking
    property bool reloadInProgress: false
    property var pendingReload: null
    property var backupHistory: []
    property var lastValidConfig: null
    property int reloadCount: 0
    property var reloadStats: ({
        total: 0,
        successful: 0,
        failed: 0,
        rolledBack: 0
    })
    
    // Signals
    signal reloadScheduled()
    signal reloadStarted()
    signal reloadCompleted(bool success)
    signal reloadFailed(string error)
    signal validationFailed(string error)
    signal backupCreated(string timestamp)
    signal rollbackPerformed(string timestamp)
    
    // Debounce timer for reload operations
    Timer {
        id: debounceTimer
        interval: root.debounceMs
        repeat: false
        onTriggered: {
            if (pendingReload) {
                performReload(pendingReload.path, pendingReload.content, pendingReload.callback)
                pendingReload = null
            }
        }
    }
    
    // Schedule a configuration reload with debouncing
    function scheduleReload(configPath, configContent, callback) {
        if (!enabled) {
            console.log("[HotReloadManager] Hot reload is disabled")
            if (callback) callback(false, "Hot reload disabled")
            return
        }
        
        if (reloadInProgress) {
            console.log("[HotReloadManager] Reload already in progress, queueing")
            pendingReload = {
                path: configPath,
                content: configContent,
                callback: callback
            }
            return
        }
        
        console.log(`[HotReloadManager] Scheduling reload with ${debounceMs}ms debounce`)
        
        pendingReload = {
            path: configPath,
            content: configContent,
            callback: callback
        }
        
        debounceTimer.restart()
        reloadScheduled()
    }
    
    // Perform the actual reload with validation and backup
    function performReload(configPath, configContent, callback) {
        console.log("[HotReloadManager] Starting configuration reload")
        reloadInProgress = true
        reloadStarted()
        reloadStats.total++
        
        try {
            // Step 1: Parse the configuration
            let config = null
            if (typeof configContent === 'string') {
                config = JSON.parse(configContent)
            } else {
                config = configContent
            }
            
            // Step 2: Validate the configuration
            if (validateSchema) {
                const validationResult = validateConfiguration(config)
                if (!validationResult.valid) {
                    const error = `Validation failed: ${validationResult.error}`
                    console.error(`[HotReloadManager] ${error}`)
                    validationFailed(error)
                    reloadStats.failed++
                    
                    if (callback) callback(false, error)
                    reloadInProgress = false
                    reloadFailed(error)
                    return
                }
            }
            
            // Step 3: Create backup if enabled
            if (backupOnChange && lastValidConfig) {
                createBackup(lastValidConfig)
            }
            
            // Step 4: Apply the configuration
            const applyResult = applyConfiguration(config)
            
            if (applyResult.success) {
                // Success - store as last valid config
                lastValidConfig = config
                reloadStats.successful++
                console.log("[HotReloadManager] Configuration reload successful")
                
                if (callback) callback(true, null)
                reloadCompleted(true)
            } else {
                // Failed - attempt rollback
                const error = applyResult.error || "Unknown error"
                console.error(`[HotReloadManager] Configuration apply failed: ${error}`)
                reloadStats.failed++
                
                if (lastValidConfig && backupOnChange) {
                    console.log("[HotReloadManager] Attempting rollback to last valid configuration")
                    const rollbackResult = rollback()
                    
                    if (rollbackResult.success) {
                        reloadStats.rolledBack++
                        if (callback) callback(false, `Failed but rolled back: ${error}`)
                    } else {
                        if (callback) callback(false, `Failed and rollback failed: ${error}`)
                    }
                } else {
                    if (callback) callback(false, error)
                }
                
                reloadFailed(error)
            }
            
        } catch (error) {
            console.error("[HotReloadManager] Reload error:", error.toString())
            reloadStats.failed++
            
            if (callback) callback(false, error.toString())
            reloadFailed(error.toString())
        } finally {
            reloadInProgress = false
            reloadCount++
            
            // Check if there's a pending reload
            if (pendingReload) {
                console.log("[HotReloadManager] Processing pending reload")
                Timer.singleShot(100, function() {
                    performReload(pendingReload.path, pendingReload.content, pendingReload.callback)
                    pendingReload = null
                })
            }
        }
    }
    
    // Validate configuration against schema
    function validateConfiguration(config) {
        try {
            // Basic structure validation
            if (!config || typeof config !== 'object') {
                return { valid: false, error: "Configuration must be an object" }
            }
            
            // Check version if present
            if (config.version) {
                const version = config.version.split('.')
                if (version.length !== 3) {
                    return { valid: false, error: "Invalid version format (expected x.y.z)" }
                }
            }
            
            // Validate modules section
            if (config.modules) {
                if (typeof config.modules !== 'object') {
                    return { valid: false, error: "Modules must be an object" }
                }
                
                // Validate known modules
                const knownModules = ['launcher', 'session', 'background', 'bar', 
                                     'dashboard', 'controlCenter', 'notifs', 'osd', 
                                     'winfo', 'lock']
                
                for (let moduleName in config.modules) {
                    if (!knownModules.includes(moduleName)) {
                        console.warn(`[HotReloadManager] Unknown module: ${moduleName}`)
                    }
                    
                    const module = config.modules[moduleName]
                    if (typeof module !== 'object') {
                        return { valid: false, error: `Module ${moduleName} must be an object` }
                    }
                    
                    // Module-specific validation
                    const moduleValidation = validateModule(moduleName, module)
                    if (!moduleValidation.valid) {
                        return moduleValidation
                    }
                }
            }
            
            // Validate appearance section
            if (config.appearance) {
                if (typeof config.appearance !== 'object') {
                    return { valid: false, error: "Appearance must be an object" }
                }
                
                // Validate color values
                if (config.appearance.colors) {
                    for (let colorKey in config.appearance.colors) {
                        const color = config.appearance.colors[colorKey]
                        if (!isValidColor(color)) {
                            return { valid: false, error: `Invalid color value for appearance.colors.${colorKey}` }
                        }
                    }
                }
            }
            
            // Validate hot reload settings
            if (config.hotReload) {
                if (typeof config.hotReload !== 'object') {
                    return { valid: false, error: "HotReload must be an object" }
                }
                
                if ('debounceMs' in config.hotReload) {
                    const debounce = config.hotReload.debounceMs
                    if (typeof debounce !== 'number' || debounce < 0 || debounce > 10000) {
                        return { valid: false, error: "HotReload.debounceMs must be between 0 and 10000" }
                    }
                }
            }
            
            return { valid: true }
            
        } catch (error) {
            return { valid: false, error: error.toString() }
        }
    }
    
    // Validate individual modules
    function validateModule(moduleName, module) {
        switch (moduleName) {
            case 'launcher':
                if ('enabled' in module && typeof module.enabled !== 'boolean') {
                    return { valid: false, error: "launcher.enabled must be boolean" }
                }
                if ('vimKeybinds' in module && typeof module.vimKeybinds !== 'boolean') {
                    return { valid: false, error: "launcher.vimKeybinds must be boolean" }
                }
                if (module.sizes) {
                    for (let sizeKey in module.sizes) {
                        if (typeof module.sizes[sizeKey] !== 'number') {
                            return { valid: false, error: `launcher.sizes.${sizeKey} must be a number` }
                        }
                    }
                }
                break
                
            case 'session':
                if ('enabled' in module && typeof module.enabled !== 'boolean') {
                    return { valid: false, error: "session.enabled must be boolean" }
                }
                break
                
            // Add more module-specific validation as needed
        }
        
        return { valid: true }
    }
    
    // Check if a value is a valid color
    function isValidColor(value) {
        if (typeof value !== 'string') return false
        
        // Hex color
        if (/^#[0-9A-Fa-f]{3,8}$/.test(value)) return true
        
        // RGB/RGBA
        if (/^rgba?\(/.test(value)) return true
        
        // Named colors
        const namedColors = ['black', 'white', 'red', 'green', 'blue', 'yellow', 
                           'cyan', 'magenta', 'gray', 'grey', 'transparent']
        if (namedColors.includes(value.toLowerCase())) return true
        
        return false
    }
    
    // Apply configuration (delegate to Config singleton)
    function applyConfiguration(config) {
        try {
            // This would normally call the Config singleton's apply method
            // For now, we'll simulate it
            console.log("[HotReloadManager] Applying configuration:", JSON.stringify(config).substring(0, 100) + "...")
            
            // Simulate applying configuration
            // In real implementation, this would call Config.applyExternalConfig(JSON.stringify(config))
            
            return { success: true }
        } catch (error) {
            return { success: false, error: error.toString() }
        }
    }
    
    // Create a backup of the current configuration
    function createBackup(config) {
        try {
            const timestamp = new Date().toISOString()
            const backup = {
                timestamp: timestamp,
                config: JSON.parse(JSON.stringify(config)) // Deep copy
            }
            
            backupHistory.push(backup)
            
            // Limit backup history
            if (backupHistory.length > maxBackups) {
                backupHistory.shift()
            }
            
            console.log(`[HotReloadManager] Backup created at ${timestamp}`)
            backupCreated(timestamp)
            
            return true
        } catch (error) {
            console.error("[HotReloadManager] Failed to create backup:", error.toString())
            return false
        }
    }
    
    // Rollback to last valid configuration
    function rollback() {
        try {
            if (!lastValidConfig) {
                console.error("[HotReloadManager] No valid configuration to rollback to")
                return { success: false, error: "No valid configuration available" }
            }
            
            console.log("[HotReloadManager] Rolling back to last valid configuration")
            const result = applyConfiguration(lastValidConfig)
            
            if (result.success) {
                const timestamp = lastValidConfig.timestamp || new Date().toISOString()
                rollbackPerformed(timestamp)
            }
            
            return result
        } catch (error) {
            return { success: false, error: error.toString() }
        }
    }
    
    // Rollback to a specific backup
    function rollbackToBackup(index) {
        if (index < 0 || index >= backupHistory.length) {
            console.error("[HotReloadManager] Invalid backup index")
            return false
        }
        
        const backup = backupHistory[index]
        console.log(`[HotReloadManager] Rolling back to backup from ${backup.timestamp}`)
        
        const result = applyConfiguration(backup.config)
        if (result.success) {
            lastValidConfig = backup.config
            rollbackPerformed(backup.timestamp)
        }
        
        return result.success
    }
    
    // Get reload statistics
    function getStats() {
        return {
            total: reloadStats.total,
            successful: reloadStats.successful,
            failed: reloadStats.failed,
            averageTime: reloadStats.averageTime,
            lastError: reloadStats.lastError,
            successRate: reloadStats.total > 0 ? 
                (reloadStats.successful / reloadStats.total * 100).toFixed(1) + '%' : 'N/A',
            backupCount: backupHistory.length,
            lastReloadTime: reloadCount > 0 ? new Date().toISOString() : 'Never'
        }
    }
    
    // Clear backup history
    function clearBackups() {
        backupHistory = []
        console.log("[HotReloadManager] Backup history cleared")
    }
    
    // Reset statistics
    function resetStats() {
        reloadStats = {
            total: 0,
            successful: 0,
            failed: 0,
            rolledBack: 0
        }
        reloadCount = 0
        console.log("[HotReloadManager] Statistics reset")
    }
    
    Component.onCompleted: {
        console.log("[HotReloadManager] Initialized")
        console.log(`  - Debounce: ${debounceMs}ms`)
        console.log(`  - Validation: ${validateSchema}`)
        console.log(`  - Backup: ${backupOnChange}`)
        console.log(`  - Max backups: ${maxBackups}`)
        console.log(`  - Enabled: ${enabled}`)
    }
}