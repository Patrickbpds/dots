# Hyprland Quickshell Migration Issues Research

## Executive Summary

The migration from quickshell/ii to quickshell/heimdall (Caelestia-based) has revealed critical configuration misalignments causing system instability. The primary issues stem from state directory mismatches, incomplete command configurations, missing wallpaper persistence, and race conditions during startup. These issues manifest as blank screens on boot, failed SDDM logout, lost wallpaper settings, and Docker Desktop startup failures. All issues are resolvable through targeted configuration fixes and code modifications to the heimdall CLI tool.

## Critical Issues Found

### 1. Wallpaper Persistence Failure
- **Impact**: Wallpaper resets to blank/default on every reboot
- **Root Cause**: heimdall CLI doesn't write to `~/.local/state/quickshell/user/generated/wallpaper/path.txt`
- **Evidence**: The path.txt file exists but isn't updated by heimdall CLI

### 2. SDDM Logout Failure
- **Impact**: Cannot return to login screen from power menu
- **Root Cause**: Empty username parameter in logout command
- **Evidence**: `["loginctl", "terminate-user", ""]` in SessionConfig.qml

### 3. Blank Screen on Boot
- **Impact**: Display shows blank/wrong resolution on fresh boot
- **Root Cause**: Race conditions in startup sequence, missing wallpaper backend initialization
- **Evidence**: No wallpaper daemon (swww/hyprpaper) started before shell

### 4. Docker Desktop Startup Failure
- **Impact**: Docker Desktop doesn't start automatically
- **Root Cause**: Complex startup logic with systemd service manipulation
- **Evidence**: Stopping and re-enabling service on every boot causes timing issues

### 5. Resolution/Proportion Issues
- **Impact**: UI elements appear incorrectly sized or positioned
- **Root Cause**: Shell starts before display fully initialized
- **Evidence**: Missing delay between display init and shell startup

### 6. Path and State Directory Mismatches
- **Impact**: Configuration and state not properly shared between components
- **Root Cause**: heimdall CLI uses different paths than quickshell expects
- **Evidence**: heimdall expects `~/.local/state/heimdall/`, quickshell expects `~/.local/state/quickshell/user/generated/`

## Root Cause Analysis

### Issue 1: Wallpaper Persistence

**What's happening:**
- User sets wallpaper via `heimdall wallpaper -f /path/to/image.jpg`
- Wallpaper displays correctly in current session
- After reboot, wallpaper is lost

**Why it's happening:**
- heimdall CLI creates symlink at `~/.local/state/heimdall/wallpaper/current` (doesn't exist)
- quickshell/heimdall reads from `~/.local/state/quickshell/user/generated/wallpaper/path.txt`
- The CLI never writes to the path.txt file that quickshell expects

**Comparison with working ii setup:**
```qml
// ii uses direct configuration
property string wallpaperPath: Config.options.background.wallpaperPath
```

**Comparison with Caelestia base:**
- Caelestia uses `~/.local/state/caelestia/` directory structure
- Has proper path.txt writing in its CLI tool

### Issue 2: SDDM Logout

**What's happening:**
- User clicks logout in power menu
- Nothing happens or error occurs
- Session remains active

**Why it's happening:**
```qml
// Current broken configuration
property list<string> logout: ["loginctl", "terminate-user", ""]
// Empty string where username should be
```

**Comparison with working ii setup:**
- ii likely uses hyprctl dispatch exit or proper username resolution

**Comparison with Caelestia base:**
```qml
// Caelestia properly resolves username
property list<string> logout: ["loginctl", "terminate-user", Quickshell.env("USER")]
```

### Issue 3: Blank Screen on Boot

**What's happening:**
- System boots to SDDM
- User logs in
- Screen remains blank or shows wrong resolution
- Manual restart of shell fixes issue

**Why it's happening:**
1. No wallpaper backend daemon started
2. Shell starts immediately without waiting for display
3. Missing wallpaper restoration on startup

**Comparison with working ii setup:**
- ii has proper startup sequence with delays
- Uses hyprpaper or swww daemon

**Comparison with Caelestia base:**
- Caelestia includes proper daemon initialization
- Has built-in startup delays

### Issue 4: Docker Desktop Failure

**What's happening:**
- Docker Desktop should auto-start
- Service manipulation causes race conditions
- Docker fails to start or starts incorrectly

**Why it's happening:**
```bash
# Current problematic command
exec-once = sh -c "systemctl --user stop docker-desktop.service && \
  systemctl --user disable docker-desktop.service && \
  systemctl --user enable docker-desktop.service && \
  /opt/docker-desktop/bin/docker-desktop"
```

**Issues:**
- Stopping service that may not be running
- Re-enabling on every boot is unnecessary
- No error handling

## Detailed Solutions

### Solution 1: Fix Wallpaper Persistence

**Option A: Modify heimdall CLI to write path.txt**

Create patch file `heimdall-wallpaper-fix.patch`:
```go
// In heimdall-cli/internal/commands/wallpaper/wallpaper.go
// Add after line 24 (after symlink creation)

import (
    "os"
    "path/filepath"
)

func setWallpaper(wallpaperPath string, generateScheme bool) error {
    // ... existing code ...
    
    // Add this block after symlink creation:
    // Write to quickshell's expected location
    qsWallpaperDir := filepath.Join(os.Getenv("HOME"), 
        ".local/state/quickshell/user/generated/wallpaper")
    qsWallpaperPath := filepath.Join(qsWallpaperDir, "path.txt")
    
    // Create directory if it doesn't exist
    if err := os.MkdirAll(qsWallpaperDir, 0755); err != nil {
        logger.Error("Failed to create quickshell wallpaper directory", "error", err)
        return err
    }
    
    // Write the wallpaper path
    if err := os.WriteFile(qsWallpaperPath, []byte(wallpaperPath), 0644); err != nil {
        logger.Error("Failed to save wallpaper path for quickshell", "error", err)
        return err
    }
    
    logger.Info("Wallpaper path saved for quickshell", "path", qsWallpaperPath)
    
    // ... rest of function ...
}
```

**Option B: Create wrapper script**

Create `/home/arthur/.local/bin/heimdall-wallpaper-wrapper`:
```bash
#!/bin/bash
# Wrapper to ensure wallpaper persistence

WALLPAPER_PATH="$2"  # Assumes -f flag is $1
QS_WALLPAPER_DIR="$HOME/.local/state/quickshell/user/generated/wallpaper"
QS_WALLPAPER_PATH="$QS_WALLPAPER_DIR/path.txt"

# Call original heimdall
heimdall wallpaper "$@"

# Save path for quickshell
if [ -n "$WALLPAPER_PATH" ] && [ -f "$WALLPAPER_PATH" ]; then
    mkdir -p "$QS_WALLPAPER_DIR"
    echo "$WALLPAPER_PATH" > "$QS_WALLPAPER_PATH"
    echo "Wallpaper path saved to $QS_WALLPAPER_PATH"
fi
```

### Solution 2: Fix Session Logout

Edit `/home/arthur/dots/wm/.config/quickshell/heimdall/config/SessionConfig.qml`:
```qml
import Quickshell
import Quickshell.Io

JsonObject {
    property bool enabled: true
    property int dragThreshold: 30
    property bool vimKeybinds: false
    property Commands commands: Commands {}

    property Sizes sizes: Sizes {}

    component Commands: JsonObject {
        // Fix: Use actual username from environment
        property list<string> logout: {
            const user = Quickshell.env("USER");
            return user ? ["loginctl", "terminate-user", user] 
                        : ["hyprctl", "dispatch", "exit"];
        }
        property list<string> shutdown: ["systemctl", "poweroff"]
        property list<string> hibernate: ["systemctl", "hibernate"]
        property list<string> reboot: ["systemctl", "reboot"]
    }

    component Sizes: JsonObject {
        property int button: 80
    }
}
```

### Solution 3: Fix Startup Sequence

Edit `/home/arthur/dots/wm/.config/hypr/hyprland/execs.conf`:
```conf
# Initialize wallpaper backend FIRST
exec-once = swww-daemon --format xrgb || hyprpaper &

# Wait for display and daemon initialization
exec-once = sleep 1

# Restore wallpaper from saved state
exec-once = ~/.config/hypr/programs/restore-wallpaper.sh

# Start shell components after wallpaper is ready
exec-once = sleep 0.5 && heimdall shell -d
exec-once = heimdall pip -d

# Rest of original configuration...
exec-once = fcitx5
exec-once = gnome-keyring-daemon --start --components=secrets
# ... etc
```

Create `/home/arthur/dots/wm/.config/hypr/programs/restore-wallpaper.sh`:
```bash
#!/bin/bash
# Wallpaper restoration script with fallback mechanisms

WALLPAPER_PATH_FILE="$HOME/.local/state/quickshell/user/generated/wallpaper/path.txt"
FALLBACK_WALLPAPER="$HOME/Pictures/Wallpapers/Autumn-Alley.jpg"

# Function to set wallpaper using available method
set_wallpaper() {
    local wallpaper="$1"
    
    # Try heimdall first
    if command -v heimdall &> /dev/null; then
        heimdall wallpaper -f "$wallpaper" 2>/dev/null && return 0
    fi
    
    # Try swww
    if pgrep -x "swww-daemon" > /dev/null; then
        swww img "$wallpaper" --transition-type fade 2>/dev/null && return 0
    fi
    
    # Try hyprpaper
    if pgrep -x "hyprpaper" > /dev/null; then
        echo "preload = $wallpaper" > /tmp/hyprpaper.conf
        echo "wallpaper = ,$wallpaper" >> /tmp/hyprpaper.conf
        hyprctl hyprpaper unload all
        hyprctl hyprpaper preload "$wallpaper"
        hyprctl hyprpaper wallpaper ",$wallpaper"
        return 0
    fi
    
    return 1
}

# Main logic
if [ -f "$WALLPAPER_PATH_FILE" ]; then
    WALLPAPER=$(cat "$WALLPAPER_PATH_FILE")
    if [ -f "$WALLPAPER" ]; then
        echo "Restoring wallpaper: $WALLPAPER"
        set_wallpaper "$WALLPAPER"
    else
        echo "Saved wallpaper not found, using fallback"
        set_wallpaper "$FALLBACK_WALLPAPER"
    fi
else
    echo "No saved wallpaper, using fallback"
    set_wallpaper "$FALLBACK_WALLPAPER"
fi
```

### Solution 4: Fix Docker Desktop

Edit `/home/arthur/dots/wm/.config/hypr/custom/execs.conf`:
```conf
# Simplified Docker Desktop startup with proper error handling
exec-once = ~/.config/hypr/programs/start-docker-desktop.sh
```

Create `/home/arthur/dots/wm/.config/hypr/programs/start-docker-desktop.sh`:
```bash
#!/bin/bash
# Robust Docker Desktop startup script

DOCKER_DESKTOP="/opt/docker-desktop/bin/docker-desktop"
SYMLINK_SCRIPT="$HOME/.config/hypr/hyprland/scripts/create-docker-symlink.sh"

# Function to check if Docker Desktop is installed
check_docker_desktop() {
    [ -f "$DOCKER_DESKTOP" ] && [ -x "$DOCKER_DESKTOP" ]
}

# Function to start Docker Desktop
start_docker_desktop() {
    # Check if already running
    if pgrep -f "docker-desktop" > /dev/null; then
        echo "Docker Desktop is already running"
        return 0
    fi
    
    # Try systemd service first
    if systemctl --user is-enabled docker-desktop.service &>/dev/null; then
        systemctl --user start docker-desktop.service && {
            echo "Started Docker Desktop via systemd"
            return 0
        }
    fi
    
    # Fallback to direct execution
    if check_docker_desktop; then
        nohup "$DOCKER_DESKTOP" > /dev/null 2>&1 &
        echo "Started Docker Desktop directly"
        return 0
    fi
    
    echo "Docker Desktop not found"
    return 1
}

# Main execution
if start_docker_desktop; then
    # Wait for Docker to initialize
    sleep 5
    
    # Create symlink if script exists
    if [ -f "$SYMLINK_SCRIPT" ] && [ -x "$SYMLINK_SCRIPT" ]; then
        sudo "$SYMLINK_SCRIPT" 2>/dev/null || echo "Symlink creation requires sudo"
    fi
fi
```

### Solution 5: Configuration Alignment

Create `/home/arthur/dots/wm/.config/hypr/hyprland/env.conf` additions:
```conf
# Align heimdall CLI with quickshell expectations
env = HEIMDALL_STATE_DIR,$HOME/.local/state/quickshell/user/generated
env = HEIMDALL_CONFIG_DIR,$HOME/.config/quickshell/heimdall
env = QS_CONFIG_NAME,heimdall
env = QS_WALLPAPER_PATH,$HOME/.local/state/quickshell/user/generated/wallpaper/path.txt
```

Create symlinks for compatibility:
```bash
#!/bin/bash
# Create compatibility symlinks
mkdir -p ~/.local/state/heimdall
ln -sf ~/.local/state/quickshell/user/generated/wallpaper ~/.local/state/heimdall/wallpaper
ln -sf ~/.config/quickshell/heimdall ~/.config/heimdall
```

## Implementation Plan

### Phase 1: Critical Fixes (Immediate)
1. **Fix logout command** (5 minutes)
   - Edit SessionConfig.qml
   - Test logout functionality
   
2. **Fix wallpaper persistence** (30 minutes)
   - Either patch heimdall CLI or create wrapper script
   - Test wallpaper setting and persistence

3. **Fix startup sequence** (15 minutes)
   - Update execs.conf
   - Create restore-wallpaper.sh
   - Test reboot cycle

### Phase 2: Stability Improvements (Day 1)
1. **Fix Docker Desktop** (20 minutes)
   - Create start-docker-desktop.sh
   - Update custom/execs.conf
   - Test Docker startup

2. **Add environment variables** (10 minutes)
   - Update env.conf
   - Create compatibility symlinks
   - Verify path resolution

### Phase 3: Long-term Alignment (Week 1)
1. **Unify state directories**
   - Audit all path references
   - Create migration script
   - Update documentation

2. **Improve error handling**
   - Add logging to scripts
   - Create health check script
   - Implement recovery mechanisms

### Priority Order
1. Session logout fix (CRITICAL - blocks user workflow)
2. Wallpaper persistence (HIGH - user experience)
3. Startup sequence (HIGH - system stability)
4. Docker Desktop (MEDIUM - developer workflow)
5. Path alignment (LOW - technical debt)

### Testing Methodology

#### Test Suite 1: Basic Functionality
```bash
#!/bin/bash
# Test basic functionality

echo "Test 1: Wallpaper Setting"
heimdall wallpaper -f ~/Pictures/Wallpapers/Autumn-Alley.jpg
sleep 2
if [ "$(cat ~/.local/state/quickshell/user/generated/wallpaper/path.txt)" = "$HOME/Pictures/Wallpapers/Autumn-Alley.jpg" ]; then
    echo "✓ Wallpaper path saved correctly"
else
    echo "✗ Wallpaper path not saved"
fi

echo "Test 2: Logout Command"
# This would need manual testing or a test environment
echo "Manual test required: Try logout from power menu"

echo "Test 3: Reboot Persistence"
echo "Manual test required: Reboot and check if wallpaper persists"
```

#### Test Suite 2: Startup Sequence
```bash
#!/bin/bash
# Monitor startup sequence

# Add to ~/.config/hypr/hyprland/execs.conf temporarily:
# exec-once = echo "$(date): Display init" >> /tmp/hypr-startup.log
# exec-once = sleep 1 && echo "$(date): Wallpaper daemon" >> /tmp/hypr-startup.log
# exec-once = ~/.config/hypr/programs/restore-wallpaper.sh && echo "$(date): Wallpaper restored" >> /tmp/hypr-startup.log
# exec-once = heimdall shell -d && echo "$(date): Shell started" >> /tmp/hypr-startup.log

# After reboot, check:
cat /tmp/hypr-startup.log
```

### Rollback Strategy

1. **Backup current configuration:**
```bash
#!/bin/bash
# Create backup before changes
BACKUP_DIR="$HOME/.config/hypr-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r ~/.config/hypr/* "$BACKUP_DIR/"
cp -r ~/.config/quickshell/heimdall/* "$BACKUP_DIR/quickshell-heimdall/"
echo "Backup created at $BACKUP_DIR"
```

2. **Rollback script:**
```bash
#!/bin/bash
# Rollback to previous configuration
BACKUP_DIR="$1"
if [ -z "$BACKUP_DIR" ] || [ ! -d "$BACKUP_DIR" ]; then
    echo "Usage: $0 <backup-directory>"
    exit 1
fi

# Stop current session
heimdall shell -k 2>/dev/null
pkill -f quickshell

# Restore configuration
cp -r "$BACKUP_DIR/"* ~/.config/hypr/
cp -r "$BACKUP_DIR/quickshell-heimdall/"* ~/.config/quickshell/heimdall/

# Restart shell
heimdall shell -d
echo "Rolled back to $BACKUP_DIR"
```

## Configuration Alignment Strategy

### Proper Caelestia Structure Alignment

1. **Directory Structure:**
```
~/.local/state/quickshell/user/generated/
├── wallpaper/
│   └── path.txt          # Current wallpaper path
├── colors/
│   └── colors.json       # Generated color scheme
└── config/
    └── overrides.json    # User overrides

~/.config/quickshell/heimdall/
├── config/
│   ├── Config.qml        # Main configuration
│   ├── SessionConfig.qml # Session commands
│   └── UserPaths.qml     # User path definitions
└── shell.qml             # Entry point
```

2. **State Management Best Practices:**
- Always use FileView with watchChanges for dynamic state
- Write state atomically to prevent corruption
- Use proper QML property bindings for reactive updates
- Implement proper error handling for missing files

3. **Environment Variable Requirements:**
```bash
# Required environment variables
export QS_CONFIG_PATH="$HOME/.config/quickshell/heimdall"
export QS_STATE_PATH="$HOME/.local/state/quickshell/user/generated"
export QS_CACHE_PATH="$HOME/.cache/quickshell"
export HEIMDALL_BACKEND="swww"  # or hyprpaper
```

### Migration from ii to heimdall

1. **Configuration Migration Script:**
```bash
#!/bin/bash
# Migrate ii configuration to heimdall format

II_CONFIG="$HOME/.config/quickshell/ii/modules/common/Config.qml"
HEIMDALL_CONFIG="$HOME/.config/quickshell/heimdall/config/Config.qml"

if [ -f "$II_CONFIG" ]; then
    # Extract wallpaper path from ii config
    WALLPAPER=$(grep -oP 'wallpaperPath:\s*"\K[^"]+' "$II_CONFIG")
    if [ -n "$WALLPAPER" ]; then
        mkdir -p "$HOME/.local/state/quickshell/user/generated/wallpaper"
        echo "$WALLPAPER" > "$HOME/.local/state/quickshell/user/generated/wallpaper/path.txt"
        echo "Migrated wallpaper: $WALLPAPER"
    fi
fi
```

## Testing Checklist

### Pre-Implementation
- [ ] Create full backup of current configuration
- [ ] Document current issues with screenshots/logs
- [ ] Verify backup restoration works

### Phase 1 Testing
- [ ] Logout returns to SDDM
- [ ] Wallpaper persists across reboots
- [ ] No blank screen on startup
- [ ] Shell components load in correct order

### Phase 2 Testing
- [ ] Docker Desktop starts automatically
- [ ] Docker symlink created successfully
- [ ] Environment variables properly set
- [ ] Compatibility symlinks work

### Phase 3 Testing
- [ ] All paths resolve correctly
- [ ] No permission errors in logs
- [ ] Configuration changes persist
- [ ] Error recovery works as expected

### Integration Testing
- [ ] Full reboot cycle works correctly
- [ ] Suspend/resume maintains state
- [ ] Multi-monitor setup works
- [ ] Performance is acceptable

### Regression Testing
- [ ] Previous features still work
- [ ] No new error messages in logs
- [ ] Resource usage normal
- [ ] User workflows unaffected

## Debugging Commands

```bash
# Check current wallpaper state
cat ~/.local/state/quickshell/user/generated/wallpaper/path.txt

# Monitor quickshell logs
journalctl --user -f | grep -E "quickshell|heimdall"

# Check running processes
ps aux | grep -E "heimdall|quickshell|swww|hyprpaper"

# Test logout command manually
loginctl terminate-user $USER

# Check heimdall IPC
heimdall shell -c "wallpaper.get"

# Monitor startup sequence
journalctl --user -b | grep -E "Started|Starting" | grep -E "heimdall|quickshell|docker"

# Check environment variables
env | grep -E "HEIMDALL|QS_|QUICKSHELL"

# Verify symlinks
ls -la ~/.local/state/heimdall/
ls -la ~/.config/heimdall/

# Test wallpaper setting
heimdall wallpaper -f ~/Pictures/Wallpapers/Autumn-Alley.jpg
cat ~/.local/state/quickshell/user/generated/wallpaper/path.txt

# Check Docker Desktop status
systemctl --user status docker-desktop.service
pgrep -f docker-desktop

# Monitor file changes
inotifywait -m ~/.local/state/quickshell/user/generated/wallpaper/

# Check display configuration
hyprctl monitors
hyprctl clients

# Verify shell configuration
heimdall shell -c "config.get"
```

## Summary

The migration issues from quickshell/ii to quickshell/heimdall are primarily caused by:

1. **Path Misalignment**: heimdall CLI and quickshell expect different state directories
2. **Incomplete Migration**: Session commands not properly configured with runtime values
3. **Missing Components**: No wallpaper daemon initialization in startup sequence
4. **Race Conditions**: Components starting before dependencies are ready
5. **Over-Engineering**: Docker Desktop startup unnecessarily complex

All issues are fixable with the solutions provided. The key is to:
- Align state directories between components
- Fix the logout command to use actual username
- Properly sequence startup with appropriate delays
- Simplify Docker Desktop startup
- Ensure wallpaper persistence through proper file writes

Implementation should follow the phased approach, with critical fixes first, followed by stability improvements and long-term alignment. Each phase should be tested thoroughly before proceeding to the next.