# Heimdall External Configuration System Plan

## Context

### Problem Statement
The current QuickShell configuration system faces a critical limitation when attempting to use external configuration files with nested objects. The error "Cannot assign QJSValue to QQmlPropertyMap*" prevents proper assignment of nested configuration structures, blocking the implementation of a flexible external configuration system.

### Current State
- Configuration is hardcoded within QML files
- No support for external configuration files (JSON/YAML)
- Cannot dynamically assign nested objects to QML properties
- Hot-reload is limited to QML file changes only
- No centralized configuration management

### Goals
1. Enable external configuration files (JSON/YAML) for QuickShell
2. Support deeply nested configuration structures
3. Implement intelligent hot-reload for configuration changes
4. Maintain type safety and validation
5. Provide seamless migration path from hardcoded values
6. Enable configuration inheritance and overrides

### Constraints
- Must work within QML/Qt property system limitations
- Cannot modify Qt's core QJSValue behavior
- Must maintain backward compatibility
- Performance impact must be minimal
- Hot-reload must be selective and efficient

## Specification

### Functional Requirements
1. **External Configuration Loading**
   - Load JSON configuration files from `~/.config/quickshell/config.json`
   - Support YAML as alternative format
   - Handle missing files gracefully with defaults

2. **Nested Object Support**
   - Recursively assign properties at any depth
   - Support arrays, objects, and primitive types
   - Handle type conversions automatically

3. **Hot-Reload Capabilities**
   - Monitor configuration file changes
   - Reload only affected components
   - Preserve application state during reload
   - Provide reload notifications

4. **Type Safety**
   - Validate configuration against schema
   - Provide meaningful error messages
   - Support type coercion where appropriate

### Non-Functional Requirements
- Configuration parsing < 100ms
- Hot-reload response < 500ms
- Memory overhead < 10MB
- Zero runtime performance impact after initial load

### Interfaces
- `Config` singleton for accessing configuration
- `ConfigPropertyAssigner` for recursive assignment
- `HotReloadManager` for change detection
- `TypeConverter` for type transformations

## Implementation Plan

### Phase 1: Core Infrastructure
- [x] Create ConfigPropertyAssigner component
  - Implement recursive property assignment
  - Handle QJSValue to QML property conversion
  - Support all primitive and complex types
  
- [ ] Implement TypeConverter utility
  - Type detection and validation
  - Automatic conversions
  - Error handling for invalid types

- [ ] Build configuration loader
  - JSON parsing
  - Schema validation
  - Default value merging

#### ConfigPropertyAssigner.qml
```qml
import QtQuick 2.15

QtObject {
    id: root
    
    // Recursively assign properties from source to target
    function assignProperties(target, source, path = "") {
        if (!source || typeof source !== 'object') {
            console.warn(`Invalid source at path: ${path}`)
            return false
        }
        
        const keys = Object.keys(source)
        let success = true
        
        for (const key of keys) {
            const value = source[key]
            const currentPath = path ? `${path}.${key}` : key
            
            try {
                if (value === null || value === undefined) {
                    // Skip null/undefined values
                    continue
                }
                
                if (typeof value === 'object' && !Array.isArray(value)) {
                    // Handle nested objects
                    if (!target[key]) {
                        // Create nested property map if it doesn't exist
                        target[key] = Qt.createQmlObject(
                            'import QtQuick 2.15; QtObject {}',
                            target,
                            `DynamicObject_${key}`
                        )
                    }
                    
                    // Recursively assign nested properties
                    success = assignProperties(target[key], value, currentPath) && success
                } else if (Array.isArray(value)) {
                    // Handle arrays
                    target[key] = processArray(value, currentPath)
                } else {
                    // Handle primitive values
                    assignPrimitive(target, key, value, currentPath)
                }
            } catch (error) {
                console.error(`Failed to assign ${currentPath}: ${error}`)
                success = false
            }
        }
        
        return success
    }
    
    function assignPrimitive(target, key, value, path) {
        // Direct assignment for primitives
        if (target.hasOwnProperty(key)) {
            const currentType = typeof target[key]
            const newType = typeof value
            
            if (currentType !== newType) {
                // Attempt type conversion
                target[key] = convertType(value, currentType)
            } else {
                target[key] = value
            }
        } else {
            // Create new property
            target[key] = value
        }
    }
    
    function processArray(array, path) {
        // Convert array elements if needed
        return array.map((item, index) => {
            if (typeof item === 'object' && !Array.isArray(item)) {
                const obj = Qt.createQmlObject(
                    'import QtQuick 2.15; QtObject {}',
                    root,
                    `ArrayObject_${path}_${index}`
                )
                assignProperties(obj, item, `${path}[${index}]`)
                return obj
            }
            return item
        })
    }
    
    function convertType(value, targetType) {
        switch (targetType) {
            case 'number':
                return Number(value)
            case 'string':
                return String(value)
            case 'boolean':
                return Boolean(value)
            default:
                return value
        }
    }
}
```

### Phase 2: Configuration Management
- [ ] Create enhanced Config singleton
  - Load external configuration
  - Merge with defaults
  - Expose nested properties
  
- [ ] Implement configuration schema
  - Define expected structure
  - Validation rules
  - Type specifications

- [ ] Build default configuration
  - Complete default values
  - Documentation for each option
  - Migration mappings

#### Enhanced Config.qml
```qml
import QtQuick 2.15
import Qt.labs.platform 1.1

QtObject {
    id: root
    
    // Configuration properties
    property var launcher: QtObject {
        property int width: 800
        property int height: 600
        property var sizes: QtObject {
            property int itemHeight: 48
            property int itemPadding: 12
            property int iconSize: 24
        }
        property var colors: QtObject {
            property string background: "#1e1e2e"
            property string foreground: "#cdd6f4"
            property string accent: "#89b4fa"
        }
    }
    
    property var appearance: QtObject {
        property var font: QtObject {
            property var family: QtObject {
                property string sans: "Inter"
                property string mono: "JetBrains Mono"
            }
            property var sizes: QtObject {
                property int small: 12
                property int medium: 14
                property int large: 16
            }
        }
        property var animations: QtObject {
            property int duration: 200
            property string easing: "OutCubic"
        }
    }
    
    property var shell: QtObject {
        property var bar: QtObject {
            property int height: 32
            property string position: "top"
            property bool autoHide: false
        }
        property var workspaces: QtObject {
            property int count: 10
            property bool dynamicCreate: true
        }
    }
    
    // Internal components
    property var _loader: ConfigLoader {
        id: configLoader
        configPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation) 
                    + "/quickshell/config.json"
        onConfigLoaded: {
            propertyAssigner.assignProperties(root, config, "Config")
            console.log("Configuration loaded successfully")
        }
        onError: {
            console.error("Failed to load configuration:", message)
            loadDefaults()
        }
    }
    
    property var _assigner: ConfigPropertyAssigner {
        id: propertyAssigner
    }
    
    property var _hotReload: HotReloadManager {
        id: hotReloadManager
        watchPath: configLoader.configPath
        target: root
        enabled: true
    }
    
    // Public methods
    function reload() {
        configLoader.load()
    }
    
    function save() {
        configLoader.save(extractProperties())
    }
    
    function reset() {
        loadDefaults()
    }
    
    function get(path) {
        const parts = path.split('.')
        let current = root
        
        for (const part of parts) {
            if (current && current[part] !== undefined) {
                current = current[part]
            } else {
                return undefined
            }
        }
        
        return current
    }
    
    function set(path, value) {
        const parts = path.split('.')
        const key = parts.pop()
        let current = root
        
        for (const part of parts) {
            if (!current[part]) {
                current[part] = Qt.createQmlObject(
                    'import QtQuick 2.15; QtObject {}',
                    current,
                    `Dynamic_${part}`
                )
            }
            current = current[part]
        }
        
        current[key] = value
        hotReloadManager.notifyChange(path, value)
    }
    
    // Initialize on creation
    Component.onCompleted: {
        configLoader.load()
    }
}
```

### Phase 3: Type System and Validation
- [ ] Implement TypeConverter component
  - Color string to QColor
  - Number string to int/real
  - Enum string validation
  - Array type checking

- [ ] Create schema validator
  - JSON Schema support
  - Custom validation rules
  - Error reporting

- [ ] Build configuration migrator
  - Version detection
  - Automatic upgrades
  - Deprecation warnings

#### TypeConverter.qml
```qml
import QtQuick 2.15

QtObject {
    id: root
    
    // Type detection
    function detectType(value) {
        if (value === null || value === undefined) return 'null'
        if (Array.isArray(value)) return 'array'
        if (value instanceof Date) return 'date'
        if (typeof value === 'object') return 'object'
        return typeof value
    }
    
    // Convert value to target type
    function convert(value, targetType) {
        const sourceType = detectType(value)
        
        if (sourceType === targetType) {
            return value
        }
        
        switch (targetType) {
            case 'color':
                return toColor(value)
            case 'font':
                return toFont(value)
            case 'size':
                return toSize(value)
            case 'point':
                return toPoint(value)
            case 'rect':
                return toRect(value)
            case 'url':
                return toUrl(value)
            case 'date':
                return toDate(value)
            case 'enum':
                return toEnum(value)
            default:
                return basicConvert(value, targetType)
        }
    }
    
    function toColor(value) {
        if (typeof value === 'string') {
            // Handle hex colors, named colors, etc.
            return Qt.color(value)
        } else if (typeof value === 'object') {
            // Handle RGB/RGBA objects
            return Qt.rgba(
                value.r || 0,
                value.g || 0,
                value.b || 0,
                value.a !== undefined ? value.a : 1
            )
        }
        return Qt.color("transparent")
    }
    
    function toFont(value) {
        if (typeof value === 'string') {
            return Qt.font({ family: value })
        } else if (typeof value === 'object') {
            return Qt.font({
                family: value.family || "sans-serif",
                pixelSize: value.size || 14,
                bold: value.bold || false,
                italic: value.italic || false,
                weight: value.weight || Font.Normal
            })
        }
        return Qt.font({})
    }
    
    function toSize(value) {
        if (typeof value === 'number') {
            return Qt.size(value, value)
        } else if (typeof value === 'object') {
            return Qt.size(value.width || 0, value.height || 0)
        } else if (typeof value === 'string') {
            const parts = value.split('x')
            if (parts.length === 2) {
                return Qt.size(parseInt(parts[0]), parseInt(parts[1]))
            }
        }
        return Qt.size(0, 0)
    }
    
    function toPoint(value) {
        if (typeof value === 'object') {
            return Qt.point(value.x || 0, value.y || 0)
        } else if (typeof value === 'string') {
            const parts = value.split(',')
            if (parts.length === 2) {
                return Qt.point(parseInt(parts[0]), parseInt(parts[1]))
            }
        }
        return Qt.point(0, 0)
    }
    
    function toRect(value) {
        if (typeof value === 'object') {
            return Qt.rect(
                value.x || 0,
                value.y || 0,
                value.width || 0,
                value.height || 0
            )
        }
        return Qt.rect(0, 0, 0, 0)
    }
    
    function toUrl(value) {
        if (typeof value === 'string') {
            if (value.startsWith('file://') || value.startsWith('http')) {
                return Qt.url(value)
            } else {
                // Assume file path
                return Qt.url('file://' + value)
            }
        }
        return Qt.url('')
    }
    
    function toDate(value) {
        if (typeof value === 'string') {
            return new Date(value)
        } else if (typeof value === 'number') {
            return new Date(value)
        }
        return new Date()
    }
    
    function toEnum(value, enumType) {
        // Validate against known enum values
        // This would need to be extended with actual enum definitions
        return value
    }
    
    function basicConvert(value, targetType) {
        switch (targetType) {
            case 'string':
                return String(value)
            case 'number':
                return Number(value)
            case 'boolean':
                return Boolean(value)
            case 'int':
                return parseInt(value)
            case 'real':
                return parseFloat(value)
            default:
                return value
        }
    }
    
    // Validate value against type
    function validate(value, type, constraints = {}) {
        const actualType = detectType(value)
        
        // Type check
        if (type && actualType !== type) {
            // Try conversion
            try {
                const converted = convert(value, type)
                value = converted
            } catch (e) {
                return {
                    valid: false,
                    error: `Type mismatch: expected ${type}, got ${actualType}`
                }
            }
        }
        
        // Apply constraints
        if (constraints.min !== undefined && value < constraints.min) {
            return {
                valid: false,
                error: `Value ${value} is below minimum ${constraints.min}`
            }
        }
        
        if (constraints.max !== undefined && value > constraints.max) {
            return {
                valid: false,
                error: `Value ${value} exceeds maximum ${constraints.max}`
            }
        }
        
        if (constraints.pattern && !new RegExp(constraints.pattern).test(value)) {
            return {
                valid: false,
                error: `Value ${value} doesn't match pattern ${constraints.pattern}`
            }
        }
        
        if (constraints.enum && !constraints.enum.includes(value)) {
            return {
                valid: false,
                error: `Value ${value} not in allowed values: ${constraints.enum.join(', ')}`
            }
        }
        
        return { valid: true, value: value }
    }
}
```

### Phase 4: Hot-Reload System
- [ ] Implement HotReloadManager
  - File system monitoring
  - Change detection
  - Selective component reload
  - State preservation

- [ ] Create reload strategies
  - Full reload for structural changes
  - Partial reload for value changes
  - No reload for comments/formatting

- [ ] Build notification system
  - User notifications
  - Developer console output
  - Reload status indicators

#### HotReloadManager.qml
```qml
import QtQuick 2.15
import Qt.labs.platform 1.1

QtObject {
    id: root
    
    // Properties
    property string watchPath: ""
    property var target: null
    property bool enabled: true
    property int debounceDelay: 500
    property var reloadStrategy: "smart" // "smart", "full", "partial"
    
    // Signals
    signal reloadStarted()
    signal reloadCompleted()
    signal reloadFailed(string error)
    signal configChanged(string path, var oldValue, var newValue)
    
    // Internal state
    property var _watcher: FileSystemWatcher {
        id: watcher
        paths: [root.watchPath]
        
        onFileChanged: {
            if (root.enabled) {
                debounceTimer.restart()
            }
        }
    }
    
    property var _debounceTimer: Timer {
        id: debounceTimer
        interval: root.debounceDelay
        repeat: false
        onTriggered: performReload()
    }
    
    property var _previousConfig: ({})
    property var _affectedComponents: []
    property var _stateCache: ({})
    
    // Methods
    function performReload() {
        console.log("Hot-reload triggered for:", watchPath)
        reloadStarted()
        
        try {
            // Load new configuration
            const newConfig = loadConfiguration()
            
            if (reloadStrategy === "smart") {
                performSmartReload(newConfig)
            } else if (reloadStrategy === "partial") {
                performPartialReload(newConfig)
            } else {
                performFullReload(newConfig)
            }
            
            _previousConfig = newConfig
            reloadCompleted()
            
        } catch (error) {
            console.error("Hot-reload failed:", error)
            reloadFailed(error.toString())
        }
    }
    
    function performSmartReload(newConfig) {
        // Detect what changed
        const changes = detectChanges(_previousConfig, newConfig)
        
        if (changes.length === 0) {
            console.log("No changes detected")
            return
        }
        
        console.log(`Detected ${changes.length} changes`)
        
        // Categorize changes
        const categories = categorizeChanges(changes)
        
        // Apply changes based on category
        if (categories.structural.length > 0) {
            // Structural changes require full reload
            console.log("Structural changes detected, performing full reload")
            performFullReload(newConfig)
        } else if (categories.visual.length > 0) {
            // Visual changes can be applied immediately
            applyVisualChanges(categories.visual, newConfig)
            
            if (categories.behavioral.length > 0) {
                // Behavioral changes need component reload
                reloadAffectedComponents(categories.behavioral, newConfig)
            }
        } else if (categories.behavioral.length > 0) {
            // Only behavioral changes
            reloadAffectedComponents(categories.behavioral, newConfig)
        } else {
            // Only data changes
            applyDataChanges(categories.data, newConfig)
        }
    }
    
    function detectChanges(oldConfig, newConfig, path = "") {
        const changes = []
        
        // Check all keys in new config
        for (const key in newConfig) {
            const currentPath = path ? `${path}.${key}` : key
            const oldValue = oldConfig[key]
            const newValue = newConfig[key]
            
            if (typeof newValue === 'object' && !Array.isArray(newValue)) {
                // Recurse into nested objects
                if (typeof oldValue === 'object') {
                    changes.push(...detectChanges(oldValue, newValue, currentPath))
                } else {
                    // Type changed to object
                    changes.push({
                        path: currentPath,
                        type: 'structural',
                        oldValue: oldValue,
                        newValue: newValue
                    })
                }
            } else if (JSON.stringify(oldValue) !== JSON.stringify(newValue)) {
                // Value changed
                changes.push({
                    path: currentPath,
                    type: inferChangeType(currentPath, oldValue, newValue),
                    oldValue: oldValue,
                    newValue: newValue
                })
            }
        }
        
        // Check for removed keys
        for (const key in oldConfig) {
            if (!(key in newConfig)) {
                const currentPath = path ? `${path}.${key}` : key
                changes.push({
                    path: currentPath,
                    type: 'structural',
                    oldValue: oldConfig[key],
                    newValue: undefined
                })
            }
        }
        
        return changes
    }
    
    function inferChangeType(path, oldValue, newValue) {
        // Infer change type based on path and values
        if (path.includes('color') || path.includes('Color')) {
            return 'visual'
        }
        if (path.includes('font') || path.includes('Font')) {
            return 'visual'
        }
        if (path.includes('size') || path.includes('Size') || 
            path.includes('width') || path.includes('height')) {
            return 'visual'
        }
        if (path.includes('animation') || path.includes('duration')) {
            return 'visual'
        }
        if (path.includes('enabled') || path.includes('visible')) {
            return 'behavioral'
        }
        if (path.includes('command') || path.includes('action')) {
            return 'behavioral'
        }
        
        // Default to data change
        return 'data'
    }
    
    function categorizeChanges(changes) {
        return {
            structural: changes.filter(c => c.type === 'structural'),
            visual: changes.filter(c => c.type === 'visual'),
            behavioral: changes.filter(c => c.type === 'behavioral'),
            data: changes.filter(c => c.type === 'data')
        }
    }
    
    function applyVisualChanges(changes, newConfig) {
        console.log("Applying visual changes...")
        
        for (const change of changes) {
            try {
                // Apply change to target
                setNestedProperty(target, change.path, change.newValue)
                
                // Emit change signal
                configChanged(change.path, change.oldValue, change.newValue)
                
                console.log(`Updated ${change.path}: ${change.oldValue} → ${change.newValue}`)
            } catch (error) {
                console.error(`Failed to apply visual change to ${change.path}:`, error)
            }
        }
    }
    
    function applyDataChanges(changes, newConfig) {
        console.log("Applying data changes...")
        
        for (const change of changes) {
            try {
                setNestedProperty(target, change.path, change.newValue)
                configChanged(change.path, change.oldValue, change.newValue)
                console.log(`Updated ${change.path}`)
            } catch (error) {
                console.error(`Failed to apply data change to ${change.path}:`, error)
            }
        }
    }
    
    function reloadAffectedComponents(changes, newConfig) {
        console.log("Reloading affected components...")
        
        // Find components affected by changes
        const affectedPaths = changes.map(c => c.path)
        const components = findAffectedComponents(affectedPaths)
        
        // Save component state
        const savedStates = {}
        for (const comp of components) {
            savedStates[comp.objectName] = saveComponentState(comp)
        }
        
        // Apply changes
        for (const change of changes) {
            setNestedProperty(target, change.path, change.newValue)
            configChanged(change.path, change.oldValue, change.newValue)
        }
        
        // Restore component state
        for (const comp of components) {
            restoreComponentState(comp, savedStates[comp.objectName])
        }
        
        console.log(`Reloaded ${components.length} components`)
    }
    
    function performPartialReload(newConfig) {
        console.log("Performing partial reload...")
        
        // Save current state
        const state = saveApplicationState()
        
        // Apply all changes
        const assigner = Qt.createQmlObject(
            'import "." as Local; Local.ConfigPropertyAssigner {}',
            root,
            'TempAssigner'
        )
        assigner.assignProperties(target, newConfig, "Config")
        assigner.destroy()
        
        // Restore state
        restoreApplicationState(state)
    }
    
    function performFullReload(newConfig) {
        console.log("Performing full reload...")
        
        // This would trigger a complete application reload
        // Implementation depends on application architecture
        target.reload()
    }
    
    function setNestedProperty(obj, path, value) {
        const parts = path.split('.')
        const key = parts.pop()
        
        let current = obj
        for (const part of parts) {
            if (!current[part]) {
                throw new Error(`Path not found: ${part} in ${path}`)
            }
            current = current[part]
        }
        
        current[key] = value
    }
    
    function loadConfiguration() {
        // Load and parse configuration file
        const file = Qt.createQmlObject(
            'import Qt.labs.platform 1.1; File {}',
            root,
            'TempFile'
        )
        file.source = watchPath
        
        if (!file.open(File.ReadOnly)) {
            throw new Error("Failed to open configuration file")
        }
        
        const content = file.readAll()
        file.close()
        file.destroy()
        
        try {
            return JSON.parse(content)
        } catch (error) {
            throw new Error("Invalid JSON in configuration file: " + error)
        }
    }
    
    function findAffectedComponents(paths) {
        // This would need to be implemented based on your component structure
        // For now, return empty array
        return []
    }
    
    function saveComponentState(component) {
        // Save relevant component state
        return {
            // Add state properties as needed
        }
    }
    
    function restoreComponentState(component, state) {
        // Restore component state
        if (!state) return
        
        // Apply saved state properties
    }
    
    function saveApplicationState() {
        return {
            // Save global application state
        }
    }
    
    function restoreApplicationState(state) {
        // Restore global application state
    }
    
    // Public API
    function notifyChange(path, value) {
        // Called when configuration is changed programmatically
        configChanged(path, getNestedProperty(_previousConfig, path), value)
    }
    
    function getNestedProperty(obj, path) {
        const parts = path.split('.')
        let current = obj
        
        for (const part of parts) {
            if (current && current[part] !== undefined) {
                current = current[part]
            } else {
                return undefined
            }
        }
        
        return current
    }
    
    Component.onCompleted: {
        if (watchPath && enabled) {
            console.log("Hot-reload manager initialized for:", watchPath)
            _previousConfig = loadConfiguration()
        }
    }
}
```

## Testing Strategy

### Unit Tests
1. **ConfigPropertyAssigner Tests**
   - Test recursive assignment with deeply nested objects
   - Test array handling
   - Test type conversion
   - Test error handling for invalid structures

2. **TypeConverter Tests**
   - Test all type conversions
   - Test validation rules
   - Test constraint checking
   - Test error cases

3. **HotReloadManager Tests**
   - Test change detection algorithm
   - Test categorization logic
   - Test reload strategies
   - Test state preservation

### Integration Tests
1. **Configuration Loading**
   - Test JSON parsing
   - Test YAML parsing
   - Test schema validation
   - Test default merging

2. **Hot-Reload Flow**
   - Test file change detection
   - Test debouncing
   - Test selective reload
   - Test error recovery

3. **End-to-End Scenarios**
   - Test complete configuration workflow
   - Test migration from hardcoded values
   - Test complex nested structures
   - Test performance under load

### Test Configuration Examples
```json
{
  "launcher": {
    "width": 800,
    "height": 600,
    "sizes": {
      "itemHeight": 48,
      "itemPadding": 12,
      "iconSize": 24
    },
    "colors": {
      "background": "#1e1e2e",
      "foreground": "#cdd6f4",
      "accent": "#89b4fa"
    }
  },
  "appearance": {
    "font": {
      "family": {
        "sans": "Inter",
        "mono": "JetBrains Mono"
      },
      "sizes": {
        "small": 12,
        "medium": 14,
        "large": 16
      }
    },
    "animations": {
      "duration": 200,
      "easing": "OutCubic"
    }
  },
  "shell": {
    "bar": {
      "height": 32,
      "position": "top",
      "autoHide": false
    },
    "workspaces": {
      "count": 10,
      "dynamicCreate": true
    }
  }
}
```

## Migration Path

### Phase 1: Preparation (Week 1)
1. Audit existing hardcoded configuration
2. Create configuration schema
3. Generate default configuration file
4. Document all configuration options

### Phase 2: Implementation (Week 2-3)
1. Implement ConfigPropertyAssigner
2. Implement TypeConverter
3. Create Config singleton
4. Add basic file loading

### Phase 3: Integration (Week 4)
1. Replace hardcoded values with Config references
2. Test with sample configurations
3. Implement hot-reload system
4. Add validation and error handling

### Phase 4: Rollout (Week 5)
1. Beta testing with power users
2. Documentation and examples
3. Migration tools for existing setups
4. Performance optimization

### Migration Example
```qml
// Before
Rectangle {
    width: 800
    height: 600
    color: "#1e1e2e"
}

// After
Rectangle {
    width: Config.launcher.width
    height: Config.launcher.height
    color: Config.launcher.colors.background
}
```

## Error Handling

### Configuration Errors
1. **Missing File**
   - Use default configuration
   - Create file with defaults
   - Log warning message

2. **Invalid JSON/YAML**
   - Show parse error location
   - Fall back to last valid configuration
   - Notify user with actionable message

3. **Schema Validation Failure**
   - Highlight invalid fields
   - Provide expected format
   - Use defaults for invalid values

4. **Type Conversion Errors**
   - Log detailed error with path
   - Skip invalid property
   - Continue with other properties

### Runtime Errors
1. **Property Assignment Failure**
   - Catch and log error
   - Continue with next property
   - Track failed assignments

2. **Hot-Reload Failure**
   - Maintain current configuration
   - Log error details
   - Retry with exponential backoff

3. **File System Errors**
   - Handle permission issues
   - Deal with file locks
   - Manage disk space issues

## Performance Considerations

### Optimization Strategies
1. **Lazy Loading**
   - Load configuration on demand
   - Cache parsed results
   - Defer nested object creation

2. **Efficient Change Detection**
   - Use checksums for quick comparison
   - Track modification times
   - Implement dirty flags

3. **Selective Updates**
   - Update only changed properties
   - Batch related changes
   - Minimize QML bindings

4. **Memory Management**
   - Release unused configurations
   - Limit history size
   - Use weak references where appropriate

### Performance Targets
- Initial load: < 100ms for 1000 properties
- Hot-reload: < 500ms for full reload
- Change detection: < 50ms
- Memory usage: < 10MB for configuration
- CPU usage: < 1% when idle

### Benchmarking Plan
1. Measure baseline performance
2. Profile configuration loading
3. Analyze hot-reload impact
4. Monitor memory usage
5. Test with large configurations

## Risks and Mitigations

### Technical Risks
1. **QML Property System Limitations**
   - Risk: Cannot handle certain type conversions
   - Mitigation: Implement custom converters, document limitations

2. **Performance Degradation**
   - Risk: Hot-reload causes UI freezes
   - Mitigation: Async loading, debouncing, selective updates

3. **State Loss During Reload**
   - Risk: User loses work during configuration reload
   - Mitigation: State preservation system, confirmation dialogs

### Implementation Risks
1. **Complexity Creep**
   - Risk: System becomes too complex
   - Mitigation: Phased implementation, clear boundaries

2. **Backward Compatibility**
   - Risk: Breaking existing configurations
   - Mitigation: Version detection, migration tools

3. **Testing Coverage**
   - Risk: Edge cases not covered
   - Mitigation: Comprehensive test suite, beta testing

## Success Metrics

### Functional Success
- ✅ External JSON/YAML configuration files work
- ✅ Nested properties accessible via `Config.path.to.property`
- ✅ Hot-reload updates UI without restart
- ✅ All existing features maintain functionality
- ✅ Configuration validation prevents errors

### Performance Success
- ✅ Configuration loads in < 100ms
- ✅ Hot-reload completes in < 500ms
- ✅ No noticeable UI lag during updates
- ✅ Memory usage stays under 10MB
- ✅ CPU usage minimal when idle

### User Experience Success
- ✅ Configuration changes visible immediately
- ✅ Clear error messages for invalid configs
- ✅ Smooth migration from hardcoded values
- ✅ Documentation covers all use cases
- ✅ Community adopts external configuration

### Developer Experience Success
- ✅ Simple API for accessing configuration
- ✅ Easy to add new configuration options
- ✅ Clear debugging information
- ✅ Minimal boilerplate code
- ✅ Type safety maintained

## Dev Log

### Session: Initial Planning
- Created comprehensive implementation plan
- Designed recursive property assignment solution
- Architected hot-reload system
- Defined testing and migration strategies

### Next Steps
1. Create proof-of-concept for ConfigPropertyAssigner
2. Test with sample nested configuration
3. Implement basic hot-reload functionality
4. Validate approach with complex structures
5. Begin phased implementation

## References

### Documentation
- [QML Property System](https://doc.qt.io/qt-6/qtqml-syntax-propertybinding.html)
- [QJSValue Documentation](https://doc.qt.io/qt-6/qjsvalue.html)
- [Qt Property Map](https://doc.qt.io/qt-6/qqmlpropertymap.html)
- [File System Watcher](https://doc.qt.io/qt-6/qfilesystemwatcher.html)

### Related Issues
- QuickShell configuration system discussions
- QML dynamic property limitations
- Hot-reload implementation patterns

### Code Examples
- ConfigPropertyAssigner.qml - Recursive property assignment
- Config.qml - Enhanced configuration singleton
- TypeConverter.qml - Type conversion utilities
- HotReloadManager.qml - Intelligent hot-reload system