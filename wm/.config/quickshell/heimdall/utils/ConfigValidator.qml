import QtQuick
import Quickshell

QtObject {
    id: root
    
    // Validation result structure
    property var lastValidationResult: ({
        valid: true,
        errors: [],
        warnings: []
    })
    
    // Type validation functions
    function validateType(value, expectedType, path) {
        const actualType = typeof value
        
        switch(expectedType) {
            case "string":
                return actualType === "string"
            case "number":
                return actualType === "number" && !isNaN(value)
            case "integer":
                return Number.isInteger(value)
            case "boolean":
                return actualType === "boolean"
            case "array":
                return Array.isArray(value)
            case "object":
                return actualType === "object" && value !== null && !Array.isArray(value)
            case "color":
                return validateColor(value)
            default:
                console.warn(`[ConfigValidator] Unknown type: ${expectedType}`)
                return true
        }
    }
    
    // Color validation
    function validateColor(value) {
        if (typeof value !== "string") return false
        
        // Check hex color format
        const hexPattern = /^#[0-9A-Fa-f]{6}$/
        if (hexPattern.test(value)) return true
        
        // Check hex with alpha
        const hexAlphaPattern = /^#[0-9A-Fa-f]{8}$/
        if (hexAlphaPattern.test(value)) return true
        
        // Check rgb/rgba format
        const rgbPattern = /^rgba?\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*(,\s*[\d.]+\s*)?\)$/
        return rgbPattern.test(value)
    }
    
    // Range validation for numeric values
    function validateRange(value, min, max, path) {
        if (typeof value !== "number") {
            return {
                valid: false,
                error: `${path}: Expected number, got ${typeof value}`
            }
        }
        
        if (min !== undefined && value < min) {
            return {
                valid: false,
                error: `${path}: Value ${value} is below minimum ${min}`
            }
        }
        
        if (max !== undefined && value > max) {
            return {
                valid: false,
                error: `${path}: Value ${value} exceeds maximum ${max}`
            }
        }
        
        return { valid: true }
    }
    
    // Enum validation
    function validateEnum(value, allowedValues, path) {
        if (!allowedValues.includes(value)) {
            return {
                valid: false,
                error: `${path}: Value "${value}" not in allowed values: [${allowedValues.join(", ")}]`
            }
        }
        return { valid: true }
    }
    
    // Pattern validation for strings
    function validatePattern(value, pattern, path) {
        if (typeof value !== "string") {
            return {
                valid: false,
                error: `${path}: Expected string for pattern validation`
            }
        }
        
        const regex = new RegExp(pattern)
        if (!regex.test(value)) {
            return {
                valid: false,
                error: `${path}: Value "${value}" does not match pattern ${pattern}`
            }
        }
        
        return { valid: true }
    }
    
    // Validate duration values
    function validateDuration(value, path) {
        const result = validateRange(value, 0, 10000, path)
        if (!result.valid) return result
        
        if (value > 5000) {
            return {
                valid: true,
                warning: `${path}: Duration ${value}ms is unusually long`
            }
        }
        
        return { valid: true }
    }
    
    // Validate opacity values
    function validateOpacity(value, path) {
        return validateRange(value, 0, 1, path)
    }
    
    // Validate font size
    function validateFontSize(value, path) {
        const result = validateRange(value, 8, 72, path)
        if (!result.valid) return result
        
        if (value < 10) {
            return {
                valid: true,
                warning: `${path}: Font size ${value} may be too small to read`
            }
        }
        
        if (value > 48) {
            return {
                valid: true,
                warning: `${path}: Font size ${value} is very large`
            }
        }
        
        return { valid: true }
    }
    
    // Cross-field validation
    function validateDependencies(config) {
        const errors = []
        const warnings = []
        
        // Animation dependencies
        if (config.modules?.animation) {
            const anim = config.modules.animation
            if (anim.enabled === false) {
                // Warn about animation settings when disabled
                if (anim.durations && Object.keys(anim.durations).length > 0) {
                    warnings.push("Animation durations are configured but animations are disabled")
                }
                if (anim.transitions && Object.keys(anim.transitions).length > 0) {
                    warnings.push("Animation transitions are configured but animations are disabled")
                }
            }
            
            // Check speed multiplier range
            if (anim.speedMultiplier !== undefined) {
                if (anim.speedMultiplier <= 0) {
                    errors.push("animation.speedMultiplier must be greater than 0")
                } else if (anim.speedMultiplier > 10) {
                    warnings.push("animation.speedMultiplier is very high (>10), animations may be too fast")
                } else if (anim.speedMultiplier < 0.1) {
                    warnings.push("animation.speedMultiplier is very low (<0.1), animations may be too slow")
                }
            }
        }
        
        // Service integration dependencies
        if (config.modules?.servicesIntegration) {
            const services = config.modules.servicesIntegration
            
            // Weather service validation
            if (services.weather?.enabled === true) {
                if (!services.weather.apiKey || services.weather.apiKey.length === 0) {
                    errors.push("Weather service is enabled but no API key is provided")
                }
                if (services.weather.updateInterval < 60000) {
                    warnings.push("Weather update interval is less than 1 minute, may hit API rate limits")
                }
            }
            
            // System monitor validation
            if (services.systemMonitor?.enabled === true) {
                if (services.systemMonitor.updateInterval < 100) {
                    errors.push("System monitor update interval is too low (<100ms), will cause high CPU usage")
                }
                if (services.systemMonitor.historySize > 1000) {
                    warnings.push("System monitor history size is very large (>1000), may use excessive memory")
                }
            }
            
            // Notification validation
            if (services.notifications?.enabled === true) {
                if (services.notifications.maxNotifications > 100) {
                    warnings.push("Maximum notifications is very high (>100), may impact performance")
                }
                const validPositions = ["top-left", "top-right", "bottom-left", "bottom-right"]
                if (services.notifications.position && !validPositions.includes(services.notifications.position)) {
                    errors.push(`Invalid notification position: ${services.notifications.position}`)
                }
            }
        }
        
        // Behavior dependencies
        if (config.modules?.behavior) {
            const behavior = config.modules.behavior
            
            // Keyboard mode conflicts
            if (behavior.keyboard?.vimMode === true && behavior.keyboard?.emacsMode === true) {
                errors.push("Cannot enable both vim and emacs keyboard modes simultaneously")
            }
            
            // Performance settings validation
            if (behavior.performance?.enableGPU === false && behavior.performance?.reducedEffects === false) {
                warnings.push("GPU acceleration disabled without reduced effects may cause poor performance")
            }
            
            // Accessibility validation
            if (behavior.accessibility?.enabled === true) {
                if (behavior.accessibility.textScale < 0.5 || behavior.accessibility.textScale > 3.0) {
                    errors.push("Text scale must be between 0.5 and 3.0")
                }
            }
        }
        
        // Theme consistency validation
        if (config.appearance?.theme === "dark" && config.appearance?.backgroundColor) {
            const bg = config.appearance.backgroundColor
            if (isLightColor(bg)) {
                warnings.push("Dark theme selected but backgroundColor appears to be light")
            }
        } else if (config.appearance?.theme === "light" && config.appearance?.backgroundColor) {
            const bg = config.appearance.backgroundColor
            if (!isLightColor(bg)) {
                warnings.push("Light theme selected but backgroundColor appears to be dark")
            }
        }
        
        // UI Components validation
        if (config.modules?.uiComponents) {
            const ui = config.modules.uiComponents
            
            // Validate tooltip settings
            if (ui.toolTip?.delay !== undefined && ui.toolTip?.timeout !== undefined) {
                if (ui.toolTip.delay >= ui.toolTip.timeout) {
                    warnings.push("Tooltip delay is greater than or equal to timeout, tooltip may not show properly")
                }
            }
            
            // Validate dialog dimensions
            if (ui.dialog?.minWidth > ui.dialog?.maxWidth) {
                errors.push("Dialog minWidth cannot be greater than maxWidth")
            }
            if (ui.dialog?.minHeight > ui.dialog?.maxHeight) {
                errors.push("Dialog minHeight cannot be greater than maxHeight")
            }
        }
        
        return { errors, warnings }
    }
    
    // Conditional validation based on field values
    function validateConditional(config, path, value) {
        const errors = []
        const warnings = []
        
        // Service-specific conditional validation
        if (path.startsWith("modules.servicesIntegration.")) {
            const service = path.split(".")[2]
            
            if (service === "weather" && path.endsWith(".provider")) {
                const validProviders = ["openweathermap", "weatherapi", "meteo"]
                if (!validProviders.includes(value)) {
                    errors.push(`Invalid weather provider: ${value}`)
                }
            }
            
            if (service === "database" && path.endsWith(".type")) {
                const validTypes = ["sqlite", "mysql", "postgresql"]
                if (!validTypes.includes(value)) {
                    errors.push(`Invalid database type: ${value}`)
                }
            }
        }
        
        // Animation-specific conditional validation
        if (path.startsWith("modules.animation.transitions.")) {
            const transitionType = path.split(".")[3]
            
            if (path.endsWith(".type")) {
                const validTypes = {
                    page: ["slide", "fade", "scale", "flip", "none"],
                    modal: ["fade", "scale", "fade-scale", "slide-up", "none"],
                    listItem: ["fade", "slide", "fade-slide", "none"],
                    tab: ["slide", "fade", "none"],
                    tooltip: ["fade", "scale", "fade-scale", "none"],
                    menu: ["fade", "scale", "fade-scale", "slide", "none"]
                }
                
                if (validTypes[transitionType] && !validTypes[transitionType].includes(value)) {
                    errors.push(`Invalid ${transitionType} transition type: ${value}`)
                }
            }
        }
        
        return { errors, warnings }
    }
    
    // Helper to determine if a color is light
    function isLightColor(color) {
        if (!color || typeof color !== "string") return false
        
        // Simple hex color lightness check
        if (color.startsWith("#")) {
            const hex = color.substring(1, 7)
            const r = parseInt(hex.substring(0, 2), 16)
            const g = parseInt(hex.substring(2, 4), 16)
            const b = parseInt(hex.substring(4, 6), 16)
            
            // Calculate relative luminance
            const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
            return luminance > 0.5
        }
        
        return false
    }
    
    // Main validation function
    function validateConfiguration(config, schema) {
        const errors = []
        const warnings = []
        
        // Validate version if present
        if (schema?.required?.includes("version")) {
            if (!config.version) {
                errors.push("Missing required field: version")
            } else {
                const versionResult = validatePattern(
                    config.version,
                    "^\\d+\\.\\d+\\.\\d+$",
                    "version"
                )
                if (!versionResult.valid) {
                    errors.push(versionResult.error)
                }
            }
        }
        
        // Validate each module configuration
        if (config.modules) {
            const moduleResults = validateModules(config.modules)
            errors.push(...moduleResults.errors)
            warnings.push(...moduleResults.warnings)
        }
        
        // Validate appearance configuration
        if (config.appearance) {
            const appearanceResults = validateAppearance(config.appearance)
            errors.push(...appearanceResults.errors)
            warnings.push(...appearanceResults.warnings)
        }
        
        // Cross-field validation
        const depResults = validateDependencies(config)
        errors.push(...depResults.errors)
        warnings.push(...depResults.warnings)
        
        // Store and return results
        lastValidationResult = {
            valid: errors.length === 0,
            errors: errors,
            warnings: warnings
        }
        
        return lastValidationResult
    }
    
    // Validate module configurations
    function validateModules(modules) {
        const errors = []
        const warnings = []
        
        // Validate launcher module
        if (modules.launcher) {
            const launcher = modules.launcher
            
            if (launcher.searchDelayMs !== undefined) {
                const result = validateDuration(launcher.searchDelayMs, "modules.launcher.searchDelayMs")
                if (!result.valid) errors.push(result.error)
                if (result.warning) warnings.push(result.warning)
            }
            
            if (launcher.maxResults !== undefined) {
                const result = validateRange(launcher.maxResults, 1, 100, "modules.launcher.maxResults")
                if (!result.valid) errors.push(result.error)
            }
            
            if (launcher.position !== undefined) {
                const result = validateEnum(
                    launcher.position,
                    ["top", "bottom", "left", "right", "center"],
                    "modules.launcher.position"
                )
                if (!result.valid) errors.push(result.error)
            }
        }
        
        // Validate bar module
        if (modules.bar) {
            const bar = modules.bar
            
            if (bar.height !== undefined) {
                const result = validateRange(bar.height, 20, 200, "modules.bar.height")
                if (!result.valid) errors.push(result.error)
            }
            
            if (bar.position !== undefined) {
                const result = validateEnum(
                    bar.position,
                    ["top", "bottom"],
                    "modules.bar.position"
                )
                if (!result.valid) errors.push(result.error)
            }
        }
        
        return { errors, warnings }
    }
    
    // Validate appearance configuration
    function validateAppearance(appearance) {
        const errors = []
        const warnings = []
        
        if (appearance.theme !== undefined) {
            const result = validateEnum(
                appearance.theme,
                ["light", "dark", "auto"],
                "appearance.theme"
            )
            if (!result.valid) errors.push(result.error)
        }
        
        if (appearance.accentColor !== undefined) {
            if (!validateColor(appearance.accentColor)) {
                errors.push(`appearance.accentColor: Invalid color format "${appearance.accentColor}"`)
            }
        }
        
        if (appearance.fontSize !== undefined) {
            const result = validateFontSize(appearance.fontSize, "appearance.fontSize")
            if (!result.valid) errors.push(result.error)
            if (result.warning) warnings.push(result.warning)
        }
        
        if (appearance.opacity !== undefined) {
            const result = validateOpacity(appearance.opacity, "appearance.opacity")
            if (!result.valid) errors.push(result.error)
        }
        
        return { errors, warnings }
    }
    
    // Validate and sanitize configuration
    function sanitizeConfiguration(config) {
        const sanitized = JSON.parse(JSON.stringify(config)) // Deep clone
        
        // Remove invalid properties
        function removeInvalid(obj, path = "") {
            for (const key in obj) {
                const fullPath = path ? `${path}.${key}` : key
                const value = obj[key]
                
                // Remove null or undefined values
                if (value === null || value === undefined) {
                    delete obj[key]
                    continue
                }
                
                // Recursively sanitize nested objects
                if (typeof value === "object" && !Array.isArray(value)) {
                    removeInvalid(value, fullPath)
                    
                    // Remove empty objects
                    if (Object.keys(value).length === 0) {
                        delete obj[key]
                    }
                }
            }
        }
        
        removeInvalid(sanitized)
        return sanitized
    }
    
    // Generate validation report
    function generateValidationReport(config, schema) {
        const result = validateConfiguration(config, schema)
        
        let report = "# Configuration Validation Report\n\n"
        report += `**Status**: ${result.valid ? "✅ Valid" : "❌ Invalid"}\n\n`
        
        if (result.errors.length > 0) {
            report += "## Errors\n\n"
            result.errors.forEach(error => {
                report += `- ❌ ${error}\n`
            })
            report += "\n"
        }
        
        if (result.warnings.length > 0) {
            report += "## Warnings\n\n"
            result.warnings.forEach(warning => {
                report += `- ⚠️ ${warning}\n`
            })
            report += "\n"
        }
        
        if (result.valid && result.warnings.length === 0) {
            report += "No issues found. Configuration is valid.\n"
        }
        
        return report
    }
}