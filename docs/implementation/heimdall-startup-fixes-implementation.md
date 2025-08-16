# Heimdall Startup Fixes Implementation

## Problem Summary
Heimdall/Quickshell was failing during boot with errors:
1. Missing `/home/arthur/.local/state/quickshell/user/generated/scheme.json`
2. Missing state directories and files
3. Environment/timing issues during boot vs manual startup

## Root Cause
The issue was that during boot, state files don't exist yet and heimdall couldn't create them on the fly. The startup sequence needed proper initialization and environment setup.

## Implemented Solutions

### 1. State Initialization Script (`init-heimdall-state.sh`)
Created comprehensive state initialization script that:
- Creates all required directories:
  - `~/.local/state/quickshell/user/generated/`
  - `~/.local/state/quickshell/user/generated/wallpaper/`
  - `~/.local/share/heimdall/`
- Generates initial state files:
  - `scheme.json` - Color scheme configuration
  - `colors.json` - Color definitions
  - `wallpaper/path.txt` - Current wallpaper path
  - `theme.json` - Theme configuration
  - `color.txt` - Primary color
- Creates compatibility symlinks between quickshell and heimdall directories
- Finds or generates color schemes (with matugen support)
- Sets proper file permissions

### 2. Updated Startup Orchestrator (`startup-orchestrator.sh`)
Enhanced the startup sequence with:
- **Environment Setup**: Exports all required XDG and Qt variables
- **Hyprland Ready Check**: Waits for Hyprland to be fully initialized
- **State Initialization**: Runs init-heimdall-state.sh before starting services
- **Improved Daemon Commands**: Uses correct `heimdall shell daemon` syntax
- **Better Error Handling**: Comprehensive logging and fallback methods
- **Multiple Start Methods**: Tries different quickshell/qs command formats

Key environment variables added:
```bash
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export QT_QPA_PLATFORM="wayland"
export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
export HEIMDALL_STATE_DIR="$HOME/.local/state/quickshell/user/generated"
export HEIMDALL_SHARE_DIR="$HOME/.local/share/heimdall"
```

### 3. Helper Scripts

#### `check-heimdall-env.sh`
Diagnostic script that checks:
- Current environment variables
- Process context (interactive vs startup)
- Binary locations and versions
- Required directories and files
- Running processes
- Missing binaries

#### `restart-heimdall.sh` (Updated)
Manual restart script with:
- Proper state initialization
- Environment variable setup
- Correct daemon commands
- Status verification

#### `test-heimdall-startup.sh`
Test script for validating the startup sequence without rebooting

### 4. File Structure Created

```
~/.local/state/
├── quickshell/
│   └── user/
│       └── generated/
│           ├── scheme.json
│           ├── colors.json
│           ├── color.txt
│           ├── theme.json
│           ├── current_wallpaper
│           └── wallpaper/
│               └── path.txt
└── heimdall/ -> quickshell/user/generated/ (symlink)

~/.local/share/
└── heimdall/
    ├── scheme.json
    ├── colors.json
    └── wallpaper_path
```

## Startup Flow

1. **Hyprland starts** → executes `startup-orchestrator.sh`
2. **Environment setup** → Export XDG and Qt variables
3. **Wait for Hyprland** → Ensure compositor is ready
4. **Initialize state** → Run `init-heimdall-state.sh`
5. **Start wallpaper daemon** → swww-daemon or hyprpaper
6. **Restore wallpaper** → From saved state
7. **Start Quickshell** → With heimdall configuration
8. **Start heimdall daemon** → If available
9. **Verify startup** → Check processes and IPC

## Testing

To test the fixes without rebooting:
```bash
# Run diagnostic
~/.config/hypr/programs/check-heimdall-env.sh

# Test startup sequence
~/.config/hypr/programs/test-heimdall-startup.sh

# Manual restart
~/.config/hypr/programs/restart-heimdall.sh
```

## Logs

Startup logs are available at:
- `/tmp/quickshell-startup.log` - Main startup log
- `/tmp/quickshell-startup-errors.log` - Error log

## Notes

- The `/usr/lib/heimdall/beat_detector` binary is missing but appears to be optional
- Heimdall daemon may be integrated into quickshell itself
- State files are duplicated across multiple locations for compatibility
- The initialization script is idempotent and can be run multiple times safely