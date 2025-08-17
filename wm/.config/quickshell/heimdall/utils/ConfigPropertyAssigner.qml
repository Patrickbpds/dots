pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root
    
    // Main function to recursively assign properties from source to target
    function assignProperties(target, source, path = "") {
        if (!target || !source) {
            console.warn(`[ConfigPropertyAssigner] Invalid target or source at path: ${path}`)
            return false
        }
        
        let success = true
        
        for (let key in source) {
            const fullPath = path ? `${path}.${key}` : key
            
            try {
                // Skip functions and undefined values
                if (typeof source[key] === 'function' || source[key] === undefined) {
                    console.log(`[ConfigPropertyAssigner] Skipping ${fullPath} (function or undefined)`)
                    continue
                }
                
                // Check if property exists in target
                if (!target.hasOwnProperty(key)) {
                    console.warn(`[ConfigPropertyAssigner] Property ${fullPath} does not exist in target`)
                    continue
                }
                
                const sourceValue = source[key]
                const targetValue = target[key]
                const sourceType = getType(sourceValue)
                const targetType = getType(targetValue)
                
                console.log(`[ConfigPropertyAssigner] Processing ${fullPath}: ${sourceType} -> ${targetType}`)
                
                // Handle different types
                if (sourceType === 'array') {
                    success = handleArray(target, source, key, fullPath) && success
                } else if (sourceType === 'object') {
                    // Check if target property is also an object for nested assignment
                    if (targetType === 'object') {
                        // Recursively assign nested properties
                        success = assignProperties(target[key], sourceValue, fullPath) && success
                    } else {
                        // Try direct assignment for non-matching types
                        success = assignValue(target, key, sourceValue, fullPath) && success
                    }
                } else {
                    // Primitive value assignment
                    success = assignValue(target, key, sourceValue, fullPath) && success
                }
                
            } catch (error) {
                console.error(`[ConfigPropertyAssigner] Error assigning ${fullPath}:`, error.toString())
                success = false
            }
        }
        
        return success
    }
    
    // Assign a single value with type checking
    function assignValue(target, key, value, path) {
        try {
            const oldValue = target[key]
            target[key] = value
            
            // Verify the assignment worked
            if (target[key] !== value && !isEquivalent(target[key], value)) {
                console.warn(`[ConfigPropertyAssigner] Assignment verification failed for ${path}`)
                console.warn(`  Expected: ${JSON.stringify(value)}`)
                console.warn(`  Got: ${JSON.stringify(target[key])}`)
                return false
            }
            
            console.log(`[ConfigPropertyAssigner] Successfully assigned ${path}: ${JSON.stringify(oldValue)} -> ${JSON.stringify(value)}`)
            return true
            
        } catch (error) {
            console.error(`[ConfigPropertyAssigner] Failed to assign ${path}:`, error.toString())
            return false
        }
    }
    
    // Handle array properties
    function handleArray(target, source, key, path) {
        try {
            const sourceArray = source[key]
            
            // Check if target property can accept arrays
            if (!Array.isArray(target[key]) && target[key] !== undefined && target[key] !== null) {
                console.warn(`[ConfigPropertyAssigner] Target ${path} is not an array, attempting direct assignment`)
            }
            
            // Create a new array to avoid reference issues
            const newArray = []
            for (let i = 0; i < sourceArray.length; i++) {
                const item = sourceArray[i]
                if (typeof item === 'object' && !Array.isArray(item)) {
                    // Deep copy objects in array
                    newArray.push(deepCopy(item))
                } else {
                    newArray.push(item)
                }
            }
            
            target[key] = newArray
            console.log(`[ConfigPropertyAssigner] Assigned array ${path} with ${newArray.length} items`)
            return true
            
        } catch (error) {
            console.error(`[ConfigPropertyAssigner] Failed to handle array ${path}:`, error.toString())
            return false
        }
    }
    
    // Get the type of a value
    function getType(value) {
        if (value === null) return 'null'
        if (value === undefined) return 'undefined'
        if (Array.isArray(value)) return 'array'
        if (value instanceof Date) return 'date'
        if (typeof value === 'object') return 'object'
        return typeof value
    }
    
    // Check if a value is a plain object (not array, date, etc.)
    function isObject(value) {
        return value !== null && 
               typeof value === 'object' && 
               !Array.isArray(value) && 
               !(value instanceof Date) &&
               !(value instanceof RegExp)
    }
    
    // Deep copy an object
    function deepCopy(obj) {
        if (obj === null || typeof obj !== 'object') return obj
        if (obj instanceof Date) return new Date(obj.getTime())
        if (obj instanceof Array) return obj.map(item => deepCopy(item))
        if (obj instanceof RegExp) return new RegExp(obj)
        
        const clonedObj = {}
        for (let key in obj) {
            if (obj.hasOwnProperty(key)) {
                clonedObj[key] = deepCopy(obj[key])
            }
        }
        return clonedObj
    }
    
    // Check if two values are equivalent (handles objects and arrays)
    function isEquivalent(a, b) {
        // Primitive comparison
        if (a === b) return true
        
        // Type check
        const typeA = getType(a)
        const typeB = getType(b)
        if (typeA !== typeB) return false
        
        // Array comparison
        if (typeA === 'array') {
            if (a.length !== b.length) return false
            for (let i = 0; i < a.length; i++) {
                if (!isEquivalent(a[i], b[i])) return false
            }
            return true
        }
        
        // Object comparison
        if (typeA === 'object') {
            const keysA = Object.keys(a)
            const keysB = Object.keys(b)
            if (keysA.length !== keysB.length) return false
            
            for (let key of keysA) {
                if (!keysB.includes(key)) return false
                if (!isEquivalent(a[key], b[key])) return false
            }
            return true
        }
        
        // Other types
        return a === b
    }
    
    // Validate that a value matches expected type/schema
    function validateValue(value, schema) {
        if (!schema) return true
        
        const valueType = getType(value)
        
        // Check type
        if (schema.type && valueType !== schema.type) {
            console.warn(`[ConfigPropertyAssigner] Type mismatch: expected ${schema.type}, got ${valueType}`)
            return false
        }
        
        // Check enum values
        if (schema.enum && !schema.enum.includes(value)) {
            console.warn(`[ConfigPropertyAssigner] Value not in enum: ${value} not in ${JSON.stringify(schema.enum)}`)
            return false
        }
        
        // Check range for numbers
        if (valueType === 'number') {
            if (schema.min !== undefined && value < schema.min) {
                console.warn(`[ConfigPropertyAssigner] Value below minimum: ${value} < ${schema.min}`)
                return false
            }
            if (schema.max !== undefined && value > schema.max) {
                console.warn(`[ConfigPropertyAssigner] Value above maximum: ${value} > ${schema.max}`)
                return false
            }
        }
        
        // Check string patterns
        if (valueType === 'string' && schema.pattern) {
            const regex = new RegExp(schema.pattern)
            if (!regex.test(value)) {
                console.warn(`[ConfigPropertyAssigner] String doesn't match pattern: ${value} !~ ${schema.pattern}`)
                return false
            }
        }
        
        return true
    }
    
    // Merge two objects recursively (for default values)
    function mergeWithDefaults(source, defaults) {
        if (!defaults) return source
        if (!source) return deepCopy(defaults)
        
        const result = deepCopy(defaults)
        
        for (let key in source) {
            if (source.hasOwnProperty(key)) {
                const sourceValue = source[key]
                const defaultValue = result[key]
                
                if (isObject(sourceValue) && isObject(defaultValue)) {
                    // Recursively merge nested objects
                    result[key] = mergeWithDefaults(sourceValue, defaultValue)
                } else {
                    // Override with source value
                    result[key] = deepCopy(sourceValue)
                }
            }
        }
        
        return result
    }
    
    Component.onCompleted: {
        console.log("[ConfigPropertyAssigner] Initialized")
    }
}