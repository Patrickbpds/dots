# Configuration Style Guide

## Purpose

This document establishes consistent patterns and conventions for the Heimdall quickshell configuration system. All configuration-related code should follow these guidelines to ensure maintainability, clarity, and consistency.

## Naming Conventions

### Property Names

#### General Rules
- Use **camelCase** for all property names
- Be descriptive but concise
- Group related properties using nested objects

#### Examples
```javascript
// ✅ Good
{
  "windowTitle": "My Application",
  "backgroundColor": "#1E1E2E",
  "animation": {
    "duration": 300,
    "easing": "ease-in-out"
  }
}

// ❌ Bad
{
  "window_title": "My Application",  // Don't use snake_case
  "bg": "#1E1E2E",                   // Too abbreviated
  "animDur": 300                     // Unclear abbreviation
}
```

### Module Names
- Use **camelCase** for module names
- Keep names singular unless representing collections
- Match the module's primary purpose

```javascript
{
  "modules": {
    "launcher": {},      // ✅ Good: singular, clear purpose
    "controlCenter": {}, // ✅ Good: camelCase for multi-word
    "notifications": {}, // ✅ Good: plural for collection
    "bars": {}          // ❌ Bad: should be "bar" (single bar config)
  }
}
```

### Color Properties
- Use descriptive names over generic ones
- Include state variants with suffixes
- Group related colors

```javascript
{
  "colors": {
    "primary": "#89B4FA",
    "primaryHover": "#A0C3FB",
    "primaryPressed": "#6D90C8",
    "background": {
      "base": "#1E1E2E",
      "elevated": "#2A2A3A",
      "overlay": "#35354A"
    }
  }
}
```

## Property Organization

### Hierarchical Structure

Organize properties in a logical hierarchy with maximum depth of 4 levels:

```javascript
{
  "modules": {                    // Level 1: Top category
    "launcher": {                 // Level 2: Module
      "appearance": {             // Level 3: Aspect
        "colors": {               // Level 4: Specific settings (max depth)
          "background": "#1E1E2E"
        }
      }
    }
  }
}
```

### Property Grouping

Group related properties together:

```javascript
{
  "launcher": {
    // Visual properties
    "appearance": {
      "theme": "dark",
      "accentColor": "#89B4FA",
      "fontSize": 14
    },
    
    // Behavioral properties
    "behavior": {
      "searchDelay": 300,
      "maxResults": 10,
      "caseSensitive": false
    },
    
    // Layout properties
    "layout": {
      "width": 600,
      "height": 400,
      "position": "center"
    }
  }
}
```

### Standard Property Groups

Use these standard groups across all modules:

1. **appearance**: Visual styling (colors, fonts, themes)
2. **behavior**: Functional behavior (delays, limits, modes)
3. **layout**: Positioning and dimensions
4. **animation**: Animation and transition settings
5. **shortcuts**: Keyboard shortcuts and bindings
6. **advanced**: Power-user settings

## Data Types and Formats

### Colors
- Use uppercase hex codes with # prefix
- 6-digit format preferred (not 3-digit shorthand)

```javascript
{
  "color": "#89B4FA",  // ✅ Good
  "color": "#89b4fa",  // ❌ Bad: lowercase
  "color": "89B4FA",   // ❌ Bad: missing #
  "color": "#89F"      // ❌ Bad: shorthand
}
```

### Durations
- Always in milliseconds
- Use descriptive property names

```javascript
{
  "animation": {
    "durationMs": 300,        // ✅ Good: clear unit
    "fadeInDurationMs": 150,  // ✅ Good: specific
    "duration": 300           // ❌ Bad: ambiguous unit
  }
}
```

### Dimensions
- Include unit in property name when not pixels
- Default to pixels for unnamed units

```javascript
{
  "width": 600,           // Pixels (default)
  "heightRem": 2.5,       // REM units
  "marginPercent": 10,    // Percentage
  "borderWidth": 2        // Pixels (default for borders)
}
```

### Booleans
- Use positive phrasing when possible
- Prefix with "is", "has", "enable" for clarity

```javascript
{
  "isEnabled": true,      // ✅ Good: clear boolean
  "hasAnimation": false,  // ✅ Good: clear state
  "disabled": false,       // ❌ Avoid: negative phrasing
  "animate": true         // ❌ Ambiguous: could be action
}
```

## Configuration Defaults

### Default Value Rules

1. **Always provide sensible defaults**
2. **Document default values**
3. **Make defaults production-ready**

```qml
// In QML configuration
QtObject {
    property int animationDuration: 300  // Default: 300ms
    property string theme: "dark"        // Default: "dark"
    property bool enableEffects: true    // Default: true
}
```

### Override Pattern

```javascript
// External config (scheme.json)
{
  "launcher": {
    "animationDuration": 500  // Overrides default 300
    // theme uses default "dark"
    // enableEffects uses default true
  }
}
```

## Validation Rules

### Required vs Optional

Mark required fields clearly in schema:

```javascript
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["version"],  // Only version is required
  "properties": {
    "version": {
      "type": "string",
      "pattern": "^\\d+\\.\\d+\\.\\d+$"
    },
    "theme": {
      "type": "string",
      "enum": ["light", "dark"],
      "default": "dark"  // Optional with default
    }
  }
}
```

### Value Constraints

Define clear constraints for values:

```javascript
{
  "properties": {
    "opacity": {
      "type": "number",
      "minimum": 0,
      "maximum": 1,
      "default": 1
    },
    "fontSize": {
      "type": "integer",
      "minimum": 8,
      "maximum": 72,
      "default": 14
    },
    "position": {
      "type": "string",
      "enum": ["top", "bottom", "left", "right", "center"]
    }
  }
}
```

## QML Integration Patterns

### Configuration Access

```qml
// ✅ Good: Direct binding to Config singleton
import qs.config

Rectangle {
    color: Config.appearance.backgroundColor
    radius: Config.appearance.borderRadius
}

// ❌ Bad: Hardcoded values
Rectangle {
    color: "#1E1E2E"
    radius: 8
}
```

### Property Binding

```qml
// ✅ Good: Reactive binding with defaults
QtObject {
    property int duration: Config.animation?.duration ?? 300
    property bool enabled: Config.launcher?.enabled ?? true
}

// ❌ Bad: Non-reactive assignment
QtObject {
    property int duration: 300
    Component.onCompleted: {
        duration = Config.animation.duration
    }
}
```

### Configuration Changes

```qml
// ✅ Good: Connect to configuration changes
Connections {
    target: Config
    function onConfigurationChanged() {
        // React to configuration changes
        updateComponent()
    }
}
```

## Documentation Requirements

### Inline Documentation

Every configuration property must have:

```qml
QtObject {
    // Brief description of what this controls
    // @default: 300
    // @range: 0-1000
    // @unit: milliseconds
    property int animationDuration: 300
}
```

### Schema Documentation

```javascript
{
  "animationDuration": {
    "type": "integer",
    "description": "Duration of animations in milliseconds",
    "default": 300,
    "minimum": 0,
    "maximum": 1000
  }
}
```

## Migration Considerations

### Version Compatibility

Always maintain backward compatibility:

```javascript
// Migration function
function migrate_1_0_to_2_0(oldConfig) {
  return {
    ...oldConfig,
    version: "2.0.0",
    // Map old properties to new structure
    modules: {
      launcher: oldConfig.launcher || {},
      // Handle renamed properties
      controlCenter: oldConfig.controlPanel || {}
    }
  }
}
```

### Deprecation Pattern

```qml
QtObject {
    // @deprecated: Use 'backgroundColor' instead
    property alias bgColor: root.backgroundColor
    
    property color backgroundColor: "#1E1E2E"
}
```

## Testing Requirements

### Configuration Tests

Each configuration module must have:

1. **Loading tests**: Verify configuration loads correctly
2. **Validation tests**: Ensure validation rules work
3. **Default tests**: Confirm defaults are applied
4. **Override tests**: Check override behavior

```javascript
// Example test structure
describe('LauncherConfig', () => {
  test('loads default configuration', () => {
    const config = loadConfig()
    expect(config.launcher.enabled).toBe(true)
  })
  
  test('validates animation duration range', () => {
    const invalid = { launcher: { animationDuration: -100 } }
    expect(() => validateConfig(invalid)).toThrow()
  })
})
```

## Best Practices

### Do's
- ✅ Keep configuration shallow when possible
- ✅ Use descriptive, self-documenting names
- ✅ Provide sensible defaults for everything
- ✅ Validate all external input
- ✅ Document all properties
- ✅ Test configuration changes
- ✅ Version your configuration schema

### Don'ts
- ❌ Don't nest deeper than 4 levels
- ❌ Don't use ambiguous abbreviations
- ❌ Don't mix naming conventions
- ❌ Don't hardcode values that should be configurable
- ❌ Don't break backward compatibility without migration
- ❌ Don't use magic numbers without documentation
- ❌ Don't assume configuration values are valid

## Examples

### Complete Module Configuration

```javascript
{
  "launcher": {
    "enabled": true,
    "appearance": {
      "theme": "dark",
      "accentColor": "#89B4FA",
      "fontSize": 14,
      "fontFamily": "Inter",
      "iconSize": 48
    },
    "behavior": {
      "searchDelayMs": 300,
      "maxResults": 10,
      "caseSensitive": false,
      "fuzzySearch": true,
      "rememberLastQuery": true
    },
    "layout": {
      "width": 600,
      "height": 400,
      "position": "center",
      "marginPercent": 5
    },
    "animation": {
      "enableAnimations": true,
      "openDurationMs": 300,
      "closeDurationMs": 200,
      "itemFadeInMs": 50,
      "easing": "ease-in-out"
    },
    "shortcuts": {
      "open": "Meta+Space",
      "close": "Escape",
      "selectNext": "Down",
      "selectPrevious": "Up"
    }
  }
}
```

This style guide should be followed for all configuration-related development in the Heimdall quickshell project.