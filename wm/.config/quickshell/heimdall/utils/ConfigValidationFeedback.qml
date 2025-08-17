import QtQuick
import Quickshell

QtObject {
    id: root
    
    // Validation result levels
    readonly property int levelInfo: 0
    readonly property int levelWarning: 1
    readonly property int levelError: 2
    readonly property int levelCritical: 3
    
    // Validation feedback messages
    property var feedbackMessages: []
    
    // Statistics
    property int totalErrors: 0
    property int totalWarnings: 0
    property int totalInfo: 0
    
    // Create a validation message
    function createMessage(level, path, message, suggestion) {
        return {
            level: level,
            path: path,
            message: message,
            suggestion: suggestion || "",
            timestamp: new Date().toISOString()
        }
    }
    
    // Add validation feedback
    function addFeedback(level, path, message, suggestion) {
        const feedback = createMessage(level, path, message, suggestion)
        feedbackMessages.push(feedback)
        
        // Update statistics
        switch(level) {
            case levelError:
            case levelCritical:
                totalErrors++
                break
            case levelWarning:
                totalWarnings++
                break
            case levelInfo:
                totalInfo++
                break
        }
        
        return feedback
    }
    
    // Clear all feedback
    function clearFeedback() {
        feedbackMessages = []
        totalErrors = 0
        totalWarnings = 0
        totalInfo = 0
    }
    
    // Get feedback by level
    function getFeedbackByLevel(level) {
        return feedbackMessages.filter(msg => msg.level === level)
    }
    
    // Get feedback for specific path
    function getFeedbackForPath(path) {
        return feedbackMessages.filter(msg => msg.path.startsWith(path))
    }
    
    // Format feedback message for display
    function formatFeedback(feedback) {
        const levelSymbols = {
            [levelInfo]: "ℹ️",
            [levelWarning]: "⚠️",
            [levelError]: "❌",
            [levelCritical]: "🚨"
        }
        
        const levelNames = {
            [levelInfo]: "INFO",
            [levelWarning]: "WARNING",
            [levelError]: "ERROR",
            [levelCritical]: "CRITICAL"
        }
        
        let formatted = `${levelSymbols[feedback.level]} [${levelNames[feedback.level]}] ${feedback.path}: ${feedback.message}`
        
        if (feedback.suggestion) {
            formatted += `\n   💡 Suggestion: ${feedback.suggestion}`
        }
        
        return formatted
    }
    
    // Generate detailed validation report
    function generateDetailedReport() {
        let report = "# Configuration Validation Report\n\n"
        report += `Generated: ${new Date().toISOString()}\n\n`
        
        // Summary section
        report += "## Summary\n\n"
        report += `- **Total Issues**: ${feedbackMessages.length}\n`
        report += `- **Errors**: ${totalErrors}\n`
        report += `- **Warnings**: ${totalWarnings}\n`
        report += `- **Info**: ${totalInfo}\n\n`
        
        // Overall status
        if (totalErrors > 0) {
            report += "**Status**: ❌ Configuration has errors that must be fixed\n\n"
        } else if (totalWarnings > 0) {
            report += "**Status**: ⚠️ Configuration is valid but has warnings\n\n"
        } else {
            report += "**Status**: ✅ Configuration is valid\n\n"
        }
        
        // Critical errors
        const criticalErrors = getFeedbackByLevel(levelCritical)
        if (criticalErrors.length > 0) {
            report += "## 🚨 Critical Errors\n\n"
            report += "These errors will prevent the application from running:\n\n"
            criticalErrors.forEach(feedback => {
                report += `- **${feedback.path}**: ${feedback.message}\n`
                if (feedback.suggestion) {
                    report += `  - *Fix*: ${feedback.suggestion}\n`
                }
            })
            report += "\n"
        }
        
        // Regular errors
        const errors = getFeedbackByLevel(levelError)
        if (errors.length > 0) {
            report += "## ❌ Errors\n\n"
            report += "These errors should be fixed for proper functionality:\n\n"
            errors.forEach(feedback => {
                report += `- **${feedback.path}**: ${feedback.message}\n`
                if (feedback.suggestion) {
                    report += `  - *Fix*: ${feedback.suggestion}\n`
                }
            })
            report += "\n"
        }
        
        // Warnings
        const warnings = getFeedbackByLevel(levelWarning)
        if (warnings.length > 0) {
            report += "## ⚠️ Warnings\n\n"
            report += "These warnings indicate potential issues:\n\n"
            warnings.forEach(feedback => {
                report += `- **${feedback.path}**: ${feedback.message}\n`
                if (feedback.suggestion) {
                    report += `  - *Suggestion*: ${feedback.suggestion}\n`
                }
            })
            report += "\n"
        }
        
        // Info messages
        const info = getFeedbackByLevel(levelInfo)
        if (info.length > 0) {
            report += "## ℹ️ Information\n\n"
            report += "Additional information about your configuration:\n\n"
            info.forEach(feedback => {
                report += `- **${feedback.path}**: ${feedback.message}\n`
            })
            report += "\n"
        }
        
        // Recommendations
        report += "## 📋 Recommendations\n\n"
        report += generateRecommendations()
        
        return report
    }
    
    // Generate recommendations based on feedback
    function generateRecommendations() {
        let recommendations = []
        
        // Check for common issues
        const animationIssues = getFeedbackForPath("modules.animation")
        if (animationIssues.length > 0) {
            recommendations.push("- Review animation settings for consistency")
        }
        
        const serviceIssues = getFeedbackForPath("modules.servicesIntegration")
        if (serviceIssues.length > 0) {
            recommendations.push("- Check service configurations and API keys")
        }
        
        const performanceWarnings = feedbackMessages.filter(msg => 
            msg.message.toLowerCase().includes("performance") ||
            msg.message.toLowerCase().includes("cpu") ||
            msg.message.toLowerCase().includes("memory")
        )
        if (performanceWarnings.length > 0) {
            recommendations.push("- Consider adjusting settings that may impact performance")
        }
        
        // General recommendations
        if (totalErrors === 0 && totalWarnings === 0) {
            recommendations.push("- Your configuration looks good!")
            recommendations.push("- Consider creating a backup of this working configuration")
        } else if (totalErrors > 5) {
            recommendations.push("- Fix critical errors first before addressing warnings")
            recommendations.push("- Consider resetting to default configuration if issues persist")
        }
        
        if (recommendations.length === 0) {
            recommendations.push("- Review the issues above and apply suggested fixes")
        }
        
        return recommendations.join("\n") + "\n"
    }
    
    // Generate console output
    function printToConsole() {
        console.log("=== Configuration Validation Results ===")
        console.log(`Errors: ${totalErrors}, Warnings: ${totalWarnings}, Info: ${totalInfo}`)
        
        feedbackMessages.forEach(feedback => {
            const formatted = formatFeedback(feedback)
            
            switch(feedback.level) {
                case levelCritical:
                case levelError:
                    console.error(formatted)
                    break
                case levelWarning:
                    console.warn(formatted)
                    break
                case levelInfo:
                    console.log(formatted)
                    break
            }
        })
        
        console.log("========================================")
    }
    
    // Generate JSON report for external tools
    function generateJSONReport() {
        return JSON.stringify({
            timestamp: new Date().toISOString(),
            summary: {
                total: feedbackMessages.length,
                errors: totalErrors,
                warnings: totalWarnings,
                info: totalInfo,
                valid: totalErrors === 0
            },
            messages: feedbackMessages,
            recommendations: generateRecommendations().split("\n").filter(r => r.length > 0)
        }, null, 2)
    }
    
    // Common validation feedback templates
    property var templates: QtObject {
        // Type errors
        function wrongType(path, expected, actual) {
            return {
                message: `Expected ${expected} but got ${actual}`,
                suggestion: `Change the value to a valid ${expected}`
            }
        }
        
        // Range errors
        function outOfRange(path, value, min, max) {
            return {
                message: `Value ${value} is out of range [${min}, ${max}]`,
                suggestion: `Set a value between ${min} and ${max}`
            }
        }
        
        // Missing required field
        function missingRequired(path) {
            return {
                message: "Required field is missing",
                suggestion: "Add this field to your configuration"
            }
        }
        
        // Invalid enum value
        function invalidEnum(path, value, validValues) {
            return {
                message: `Invalid value "${value}"`,
                suggestion: `Use one of: ${validValues.join(", ")}`
            }
        }
        
        // Deprecated field
        function deprecated(path, alternative) {
            return {
                message: "This field is deprecated",
                suggestion: alternative ? `Use "${alternative}" instead` : "Remove this field"
            }
        }
        
        // Performance warning
        function performanceImpact(path, issue) {
            return {
                message: `This setting may cause ${issue}`,
                suggestion: "Consider adjusting this value for better performance"
            }
        }
        
        // Conflict warning
        function conflict(path, conflictsWith) {
            return {
                message: `Conflicts with ${conflictsWith}`,
                suggestion: "Only one of these settings should be enabled"
            }
        }
    }
}