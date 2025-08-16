# Heimdall/Quickshell Startup Fixes

## Date: 2025-08-13

## Problem Description
The Heimdall Quickshell configuration was experiencing startup issues where:
- The panel would be visible but with no wallpaper (black background)
- State files were not being properly created or found
- Heimdall services were not starting correctly
- No proper error logging or diagnostics were available

## Solution Implementation

### 1. Enhanced Startup Orchestrator (`startup-orchestrator.sh`)

**Location:** `/home/arthur/dots/wm/.config/hypr/programs/startup-orchestrator.sh`

**Key Improvements:**
- Added comprehensive error logging to `/tmp/quickshell-startup-errors.log`
- Added color-coded console output for better visibility
- Implemented retry mechanisms for critical components
- Added verification functions for files and directories
- Enhanced state directory creation with proper error handling
- Added wallpaper state file verification and auto-repair
- Implemented proper Quickshell startup with `qs -c heimdall` command
- Added IPC communication testing
- Added final state verification and summary reporting

**Critical Features:**
- Verifies and creates all required state directories:
  - `~/.local/state/quickshell/user/generated/`
  - `~/.local/state/quickshell/user/generated/wallpaper/`
  - `~/.local/share/heimdall/`
- Ensures wallpaper path files exist in multiple locations for compatibility
- Properly starts Quickshell with the heimdall configuration
- Provides detailed logging of each step with success/failure indicators

### 2. Diagnostic Script (`check-heimdall-startup.sh`)

**Location:** `/home/arthur/dots/wm/.config/hypr/programs/check-heimdall-startup.sh`

**Features:**
- Comprehensive system check covering:
  - Environment variables (Wayland, XDG_RUNTIME_DIR)
  - Required commands and their versions
  - Running processes status
  - State directories and permissions
  - State files and their contents
  - Wallpaper status verification
  - Log file analysis
  - Heimdall IPC communication testing
  - System resource availability
- Color-coded output for easy issue identification
- Generates diagnostic report file with timestamp
- Provides specific recommendations for found issues
- Offers to run startup orchestrator if issues are detected

### 3. Enhanced Wallpaper Restoration (`restore-wallpaper.sh`)

**Location:** `/home/arthur/dots/wm/.config/hypr/programs/restore-wallpaper.sh`

**Improvements:**
- Checks multiple state file locations for compatibility
- Implements retry mechanism with up to 15 attempts
- Auto-starts swww-daemon if not running
- Verifies wallpaper was actually set after applying
- Provides detailed logging with timestamps
- Handles missing state files gracefully with fallback

### 4. Improved Wallpaper Sync (`wallpaper-sync.sh`)

**Location:** `/home/arthur/dots/wm/.config/hypr/programs/wallpaper-sync.sh`

**Enhancements:**
- Writes wallpaper path to all required locations:
  - `~/.local/state/quickshell/user/generated/wallpaper/path.txt`
  - `~/.local/share/heimdall/wallpaper_path`
  - `~/.local/state/heimdall/wallpaper/path.txt`
- Creates necessary symlinks for compatibility
- Optionally generates color scheme with heimdall
- Provides success/failure feedback for each operation

### 5. Manual Restart Script (`restart-heimdall.sh`)

**Location:** `/home/arthur/dots/wm/.config/hypr/programs/restart-heimdall.sh`

**Purpose:**
- Provides a clean way to restart Heimdall/Quickshell for testing
- Kills existing processes cleanly
- Verifies and repairs state files
- Starts all components in correct order
- Provides real-time status feedback

## Key State File Locations

The system maintains wallpaper state in multiple locations for compatibility:

1. **Primary Quickshell location:**
   - `~/.local/state/quickshell/user/generated/wallpaper/path.txt`

2. **Heimdall share location:**
   - `~/.local/share/heimdall/wallpaper_path`

3. **Legacy/compatibility location:**
   - `~/.local/state/heimdall/` (symlink to quickshell state)

## Usage Instructions

### Normal Startup
The enhanced `startup-orchestrator.sh` is automatically called by Hyprland on startup via:
```bash
exec-once = ~/.config/hypr/programs/startup-orchestrator.sh
```

### Manual Diagnostics
Run the diagnostic script to check system status:
```bash
~/.config/hypr/programs/check-heimdall-startup.sh
```

### Manual Restart
To restart Heimdall/Quickshell manually:
```bash
~/.config/hypr/programs/restart-heimdall.sh
```

### Check Logs
View startup logs:
```bash
# Main startup log
cat /tmp/quickshell-startup.log

# Error log (if exists)
cat /tmp/quickshell-startup-errors.log

# Latest diagnostic report
ls -lt /tmp/heimdall-diagnostic-*.log | head -1
```

## Troubleshooting

### If wallpaper doesn't appear:
1. Run the diagnostic script to identify issues
2. Check if swww-daemon is running: `pgrep -x swww-daemon`
3. Verify wallpaper file exists: `cat ~/.local/state/quickshell/user/generated/wallpaper/path.txt`
4. Manually set wallpaper: `swww img /path/to/wallpaper.jpg`

### If Quickshell doesn't start:
1. Check if process is running: `pgrep -f quickshell`
2. Try manual start: `qs -c heimdall`
3. Check error log: `tail -50 /tmp/quickshell-startup-errors.log`

### If state files are missing:
1. Run: `~/.config/hypr/programs/wallpaper-sync.sh /path/to/wallpaper.jpg`
2. This will create all necessary state files

## Testing Recommendations

After making these changes:

1. **Test immediate restart:**
   ```bash
   ~/.config/hypr/programs/restart-heimdall.sh
   ```

2. **Run diagnostics:**
   ```bash
   ~/.config/hypr/programs/check-heimdall-startup.sh
   ```

3. **Test full reboot:**
   - Reboot the system
   - Check `/tmp/quickshell-startup.log` after login
   - Verify wallpaper appears
   - Verify panel/shell components are working

4. **Monitor for errors:**
   ```bash
   tail -f /tmp/quickshell-startup-errors.log
   ```

## Summary

These enhancements provide:
- Robust error handling and recovery
- Comprehensive logging and diagnostics
- Multiple fallback mechanisms
- Clear visibility into startup issues
- Easy troubleshooting tools

The main issue was that Quickshell wasn't being started properly and state files weren't being created in all required locations. The enhanced scripts now ensure proper initialization order, verify all components, and provide detailed feedback for troubleshooting.