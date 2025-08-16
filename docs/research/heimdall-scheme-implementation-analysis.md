# Heimdall Scheme Implementation Analysis

## Executive Summary

The color scheme implementation in heimdall-cli has critical issues that prevent proper integration with the Quickshell UI:

1. **Path Mismatch**: heimdall-cli writes to `current_scheme.json` while Quickshell reads from `scheme.json`
2. **Format Mismatch**: The `scheme.json` file contains only raw colors instead of the expected structured format
3. **Missing Color Prefix**: Quickshell expects colors with `m3` prefix, but the scheme provides them without
4. **No Sync Mechanism**: No process updates `scheme.json` when schemes are changed via CLI

## Current Implementation Issues

### 1. File Path Discrepancy

**heimdall-cli behavior:**
- Writes scheme data to: `~/.local/state/heimdall/current_scheme.json`
- Location defined in: `internal/scheme/manager.go:SetScheme()`
- Format: Full scheme object with metadata

**Quickshell expectation:**
- Reads from: `~/.local/state/quickshell/user/generated/scheme.json`
- Symlinked as: `~/.local/state/heimdall/scheme.json`
- Location defined in: `heimdall/services/Colours.qml:82`

### 2. Format Incompatibility

**Expected format (from caelestia/cli):**
```json
{
  "name": "catppuccin",
  "flavour": "mocha", 
  "mode": "dark",
  "variant": "tonalspot",
  "colours": {
    "primary": "7171ac",
    "secondary": "76758e",
    // ... (no prefixes, hex without #)
  }
}
```

**Current scheme.json content:**
```json
{
  "background": "#131314",
  "error": "#ffb4ab",
  // ... (raw colors only, with # prefix)
}
```

**heimdall-cli current_scheme.json format:**
```json
{
  "name": "catppuccin",
  "flavour": "mocha",
  "mode": "dark",
  "variant": "",
  "colors": {
    "background": {"hex": "#131314", "rgb": {...}},
    // ... (complex color objects)
  },
  "metadata": {...}
}
```

### 3. Color Naming Convention

**Quickshell QML expects:**
- Properties prefixed with `m3` (Material 3 design)
- Example: `m3primary`, `m3background`, `m3surface`
- Defined in: `heimdall/services/Colours.qml:70-74`

**Current implementation provides:**
- No prefix: `primary`, `background`, `surface`
- Mismatch prevents proper color application

## Comparison with caelestia/cli

### caelestia/cli Implementation (Python)

**File:** `src/caelestia/subcommands/scheme.py`
- Uses `Scheme` class from `utils/scheme.py`
- Saves to: `~/.local/state/caelestia/scheme.json`
- Format: Structured with name, flavour, mode, variant, colours
- Updates: Atomic write with proper format

**Key differences:**
1. Single `scheme.json` file (not `current_scheme.json`)
2. Consistent format between save and read
3. Colors stored as hex strings without `#`
4. Direct integration with Quickshell expectations

### heimdall-cli Implementation (Go)

**Files:**
- `internal/scheme/manager.go`: Core scheme management
- `internal/commands/scheme/set.go`: CLI command implementation
- `internal/utils/paths/xdg.go`: Path definitions

**Issues:**
1. Writes to wrong filename (`current_scheme.json`)
2. Complex color objects instead of simple hex strings
3. No process to sync/convert to expected format
4. Migration code doesn't handle format conversion

## Quickshell Integration

### Launcher Component

**File:** `modules/launcher/services/Schemes.qml`
- Executes: `heimdall scheme set -n [name] -f [flavour]`
- Expects scheme.json to be updated after command
- No feedback when scheme doesn't change

### Color Service

**File:** `services/Colours.qml`
- Watches: `${Paths.state}/scheme.json`
- Loads colors with: `JSON.parse(data)`
- Maps to QML properties: `m3${name} = #${colour}`

## Root Causes

1. **Incomplete Migration**: The migration from caelestia to heimdall didn't update the file writing logic
2. **Missing Sync Process**: No component writes the properly formatted `scheme.json`
3. **Format Evolution**: heimdall-cli evolved to use complex color objects but didn't maintain backward compatibility
4. **Path Confusion**: Multiple scheme-related files without clear purpose distinction

## Required Fixes

### Immediate Fix (heimdall-cli)

1. **Update SetScheme() in manager.go:**
   - Write to both `current_scheme.json` (internal) and `scheme.json` (UI)
   - Convert complex color format to simple hex strings
   - Match expected JSON structure

2. **Format Conversion:**
   ```go
   // After setting scheme internally
   uiScheme := map[string]interface{}{
       "name": scheme.Name,
       "flavour": scheme.Flavour,
       "mode": scheme.Mode,
       "variant": scheme.Variant,
       "colours": convertToSimpleColors(scheme.Colors),
   }
   // Write to scheme.json
   ```

3. **Color Conversion:**
   - Strip `#` from hex values
   - Remove `m3` prefix if present
   - Convert color objects to simple strings

### Alternative Fix (Quickshell)

1. **Update Colours.qml:**
   - Read from `current_scheme.json` instead
   - Handle complex color format
   - Extract hex values from color objects

2. **Add compatibility layer:**
   - Check both file locations
   - Support both formats
   - Graceful fallback

## Beat Detector Removal

**File:** `services/BeatDetector.qml`
- Line 13: References `/usr/lib/heimdall/beat_detector`
- Has been commented out (fix applied)
- Not related to color scheme functionality
- Used by Media.qml for animation speed (will use default value)

## Implementation Recommendations

### Quick Fix (Workaround)
Create a sync script that watches `current_scheme.json` and updates `scheme.json`:

```bash
#!/bin/bash
# /usr/local/bin/heimdall-scheme-sync

inotifywait -m ~/.local/state/heimdall/current_scheme.json -e modify |
while read path action file; do
    if [ -f ~/.local/state/heimdall/current_scheme.json ]; then
        jq '{
            name: .name,
            flavour: .flavour,
            mode: .mode,
            variant: .variant,
            colours: .colors | to_entries | map({
                key: .key | gsub("^m3"; ""),
                value: .value.hex[1:]
            }) | from_entries
        }' ~/.local/state/heimdall/current_scheme.json > ~/.local/state/heimdall/scheme.json
    fi
done
```

### Proper Fix (heimdall-cli modification)

Modify `internal/scheme/manager.go`:

```go
func (m *Manager) SetScheme(scheme *Scheme) error {
    // Existing code to save current_scheme.json
    statePath := filepath.Join(m.stateDir, "current_scheme.json")
    // ... existing implementation ...

    // NEW: Also write UI-compatible scheme.json
    uiPath := filepath.Join(m.stateDir, "scheme.json")
    uiScheme := map[string]interface{}{
        "name":    scheme.Name,
        "flavour": scheme.Flavour,
        "mode":    scheme.Mode,
        "variant": scheme.Variant,
        "colours": m.convertToUIColors(scheme.Colors),
    }
    
    uiData, err := json.MarshalIndent(uiScheme, "", "  ")
    if err != nil {
        return fmt.Errorf("failed to marshal UI scheme: %w", err)
    }
    
    if err := paths.AtomicWrite(uiPath, uiData); err != nil {
        return fmt.Errorf("failed to write UI scheme: %w", err)
    }
    
    return nil
}

func (m *Manager) convertToUIColors(colors map[string]*color.Color) map[string]string {
    result := make(map[string]string)
    for name, color := range colors {
        // Remove m3 prefix if present
        key := strings.TrimPrefix(name, "m3")
        // Convert to hex without #
        result[key] = color.Hex()[1:]
    }
    return result
}
```

## Testing Recommendations

1. **Verify file writes:**
   ```bash
   heimdall scheme set catppuccin mocha dark
   cat ~/.local/state/heimdall/current_scheme.json | jq .
   cat ~/.local/state/heimdall/scheme.json | jq .
   ```

2. **Check Quickshell integration:**
   - Monitor QML console for errors
   - Verify color changes in UI
   - Test launcher scheme selection

3. **Format validation:**
   - Ensure colors load without `m3` prefix issues
   - Verify mode switching (light/dark)
   - Check variant application

## Conclusion

The scheme implementation has a fundamental disconnect between what heimdall-cli writes and what Quickshell expects. The fix requires either:
1. Updating heimdall-cli to write the correct format to `scheme.json`
2. Updating Quickshell to read from `current_scheme.json` with proper format handling

The first option is recommended as it maintains compatibility with the existing UI components and follows the original caelestia design.