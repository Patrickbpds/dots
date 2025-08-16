# Heimdall Architecture Analysis and Startup Issues Research

## Executive Summary

This comprehensive analysis investigates the Heimdall Quickshell architecture, comparing it with the previous `ii` configuration to understand startup issues. The research reveals critical differences in state management, wallpaper handling, and initialization sequences between the two configurations. The primary issues stem from asynchronous loading patterns, missing state file initialization, and race conditions in the startup orchestration.

## Architecture Overview

### Heimdall vs II Configuration Comparison

#### II Configuration (Original)
- **Structure**: Monolithic shell.qml with all modules loaded via LazyLoader
- **State Management**: Direct Config.options.background.wallpaperPath property
- **Wallpaper**: Synchronous loading from config property
- **Initialization**: Component.onCompleted hooks for singleton initialization
- **Module Loading**: Conditional loading based on enable flags

#### Heimdall Configuration (New)
- **Structure**: Modular architecture with separate service layers
- **State Management**: File-based state via Paths.state directory
- **Wallpaper**: Asynchronous loading from state files with FileView watchers
- **Initialization**: IPC-based communication and state synchronization
- **Module Loading**: Simplified loader pattern with async components

## Critical Architectural Differences

### 1. Wallpaper State Management

#### II Approach
```qml
// Direct property binding
property string wallpaperPath: Config.options.background.wallpaperPath
source: bgRoot.wallpaperPath
```
- Wallpaper path stored in JSON config
- Immediate availability on startup
- No file system dependencies

#### Heimdall Approach
```qml
// File-based state with FileView
readonly property string currentNamePath: Paths.strip(`${Paths.state}/wallpaper/path.txt`)
FileView {
    path: root.currentNamePath
    watchChanges: true
    onFileChanged: reload()
    onLoaded: {
        root.actualCurrent = text().trim();
    }
}
```
- Wallpaper path in state file: `~/.local/state/quickshell/user/generated/wallpaper/path.txt`
- Asynchronous file loading
- Dependency on file system state

### 2. State Directory Structure

#### Heimdall State Paths
```
~/.local/state/quickshell/user/generated/
├── wallpaper/
│   └── path.txt          # Current wallpaper path
├── colors.json           # Material You colors
├── color.txt             # Current color scheme
├── material_colors.scss  # SCSS variables
└── terminal/             # Terminal color schemes
```

#### Legacy Compatibility
- Symlink: `~/.local/state/heimdall` → `~/.local/state/quickshell/user/generated`
- Multiple state file locations checked for compatibility
- Fallback mechanisms for missing state

### 3. Startup Sequence Analysis

#### Current Startup Flow (startup-orchestrator.sh)
1. **Wayland Display Wait** (0-10s timeout)
2. **State Directory Creation** (immediate)
3. **Wallpaper Daemon Start** (swww-daemon, 1s delay)
4. **Wallpaper Restoration** (restore-wallpaper.sh)
5. **Quickshell Launch** (`qs -c heimdall`, 3s delay)
6. **Heimdall Services** (shell --daemon, pip)

#### Identified Issues

##### Race Condition 1: State File Availability
- **Problem**: Quickshell starts before state files are fully initialized
- **Symptom**: Empty wallpaper path on first read
- **Evidence**: Wallpaper.qml shows "Wallpaper missing?" prompt initially

##### Race Condition 2: FileView Loading
- **Problem**: FileView component loads asynchronously
- **Symptom**: Initial render without wallpaper
- **Evidence**: `onLoaded` callback fires after initial component render

##### Race Condition 3: Wallpaper Daemon Readiness
- **Problem**: swww-daemon may not be ready when wallpaper set attempted
- **Symptom**: Wallpaper restoration fails silently
- **Evidence**: Retry logic in restore-wallpaper.sh (15 attempts)

## Root Cause Analysis

### Primary Issue: Asynchronous State Loading

The Heimdall configuration relies on asynchronous file loading for critical state:

```qml
// Wallpapers.qml
FileView {
    path: root.currentNamePath
    watchChanges: true
    onFileChanged: reload()
    onLoaded: {
        root.actualCurrent = text().trim();  // This happens AFTER initial render
        root.previewColourLock = false;
    }
}
```

This creates a timing window where:
1. Component initializes with empty state
2. FileView starts loading
3. Initial render occurs (no wallpaper)
4. FileView completes loading
5. State updates trigger re-render

### Secondary Issue: Missing Initial State

The startup orchestrator creates state files but may not populate them before Quickshell reads:

```bash
# Creates file but content write may be delayed
echo "$DEFAULT_WALLPAPER" > "$path_file"
# Quickshell may read empty/partial file
```

### Tertiary Issue: IPC Communication Delays

Heimdall uses IPC for state management:

```qml
IpcHandler {
    target: "wallpaper"
    function get(): string {
        return root.actualCurrent;
    }
    function set(path: string): void {
        root.setWallpaper(path);
    }
}
```

IPC handlers may not be ready immediately on startup, causing:
- Failed wallpaper commands
- Delayed state synchronization
- Missing initial configuration

## Configuration File Analysis

### Heimdall Configuration Structure

#### Main Config (`~/.config/heimdall/config.json`)
- Contains CLI tool settings
- Wallpaper directory paths
- External tool configurations
- No shell-specific settings

#### Shell Config (`~/.config/heimdall/shell.json`)
- Minimal configuration (only version)
- Shell settings loaded from QML Config singleton
- Dynamic configuration via FileView adapters

### Missing Migration Elements

Comparing ii to heimdall reveals missing elements:

1. **Wallpaper Path Configuration**
   - ii: Stored in Config.options.background.wallpaperPath
   - heimdall: No equivalent in shell.json

2. **Initial State Population**
   - ii: Config loaded synchronously from JSON
   - heimdall: State files may be empty on first run

3. **Module Initialization**
   - ii: Component.onCompleted with explicit initialization
   - heimdall: Implicit initialization via Loader

## Startup Timing Analysis

### Measured Delays in Current Implementation

```bash
# From startup-orchestrator.sh
sleep 0.5  # After display init
sleep 1    # After swww-daemon start
sleep 3    # After quickshell start
sleep 2    # After heimdall shell start
```

Total minimum delay: 6.5 seconds before full initialization

### Critical Path Dependencies

```
Wayland Display
    ↓
State Directories
    ↓
Wallpaper Daemon (swww)
    ↓
Wallpaper Restoration
    ↓
Quickshell Launch
    ↓
Module Loading (async)
    ↓
FileView Loading (async)
    ↓
Wallpaper Display
```

## Recommended Solutions

### Solution 1: Synchronous State Initialization

Ensure state files are populated before Quickshell starts:

```bash
# In startup-orchestrator.sh, before launching Quickshell
ensure_state_file() {
    local file="$1"
    local content="$2"
    echo "$content" > "$file"
    # Verify write completed
    while [ "$(cat "$file" 2>/dev/null)" != "$content" ]; do
        sleep 0.1
    done
}

ensure_state_file "$QUICKSHELL_STATE_DIR/wallpaper/path.txt" "$WALLPAPER_PATH"
```

### Solution 2: Preload Critical State in QML

Modify Wallpaper.qml to handle initial state:

```qml
Component.onCompleted: {
    // Synchronously read initial state
    const initialPath = FileIO.read(root.currentNamePath);
    if (initialPath) {
        root.actualCurrent = initialPath.trim();
    }
}
```

### Solution 3: Startup State Verification

Add verification step in orchestrator:

```bash
verify_quickshell_ready() {
    local max_attempts=30
    for i in $(seq 1 $max_attempts); do
        if qs -c heimdall ipc call wallpaper get &>/dev/null; then
            local current=$(qs -c heimdall ipc call wallpaper get)
            if [ -n "$current" ] && [ "$current" != "null" ]; then
                return 0
            fi
        fi
        sleep 0.5
    done
    return 1
}
```

### Solution 4: Fallback Wallpaper in QML

Implement immediate fallback in Wallpaper.qml:

```qml
property string source: Wallpapers.current || defaultWallpaper
readonly property string defaultWallpaper: Paths.expandTilde("~/dots/media/Pictures/Wallpapers/Autumn-Alley.jpg")
```

## Performance Impact Analysis

### Current Startup Timeline
1. **0-1s**: Wayland initialization
2. **1-2s**: State directory setup
3. **2-3s**: Wallpaper daemon start
4. **3-4s**: Quickshell launch
5. **4-7s**: Module loading (async)
6. **7-10s**: Full initialization

### Optimized Timeline (with fixes)
1. **0-1s**: Wayland + parallel state setup
2. **1-2s**: Wallpaper daemon + state verification
3. **2-3s**: Quickshell with preloaded state
4. **3-4s**: Full initialization complete

## Testing Recommendations

### Test Scenario 1: Cold Boot
```bash
# Completely remove state and test
rm -rf ~/.local/state/quickshell
rm -rf ~/.local/state/heimdall
systemctl reboot
# Observe startup behavior
```

### Test Scenario 2: State Corruption
```bash
# Corrupt state files
echo "" > ~/.local/state/quickshell/user/generated/wallpaper/path.txt
qs -c heimdall
# Should handle gracefully
```

### Test Scenario 3: Race Condition
```bash
# Add delays to simulate slow disk
strace -e inject=open:delay_enter=500ms qs -c heimdall
# Should still initialize properly
```

## Conclusion

The Heimdall architecture represents a significant departure from the ii configuration, introducing:

1. **File-based state management** replacing direct configuration
2. **Asynchronous loading patterns** throughout the stack
3. **IPC-based communication** for state synchronization
4. **Modular service architecture** with independent components

The startup issues stem primarily from:
- **Race conditions** in asynchronous state loading
- **Missing state initialization** on first boot
- **Inadequate synchronization** between components

The recommended solutions focus on:
- **Ensuring state availability** before component initialization
- **Adding fallback mechanisms** for missing state
- **Improving startup synchronization** with proper verification

Implementation of these fixes should resolve the first-boot issues while maintaining the architectural benefits of the Heimdall design.

## Appendix: File Locations Reference

### Critical State Files
- Wallpaper path: `~/.local/state/quickshell/user/generated/wallpaper/path.txt`
- Color scheme: `~/.local/state/quickshell/user/generated/colors.json`
- Shell config: `~/.config/heimdall/shell.json`

### Startup Scripts
- Orchestrator: `~/.config/hypr/programs/startup-orchestrator.sh`
- Wallpaper restore: `~/.config/hypr/programs/restore-wallpaper.sh`
- Wallpaper sync: `~/.config/hypr/programs/wallpaper-sync.sh`

### QML Components
- Shell entry: `~/.config/quickshell/heimdall/shell.qml`
- Wallpaper service: `~/.config/quickshell/heimdall/services/Wallpapers.qml`
- Background module: `~/.config/quickshell/heimdall/modules/background/`