pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root
    
    // Main conversion function
    function convert(value, targetType) {
        if (value === null || value === undefined) {
            console.log(`[TypeConverter] Cannot convert null/undefined to ${targetType}`)
            return value
        }
        
        const sourceType = typeof value
        console.log(`[TypeConverter] Converting ${sourceType} to ${targetType}: ${JSON.stringify(value)}`)
        
        switch (targetType.toLowerCase()) {
            case 'boolean':
            case 'bool':
                return toBoolean(value)
            
            case 'number':
            case 'int':
            case 'integer':
            case 'double':
            case 'real':
                return toNumber(value)
            
            case 'string':
                return toString(value)
            
            case 'color':
                return toColor(value)
            
            case 'date':
                return toDate(value)
            
            case 'url':
                return toUrl(value)
            
            case 'size':
                return toSize(value)
            
            case 'point':
                return toPoint(value)
            
            case 'rect':
                return toRect(value)
            
            case 'font':
                return toFont(value)
            
            default:
                console.warn(`[TypeConverter] Unknown target type: ${targetType}`)
                return value
        }
    }
    
    // Convert to boolean
    function toBoolean(value) {
        if (typeof value === 'boolean') return value
        
        if (typeof value === 'string') {
            const lower = value.toLowerCase().trim()
            
            // True values
            if (['true', 'yes', 'on', '1', 'enabled', 'active'].includes(lower)) {
                return true
            }
            
            // False values
            if (['false', 'no', 'off', '0', 'disabled', 'inactive'].includes(lower)) {
                return false
            }
            
            console.warn(`[TypeConverter] Cannot convert string "${value}" to boolean`)
            return false
        }
        
        if (typeof value === 'number') {
            return value !== 0
        }
        
        // Objects and arrays are truthy
        return !!value
    }
    
    // Convert to number
    function toNumber(value) {
        if (typeof value === 'number') return value
        
        if (typeof value === 'string') {
            const trimmed = value.trim()
            
            // Handle empty string
            if (trimmed === '') return 0
            
            // Handle hex numbers
            if (trimmed.startsWith('0x') || trimmed.startsWith('0X')) {
                const hex = parseInt(trimmed, 16)
                if (!isNaN(hex)) return hex
            }
            
            // Handle percentages
            if (trimmed.endsWith('%')) {
                const percent = parseFloat(trimmed.slice(0, -1))
                if (!isNaN(percent)) return percent / 100
            }
            
            // Handle regular numbers
            const num = parseFloat(trimmed)
            if (!isNaN(num)) return num
            
            console.warn(`[TypeConverter] Cannot convert string "${value}" to number`)
            return 0
        }
        
        if (typeof value === 'boolean') {
            return value ? 1 : 0
        }
        
        console.warn(`[TypeConverter] Cannot convert ${typeof value} to number`)
        return 0
    }
    
    // Convert to string
    function toString(value) {
        if (typeof value === 'string') return value
        
        if (value === null) return 'null'
        if (value === undefined) return 'undefined'
        
        if (typeof value === 'object') {
            try {
                return JSON.stringify(value)
            } catch (error) {
                return value.toString()
            }
        }
        
        return String(value)
    }
    
    // Convert to Qt color
    function toColor(value) {
        if (typeof value === 'string') {
            const trimmed = value.trim()
            
            // Handle hex colors
            if (trimmed.startsWith('#')) {
                return trimmed
            }
            
            // Handle rgb/rgba
            if (trimmed.startsWith('rgb')) {
                return trimmed
            }
            
            // Handle named colors
            const namedColors = [
                'black', 'white', 'red', 'green', 'blue', 'yellow', 
                'cyan', 'magenta', 'gray', 'grey', 'transparent'
            ]
            if (namedColors.includes(trimmed.toLowerCase())) {
                return trimmed
            }
            
            // Try to parse as Qt color
            try {
                return Qt.color(trimmed)
            } catch (error) {
                console.warn(`[TypeConverter] Cannot convert "${value}" to color`)
                return 'transparent'
            }
        }
        
        if (typeof value === 'object') {
            // Handle color object {r: 255, g: 255, b: 255, a: 1.0}
            if ('r' in value && 'g' in value && 'b' in value) {
                const r = Math.max(0, Math.min(255, value.r))
                const g = Math.max(0, Math.min(255, value.g))
                const b = Math.max(0, Math.min(255, value.b))
                const a = value.a !== undefined ? Math.max(0, Math.min(1, value.a)) : 1
                
                if (a < 1) {
                    return `rgba(${r}, ${g}, ${b}, ${a})`
                } else {
                    return `rgb(${r}, ${g}, ${b})`
                }
            }
        }
        
        console.warn(`[TypeConverter] Cannot convert ${typeof value} to color`)
        return 'transparent'
    }
    
    // Convert to Date
    function toDate(value) {
        if (value instanceof Date) return value
        
        if (typeof value === 'string') {
            const date = new Date(value)
            if (!isNaN(date.getTime())) {
                return date
            }
        }
        
        if (typeof value === 'number') {
            return new Date(value)
        }
        
        console.warn(`[TypeConverter] Cannot convert ${typeof value} to date`)
        return new Date()
    }
    
    // Convert to URL
    function toUrl(value) {
        if (typeof value === 'string') {
            // Handle file paths
            if (value.startsWith('/') || value.startsWith('~/')) {
                return 'file://' + value.replace('~', Quickshell.env("HOME"))
            }
            
            // Handle URLs
            if (value.includes('://')) {
                return value
            }
            
            // Assume relative path
            return 'file://' + value
        }
        
        console.warn(`[TypeConverter] Cannot convert ${typeof value} to URL`)
        return ''
    }
    
    // Convert to Qt size
    function toSize(value) {
        if (typeof value === 'object' && value !== null) {
            if ('width' in value && 'height' in value) {
                return Qt.size(toNumber(value.width), toNumber(value.height))
            }
        }
        
        if (typeof value === 'string') {
            const parts = value.split(/[x,\s]+/)
            if (parts.length === 2) {
                return Qt.size(toNumber(parts[0]), toNumber(parts[1]))
            }
        }
        
        if (typeof value === 'number') {
            return Qt.size(value, value)
        }
        
        console.warn(`[TypeConverter] Cannot convert ${typeof value} to size`)
        return Qt.size(0, 0)
    }
    
    // Convert to Qt point
    function toPoint(value) {
        if (typeof value === 'object' && value !== null) {
            if ('x' in value && 'y' in value) {
                return Qt.point(toNumber(value.x), toNumber(value.y))
            }
        }
        
        if (typeof value === 'string') {
            const parts = value.split(/[,\s]+/)
            if (parts.length === 2) {
                return Qt.point(toNumber(parts[0]), toNumber(parts[1]))
            }
        }
        
        if (typeof value === 'number') {
            return Qt.point(value, value)
        }
        
        console.warn(`[TypeConverter] Cannot convert ${typeof value} to point`)
        return Qt.point(0, 0)
    }
    
    // Convert to Qt rect
    function toRect(value) {
        if (typeof value === 'object' && value !== null) {
            const x = toNumber(value.x || 0)
            const y = toNumber(value.y || 0)
            const width = toNumber(value.width || value.w || 0)
            const height = toNumber(value.height || value.h || 0)
            return Qt.rect(x, y, width, height)
        }
        
        if (typeof value === 'string') {
            const parts = value.split(/[,\s]+/)
            if (parts.length === 4) {
                return Qt.rect(
                    toNumber(parts[0]),
                    toNumber(parts[1]),
                    toNumber(parts[2]),
                    toNumber(parts[3])
                )
            }
        }
        
        console.warn(`[TypeConverter] Cannot convert ${typeof value} to rect`)
        return Qt.rect(0, 0, 0, 0)
    }
    
    // Convert to font
    function toFont(value) {
        if (typeof value === 'string') {
            // Simple font name
            return { family: value }
        }
        
        if (typeof value === 'object' && value !== null) {
            const font = {}
            
            if ('family' in value) font.family = toString(value.family)
            if ('size' in value) font.pixelSize = toNumber(value.size)
            if ('pixelSize' in value) font.pixelSize = toNumber(value.pixelSize)
            if ('pointSize' in value) font.pointSize = toNumber(value.pointSize)
            if ('weight' in value) font.weight = toFontWeight(value.weight)
            if ('bold' in value) font.bold = toBoolean(value.bold)
            if ('italic' in value) font.italic = toBoolean(value.italic)
            if ('underline' in value) font.underline = toBoolean(value.underline)
            if ('strikeout' in value) font.strikeout = toBoolean(value.strikeout)
            if ('letterSpacing' in value) font.letterSpacing = toNumber(value.letterSpacing)
            if ('wordSpacing' in value) font.wordSpacing = toNumber(value.wordSpacing)
            
            return font
        }
        
        console.warn(`[TypeConverter] Cannot convert ${typeof value} to font`)
        return {}
    }
    
    // Convert to font weight
    function toFontWeight(value) {
        if (typeof value === 'number') return value
        
        if (typeof value === 'string') {
            const weights = {
                'thin': 100,
                'extralight': 200,
                'light': 300,
                'normal': 400,
                'regular': 400,
                'medium': 500,
                'semibold': 600,
                'bold': 700,
                'extrabold': 800,
                'black': 900
            }
            
            const lower = value.toLowerCase()
            if (lower in weights) {
                return weights[lower]
            }
            
            // Try to parse as number
            const num = toNumber(value)
            if (num >= 100 && num <= 900) {
                return num
            }
        }
        
        return 400 // Normal weight
    }
    
    // Batch conversion for objects
    function convertObject(obj, schema) {
        if (!obj || !schema) return obj
        
        const result = {}
        
        for (let key in obj) {
            if (obj.hasOwnProperty(key)) {
                if (schema[key] && schema[key].type) {
                    result[key] = convert(obj[key], schema[key].type)
                } else {
                    result[key] = obj[key]
                }
            }
        }
        
        return result
    }
    
    // Type detection
    function detectType(value) {
        if (value === null) return 'null'
        if (value === undefined) return 'undefined'
        
        const type = typeof value
        
        if (type === 'string') {
            // Try to detect specific string types
            if (/^#[0-9A-Fa-f]{3,8}$/.test(value) || /^rgba?\(/.test(value)) {
                return 'color'
            }
            if (/^\d{4}-\d{2}-\d{2}/.test(value)) {
                return 'date'
            }
            if (/^(https?|file|qrc):\/\//.test(value)) {
                return 'url'
            }
        }
        
        if (type === 'object') {
            if (value instanceof Date) return 'date'
            if (Array.isArray(value)) return 'array'
            
            // Check for specific object shapes
            if ('r' in value && 'g' in value && 'b' in value) return 'color'
            if ('width' in value && 'height' in value) return 'size'
            if ('x' in value && 'y' in value) return 'point'
            if ('family' in value || 'pixelSize' in value) return 'font'
        }
        
        return type
    }
    
    Component.onCompleted: {
        console.log("[TypeConverter] Initialized")
    }
}