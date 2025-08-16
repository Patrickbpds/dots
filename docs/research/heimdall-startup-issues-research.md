# Heimdall Quickshell Startup Issues Research Report

## Executive Summary

The Heimdall Quickshell configuration exhibits critical startup timing issues on Hyprland, manifesting as initial freezes with missing wallpaper and UI elements. The root causes include race conditions in the startup orchestration script, incorrect heimdall CLI flags, missing wallpaper daemon synchronization, and potential QML component initialization delays. These issues only occur on first boot after system startup, suggesting systemd/display initialization dependencies.

## Issue Description

### User-Reported Symptoms
1. **Initial startup freeze**: Shell appears frozen with ugly/incomplete rendering
2. **Missing wallpaper**: No wallpaper displayed on first boot
3. **Screen blink recovery**: After some time, screen blinks and starts properly
4. **Subsequent logins work**: Logout/login works normally - issue only on first boot

### Current Configuration Analysis

#### Startup Orchestrator Script (`startup-orchestrator.sh`)
**Source**: `/home/arthur/dots/wm/.config/hypr/programs/startup-orchestrator.sh`
**Relevance**: Primary startup coordination script
**Key Points**:
- Uses fixed delays (0.5s, 1s) for synchronization
- Starts swww-daemon before wallpaper restoration
- Launches heimdall shell with `-d` flag (incorrect - should be `--daemon`)
- Launches heimdall pip with `-d` flag (incorrect - pip doesn't support this flag)
**Code Examples**:
```bash
# Incorrect flag usage causing errors
heimdall shell -d >> "$LOG_FILE" 2>&1 &  # Should be --daemon
heimdall pip -d >> "$LOG_FILE" 2>&1 &    # pip doesn't support -d flag
```
**Caveats**: Error logs show "unknown shorthand flag: 'd' in -d" for pip command

#### Hyprland Execution Configuration
**Source**: `/home/arthur/dots/wm/.config/hypr/hyprland/execs.conf`
**Relevance**: Defines startup sequence for Hyprland
**Key Points**:
- Uses orchestrator script for coordinated startup
- Proper systemd environment variable export
- Includes dbus-update-activation-environment (commented out)
- Sets cursor and workspace focus
**Code Examples**:
```conf
exec-once = ~/.config/hypr/programs/startup-orchestrator.sh
exec-once = systemctl --user import-environment $(env | grep -E '^(XDG_|WAYLAND_|DISPLAY|...)' | cut -d= -f1 | tr '\n' ' ')
```
**Caveats**: Commented out dbus-update lines might be needed for proper initialization

#### Quickshell Background Module
**Source**: `/home/arthur/dots/wm/.config/quickshell/heimdall/modules/background/Background.qml`
**Relevance**: Renders wallpaper and background layer
**Key Points**:
- Uses asynchronous loading
- Sets WlrLayershell.layer to Background
- Includes Wallpaper component
- Conditional desktop clock loading
**Code Examples**:
```qml
Loader {
    asynchronous: true
    active: Config.background.enabled
    // ...
}
```
**Caveats**: Asynchronous loading may contribute to timing issues

#### Wallpaper Service Component
**Source**: `/home/arthur/dots/wm/.config/quickshell/heimdall/services/Wallpapers.qml`
**Relevance**: Manages wallpaper state and loading
**Key Points**:
- Reads from `~/.local/state/quickshell/user/generated/wallpaper/path.txt`
- Uses FileView with watchChanges for dynamic updates
- Implements preview functionality
- Executes heimdall CLI for wallpaper changes
**Code Examples**:
```qml
readonly property string currentNamePath: Paths.strip(`${Paths.state}/wallpaper/path.txt`)
function setWallpaper(path: string): void {
    actualCurrent = path;
    Quickshell.execDetached(["heimdall", "wallpaper", "-f", path]);
}
```
**Caveats**: Depends on external state file that may not exist on first boot

## Root Cause Analysis

### 1. Incorrect Heimdall CLI Flags

**Finding**: The startup orchestrator uses incorrect flags for heimdall commands
- `heimdall shell -d` should be `heimdall shell --daemon`
- `heimdall pip -d` is invalid - pip doesn't support daemon mode flag

**Evidence from startup log**:
```
Error: unknown shorthand flag: 'd' in -d
Usage:
  heimdall pip [flags]
```

### 2. Race Condition in Wallpaper Initialization

**Finding**: Multiple asynchronous operations compete during startup:
- swww-daemon initialization
- Wallpaper state file reading
- Quickshell Background module loading
- QML component initialization

**Evidence**:
- Fixed sleep delays in orchestrator (0.5s, 1s)
- Asynchronous QML Loader components
- FileView watching for changes that may not exist yet

### 3. Missing Display/Compositor Readiness Check

**Finding**: No verification that Hyprland/Wayland display is fully initialized
- Script starts immediately after exec-once
- No check for display server readiness
- No verification of screen configuration

**Evidence from Hyprland wiki**:
- exec-once runs immediately on compositor startup
- No built-in synchronization mechanism

### 4. State File Dependencies

**Finding**: Wallpaper restoration depends on state file that may not exist
- Path: `~/.local/state/quickshell/user/generated/wallpaper/path.txt`
- Fallback mechanism exists but may not trigger properly
- Race between file creation and reading

### 5. QML Component Initialization Timing

**Finding**: Multiple QML components use Component.onCompleted without coordination
- Background module uses asynchronous loading
- Wallpaper component has image loading states
- No centralized initialization sequence

**Evidence from grep results**:
- 49 matches for Component.onCompleted/Timer/delay patterns
- No apparent coordination mechanism

## Comparison with Working Configurations

### Source: Previous Research Documents
**Relevance**: Historical analysis of similar issues
**Key Points**:
- Previous ii configuration had simpler startup
- Caelestia base uses different state directory structure
- Missing wallpaper persistence in heimdall CLI identified
**Code Examples**: From previous analysis:
```go
// Missing in heimdall CLI
if err := os.WriteFile(paths.WallpaperPath, []byte(wallpaperPath), 0644); err != nil {
    logger.Error("Failed to save wallpaper path", "error", err)
}
```
**Caveats**: Some issues already identified but not fixed

### Source: Hyprland Wiki - Executing Keywords
**Relevance**: Official documentation on startup execution
**Key Points**:
- exec-once runs only on launch
- exec runs on each reload
- No built-in synchronization primitives
- Environment variables set with env keyword
**Code Examples**:
```conf
exec-once = command  # Runs once on startup
exec = command       # Runs on each reload
```
**Caveats**: Wiki doesn't provide timing guarantees

## Proposed Solutions

### Immediate Fixes

1. **Fix Heimdall CLI Flags**
```bash
# In startup-orchestrator.sh, change:
heimdall shell -d >> "$LOG_FILE" 2>&1 &
# To:
heimdall shell --daemon >> "$LOG_FILE" 2>&1 &

# Remove pip daemon attempt (not supported):
# heimdall pip -d >> "$LOG_FILE" 2>&1 &
heimdall pip >> "$LOG_FILE" 2>&1 &
```

2. **Add Display Readiness Check**
```bash
# Wait for Wayland display
while [ -z "$WAYLAND_DISPLAY" ]; do
    sleep 0.1
done

# Wait for Hyprland IPC
while ! hyprctl version &>/dev/null; do
    sleep 0.1
done
```

3. **Improve Wallpaper Restoration**
```bash
# Ensure state directory exists
mkdir -p ~/.local/state/quickshell/user/generated/wallpaper

# Check and create default if missing
if [ ! -f "$STATE_FILE" ]; then
    echo "$FALLBACK_WALLPAPER" > "$STATE_FILE"
fi
```

### Long-term Improvements

1. **Implement Proper Service Dependencies**
- Use systemd user services with proper After=/Wants= dependencies
- Create hyprland-session.target for coordination
- Use Type=notify for readiness signaling

2. **QML Initialization Coordination**
- Implement initialization state machine
- Use Qt signals for component readiness
- Add retry logic for failed operations

3. **Enhanced Logging**
- Add timestamps to all operations
- Log component initialization states
- Implement debug mode with verbose output

## Testing Recommendations

1. **Cold Boot Test**
- Full system restart
- Monitor startup log: `/tmp/quickshell-startup.log`
- Check process order with `ps aux | grep -E "heimdall|quickshell"`

2. **Timing Analysis**
- Add timing measurements to orchestrator
- Log each step with `date +%s.%N`
- Identify bottlenecks

3. **State File Verification**
- Check file existence before/after boot
- Verify file permissions
- Test with missing state directory

## Additional Research Findings

### Source: GitHub Quickshell Issues
**Relevance**: Community-reported similar issues
**Key Points**:
- No direct matches for "startup freeze wallpaper"
- Several crash reports related to FloatingWindow
- Qt.locale and formatDateTime issues reported
**Caveats**: Issues may be version-specific

### Source: Quickshell Codebase Analysis
**Relevance**: Understanding initialization flow
**Key Points**:
- ShellRoot is top-level component
- Multiple singleton services initialized
- Heavy use of asynchronous loading
- IPC handlers for external communication
**Code Examples**:
```qml
ShellRoot {
    Background {}
    Drawers {}
    AreaPicker {}
    Lock {}
    Shortcuts {}
}
```

## Recommendations Priority

### Critical (Immediate)
1. Fix heimdall CLI flags in startup-orchestrator.sh
2. Add display readiness checks
3. Ensure state directory exists

### High (Next Session)
1. Implement proper wallpaper state persistence
2. Add retry logic for failed operations
3. Enhance error logging

### Medium (Future)
1. Migrate to systemd user services
2. Implement QML initialization coordination
3. Add performance monitoring

## Conclusion

The startup issues stem from a combination of incorrect command flags, race conditions, and missing synchronization between components. The immediate fix of correcting the heimdall CLI flags should resolve the most visible errors, while adding proper readiness checks will address the timing issues. The fact that subsequent logins work correctly indicates the issue is specifically related to cold boot initialization timing, likely due to systemd and display server startup sequences not being properly synchronized with the Quickshell components.

## References

- Hyprland Wiki - Keywords: https://wiki.hyprland.org/Configuring/Keywords/#executing
- Quickshell GitHub: https://github.com/outfoxxed/quickshell
- Previous Analysis: `/home/arthur/dots/HYPRLAND_QUICKSHELL_ISSUES_ANALYSIS.md`
- Startup Log: `/tmp/quickshell-startup.log`
- Heimdall CLI Documentation: Built-in help via `heimdall --help`