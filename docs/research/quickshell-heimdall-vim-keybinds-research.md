# Quickshell Heimdall Vim Keybindings Research

## Executive Summary

The vim-keybinds option in Quickshell Heimdall enables Vim-style keyboard navigation in the launcher and session (power menu) modules. When enabled, users can navigate using Ctrl+J/K in addition to arrow keys. The setting is currently hardcoded to `false` in the QML configuration files and requires manual modification to enable.

## Configuration Location and Structure

### 1. Configuration Files

The vim-keybinds setting is defined in two configuration files:

#### LauncherConfig.qml
**Location**: `/home/arthur/dots/wm/.config/quickshell/heimdall/config/LauncherConfig.qml`
```qml
property bool vimKeybinds: false  // Line 10
```

#### SessionConfig.qml
**Location**: `/home/arthur/dots/wm/.config/quickshell/heimdall/config/SessionConfig.qml`
```qml
property bool vimKeybinds: false  // Line 7
```

### 2. Configuration Loading System

The configuration is loaded through a hierarchical system:

1. **Config.qml** (`/heimdall/config/Config.qml`)
   - Main configuration singleton
   - Loads settings from `~/.config/heimdall/shell.json`
   - Falls back to QML defaults if JSON is minimal

2. **shell.json** (`~/.config/heimdall/shell.json`)
   - Currently contains minimal configuration: `{"version": "1.0.0"}`
   - Does not include vim keybindings settings
   - Would need to be extended to support these settings

## Implementation Details

### 1. Launcher Module Vim Keybindings

**File**: `/home/arthur/dots/wm/.config/quickshell/heimdall/modules/launcher/Content.qml`

#### Keybindings Enabled When `vimKeybinds: true`:

```qml
Keys.onPressed: event => {
    if (!Config.launcher.vimKeybinds)
        return;

    if (event.modifiers & Qt.ControlModifier) {
        if (event.key === Qt.Key_J) {
            // Move down in list (like j in vim)
            list.currentList?.incrementCurrentIndex();
            event.accepted = true;
        } else if (event.key === Qt.Key_K) {
            // Move up in list (like k in vim)
            list.currentList?.decrementCurrentIndex();
            event.accepted = true;
        } else if (event.key === Qt.Key_N) {
            // Next item (Ctrl+N for next wallpaper - vim-like)
            list.currentList?.incrementCurrentIndex();
            event.accepted = true;
        } else if (event.key === Qt.Key_P) {
            // Previous item (Ctrl+P for previous wallpaper - vim-like)
            list.currentList?.decrementCurrentIndex();
            event.accepted = true;
        }
    } else if (event.key === Qt.Key_Tab) {
        // Tab navigation (always enabled)
        list.currentList?.incrementCurrentIndex();
        event.accepted = true;
    } else if (event.key === Qt.Key_Backtab || 
               (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
        // Shift+Tab navigation (always enabled)
        list.currentList?.decrementCurrentIndex();
        event.accepted = true;
    }
}
```

### 2. Session Module Vim Keybindings

**File**: `/home/arthur/dots/wm/.config/quickshell/heimdall/modules/session/Content.qml`

#### Keybindings Enabled When `vimKeybinds: true`:

```qml
Keys.onPressed: event => {
    if (!Config.session.vimKeybinds)
        return;

    if (event.modifiers & Qt.ControlModifier) {
        if (event.key === Qt.Key_J && KeyNavigation.down) {
            // Move to next button (like j in vim)
            KeyNavigation.down.focus = true;
            event.accepted = true;
        } else if (event.key === Qt.Key_K && KeyNavigation.up) {
            // Move to previous button (like k in vim)
            KeyNavigation.up.focus = true;
            event.accepted = true;
        }
    } else if (event.key === Qt.Key_Tab && KeyNavigation.down) {
        // Tab navigation (always enabled)
        KeyNavigation.down.focus = true;
        event.accepted = true;
    } else if (event.key === Qt.Key_Backtab || 
               (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
        // Shift+Tab navigation (always enabled)
        if (KeyNavigation.up) {
            KeyNavigation.up.focus = true;
            event.accepted = true;
        }
    }
}
```

## Complete List of Vim Keybindings

### When vim-keybinds is ENABLED:

#### Launcher Module:
- **Ctrl+J**: Move down in the list (next item)
- **Ctrl+K**: Move up in the list (previous item)
- **Ctrl+N**: Move to next item (alternative to Ctrl+J)
- **Ctrl+P**: Move to previous item (alternative to Ctrl+K)
- **Tab**: Move to next item (always enabled)
- **Shift+Tab**: Move to previous item (always enabled)
- **Up Arrow**: Move up (always enabled)
- **Down Arrow**: Move down (always enabled)
- **Enter**: Select current item (always enabled)
- **Escape**: Close launcher (always enabled)

#### Session Module (Power Menu):
- **Ctrl+J**: Focus next button (logout → shutdown → hibernate → reboot)
- **Ctrl+K**: Focus previous button (reverse order)
- **Tab**: Focus next button (always enabled)
- **Shift+Tab**: Focus previous button (always enabled)
- **Enter**: Execute selected action (always enabled)
- **Escape**: Close session menu (always enabled)

### When vim-keybinds is DISABLED (default):

Only these keybindings work:
- **Tab/Shift+Tab**: Navigation
- **Arrow Keys**: Navigation (launcher only)
- **Enter**: Selection
- **Escape**: Close

## How to Enable Vim Keybindings

### Method 1: Direct QML Modification (Current Only Option)

1. **Edit LauncherConfig.qml**:
   ```bash
   nano /home/arthur/dots/wm/.config/quickshell/heimdall/config/LauncherConfig.qml
   ```
   Change line 10 from:
   ```qml
   property bool vimKeybinds: false
   ```
   To:
   ```qml
   property bool vimKeybinds: true
   ```

2. **Edit SessionConfig.qml**:
   ```bash
   nano /home/arthur/dots/wm/.config/quickshell/heimdall/config/SessionConfig.qml
   ```
   Change line 7 from:
   ```qml
   property bool vimKeybinds: false
   ```
   To:
   ```qml
   property bool vimKeybinds: true
   ```

3. **Restart Quickshell**:
   ```bash
   pkill quickshell && quickshell &
   ```

### Method 2: JSON Configuration (Future Enhancement)

To enable vim keybindings through the JSON configuration system, the `shell.json` file would need to be extended:

**Proposed shell.json structure**:
```json
{
  "version": "1.0.0",
  "launcher": {
    "vimKeybinds": true,
    "enabled": true,
    "maxShown": 8,
    "maxWallpapers": 9
  },
  "session": {
    "vimKeybinds": true,
    "enabled": true,
    "dragThreshold": 30
  }
}
```

However, this requires:
1. Updating the JsonAdapter in Config.qml to properly parse these settings
2. Ensuring the configuration system properly overrides QML defaults
3. Testing the hot-reload functionality with these settings

## Behavior Changes When Vim Mode is Active

### 1. Navigation Enhancement
- Provides keyboard-only navigation without arrow keys
- Allows keeping hands on home row for faster navigation
- Consistent with vim muscle memory for developers

### 2. No Visual Indicators
- No visual indication that vim mode is active
- Keybindings work silently in the background
- No change to UI appearance

### 3. Additional Keybinding Options
- Adds 4 new keybinding combinations per module
- Does not disable existing keybindings
- Tab/Shift+Tab navigation remains available

### 4. Context-Aware Behavior
- In launcher: navigates through application/action list
- In session: navigates through power menu buttons
- Respects current focus and list boundaries

## Technical Implementation Notes

### 1. Event Handling
- Uses Qt's `Keys.onPressed` event handler
- Checks for `Qt.ControlModifier` to detect Ctrl key
- Sets `event.accepted = true` to prevent event propagation

### 2. Navigation Methods
- Launcher uses `list.currentList?.incrementCurrentIndex()` and `decrementCurrentIndex()`
- Session uses `KeyNavigation.up/down.focus = true` for button focus
- Both respect null checks with optional chaining (`?.`)

### 3. Configuration Access
- Accessed via `Config.launcher.vimKeybinds` and `Config.session.vimKeybinds`
- Config singleton provides centralized access
- Falls back to QML defaults if JSON config is incomplete

## Current Limitations

1. **No GUI Configuration**: Cannot be toggled through a settings interface
2. **No Hot-Reload**: Requires Quickshell restart after modification
3. **Limited JSON Support**: shell.json doesn't currently support these settings
4. **No Per-Module Toggle**: Cannot enable for launcher but disable for session independently (though technically possible)
5. **No Custom Keybinding**: Hardcoded to Ctrl+J/K/N/P, cannot be customized

## Recommendations

### For Users
1. Enable vim keybindings if you're comfortable with vim navigation
2. Keep a backup of modified QML files before updates
3. Test keybindings after enabling to ensure they work as expected

### For Developers
1. Extend shell.json schema to include vim keybinding settings
2. Add GUI toggle in settings/configuration panel
3. Consider adding visual indicator when vim mode is active
4. Document the feature in user-facing documentation
5. Consider adding more vim-like keybindings (gg for top, G for bottom, etc.)

## Related Files and Components

- **Config System**: `/heimdall/config/Config.qml`, `ConfigEnhanced.qml`
- **Launcher Module**: `/heimdall/modules/launcher/Content.qml`
- **Session Module**: `/heimdall/modules/session/Content.qml`
- **Configuration Files**: `LauncherConfig.qml`, `SessionConfig.qml`
- **User Config**: `~/.config/heimdall/shell.json`

## Conclusion

The vim-keybinds feature in Quickshell Heimdall is a well-implemented but underdocumented feature that provides efficient keyboard navigation for vim users. While functional, it requires manual QML modification to enable and lacks integration with the JSON configuration system. The implementation is clean and follows Qt best practices, making it a solid foundation for future enhancements.