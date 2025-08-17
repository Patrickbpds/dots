import QtQuick
import Quickshell

QtObject {
    id: root
    
    // Current configuration version
    readonly property string currentVersion: "2.0.0"
    
    // Minimum supported version for compatibility
    readonly property string minimumSupportedVersion: "1.0.0"
    
    // Version comparison utilities
    function parseVersion(versionString) {
        if (!versionString || typeof versionString !== "string") {
            return null
        }
        
        const parts = versionString.split(".")
        if (parts.length !== 3) {
            return null
        }
        
        const major = parseInt(parts[0])
        const minor = parseInt(parts[1])
        const patch = parseInt(parts[2])
        
        if (isNaN(major) || isNaN(minor) || isNaN(patch)) {
            return null
        }
        
        return {
            major: major,
            minor: minor,
            patch: patch,
            string: versionString
        }
    }
    
    // Compare two version objects
    // Returns: -1 if v1 < v2, 0 if v1 == v2, 1 if v1 > v2
    function compareVersions(v1, v2) {
        if (!v1 || !v2) return 0
        
        if (v1.major !== v2.major) {
            return v1.major > v2.major ? 1 : -1
        }
        
        if (v1.minor !== v2.minor) {
            return v1.minor > v2.minor ? 1 : -1
        }
        
        if (v1.patch !== v2.patch) {
            return v1.patch > v2.patch ? 1 : -1
        }
        
        return 0
    }
    
    // Check if a version string is compatible
    function isVersionCompatible(versionString) {
        const version = parseVersion(versionString)
        const current = parseVersion(currentVersion)
        const minimum = parseVersion(minimumSupportedVersion)
        
        if (!version) {
            console.warn("[ConfigVersionManager] Invalid version string:", versionString)
            return false
        }
        
        // Check if version is at least the minimum supported
        if (compareVersions(version, minimum) < 0) {
            console.warn("[ConfigVersionManager] Version too old:", versionString)
            return false
        }
        
        // Check if version is not newer than current
        if (compareVersions(version, current) > 0) {
            console.warn("[ConfigVersionManager] Version too new:", versionString)
            return false
        }
        
        return true
    }
    
    // Detect which version a configuration is
    function detectConfigVersion(config) {
        // If version is explicitly specified, use it
        if (config.version) {
            return config.version
        }
        
        // Try to detect version based on structure
        // Version 1.0.0 characteristics
        if (config.launcher && !config.modules) {
            return "1.0.0"
        }
        
        // Version 2.0.0 characteristics
        if (config.modules) {
            return "2.0.0"
        }
        
        // Default to oldest version if unknown
        return "1.0.0"
    }
    
    // Migration functions
    function migrate_1_0_0_to_1_1_0(config) {
        console.log("[ConfigVersionManager] Migrating from 1.0.0 to 1.1.0")
        
        const migrated = JSON.parse(JSON.stringify(config)) // Deep clone
        
        // Add version field if missing
        migrated.version = "1.1.0"
        
        // Migrate color properties to new structure
        if (migrated.colours) {
            migrated.colors = migrated.colours
            delete migrated.colours
        }
        
        return migrated
    }
    
    function migrate_1_1_0_to_2_0_0(config) {
        console.log("[ConfigVersionManager] Migrating from 1.1.0 to 2.0.0")
        
        const migrated = {
            version: "2.0.0",
            meta: {
                version: "2.0.0",
                created: new Date().toISOString(),
                modified: new Date().toISOString()
            }
        }
        
        // Migrate appearance settings
        if (config.appearance) {
            migrated.appearance = config.appearance
        }
        
        // Migrate colors
        if (config.colors || config.colours) {
            migrated.colors = config.colors || config.colours
        }
        
        // Migrate modules to new structure
        migrated.modules = {}
        
        // Migrate launcher
        if (config.launcher) {
            migrated.modules.launcher = config.launcher
            if (migrated.modules.launcher.enabled === undefined) {
                migrated.modules.launcher.enabled = true
            }
        }
        
        // Migrate session
        if (config.session) {
            migrated.modules.session = config.session
        }
        
        // Migrate bar
        if (config.bar) {
            migrated.modules.bar = config.bar
        }
        
        // Migrate control center
        if (config.controlCenter || config.controlPanel) {
            migrated.modules.controlCenter = config.controlCenter || config.controlPanel
        }
        
        // Migrate dashboard
        if (config.dashboard) {
            migrated.modules.dashboard = config.dashboard
        }
        
        // Migrate notifications
        if (config.notifs || config.notifications) {
            migrated.modules.notifications = config.notifs || config.notifications
        }
        
        // Migrate lock screen
        if (config.lock) {
            migrated.modules.lock = config.lock
        }
        
        // Migrate OSD
        if (config.osd) {
            migrated.modules.osd = config.osd
        }
        
        // Migrate services
        if (config.services) {
            migrated.services = config.services
        }
        
        // Migrate paths
        if (config.paths) {
            migrated.paths = config.paths
        }
        
        return migrated
    }
    
    // Main migration function
    function migrateConfiguration(config) {
        const detectedVersion = detectConfigVersion(config)
        const version = parseVersion(detectedVersion)
        const target = parseVersion(currentVersion)
        
        if (!version) {
            console.error("[ConfigVersionManager] Could not detect configuration version")
            return null
        }
        
        // If already at current version, no migration needed
        if (compareVersions(version, target) === 0) {
            console.log("[ConfigVersionManager] Configuration already at current version")
            return config
        }
        
        // If newer than current version, cannot migrate
        if (compareVersions(version, target) > 0) {
            console.error("[ConfigVersionManager] Configuration version is newer than supported")
            return null
        }
        
        let migrated = JSON.parse(JSON.stringify(config)) // Deep clone
        
        // Apply migrations in sequence
        const migrations = [
            { from: "1.0.0", to: "1.1.0", func: migrate_1_0_0_to_1_1_0 },
            { from: "1.1.0", to: "2.0.0", func: migrate_1_1_0_to_2_0_0 }
        ]
        
        let currentVersionStr = detectedVersion
        
        while (currentVersionStr !== currentVersion) {
            let migrationApplied = false
            
            for (const migration of migrations) {
                if (migration.from === currentVersionStr) {
                    migrated = migration.func(migrated)
                    currentVersionStr = migration.to
                    migrationApplied = true
                    break
                }
            }
            
            if (!migrationApplied) {
                console.error("[ConfigVersionManager] No migration path from", currentVersionStr)
                return null
            }
        }
        
        console.log("[ConfigVersionManager] Migration complete to version", currentVersion)
        return migrated
    }
    
    // Create a backup of the configuration
    function createBackup(config) {
        const timestamp = new Date().toISOString().replace(/[:.]/g, "-")
        const backup = {
            timestamp: timestamp,
            version: detectConfigVersion(config),
            config: JSON.parse(JSON.stringify(config))
        }
        
        return backup
    }
    
    // Restore from backup
    function restoreFromBackup(backup) {
        if (!backup || !backup.config) {
            console.error("[ConfigVersionManager] Invalid backup format")
            return null
        }
        
        console.log("[ConfigVersionManager] Restoring from backup:", backup.timestamp)
        
        // Migrate the backup if needed
        return migrateConfiguration(backup.config)
    }
    
    // Generate migration report
    function generateMigrationReport(originalConfig, migratedConfig) {
        const report = {
            success: migratedConfig !== null,
            originalVersion: detectConfigVersion(originalConfig),
            targetVersion: currentVersion,
            changes: []
        }
        
        if (!migratedConfig) {
            report.error = "Migration failed"
            return report
        }
        
        // Compare structures to identify changes
        function compareObjects(original, migrated, path = "") {
            const changes = []
            
            // Check for new properties in migrated
            for (const key in migrated) {
                const fullPath = path ? `${path}.${key}` : key
                
                if (!(key in original)) {
                    changes.push({
                        type: "added",
                        path: fullPath,
                        value: migrated[key]
                    })
                } else if (typeof migrated[key] === "object" && typeof original[key] === "object") {
                    changes.push(...compareObjects(original[key], migrated[key], fullPath))
                } else if (migrated[key] !== original[key]) {
                    changes.push({
                        type: "modified",
                        path: fullPath,
                        oldValue: original[key],
                        newValue: migrated[key]
                    })
                }
            }
            
            // Check for removed properties
            for (const key in original) {
                const fullPath = path ? `${path}.${key}` : key
                
                if (!(key in migrated)) {
                    changes.push({
                        type: "removed",
                        path: fullPath,
                        value: original[key]
                    })
                }
            }
            
            return changes
        }
        
        report.changes = compareObjects(originalConfig, migratedConfig)
        return report
    }
    
    // Check if migration is needed
    function needsMigration(config) {
        const version = detectConfigVersion(config)
        const current = parseVersion(currentVersion)
        const detected = parseVersion(version)
        
        if (!detected) return true
        
        return compareVersions(detected, current) < 0
    }
}