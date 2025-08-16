# Hyprland UWSM Monitor Issues Research

## Executive Summary
Research into Hyprland configuration issues when using UWSM (Universal Wayland Session Manager) reveals significant differences in session management, environment handling, and startup sequences that can cause monitor shutdown and blank screen issues.

## Key Findings

### Source: [UWSM GitHub Repository](https://github.com/Vladimir-csp/uwsm)
**Relevance**: Official documentation for understanding UWSM architecture and requirements
**Key Points**:
- UWSM wraps Wayland compositors into systemd units for robust session management
- Provides environment management, XDG autostart support, and bi-directional binding with login session
- Requires specific startup notification from compositor via `uwsm finalize` command
- Uses `Type=notify` systemd service requiring explicit readiness signal
- Manages environment variables through systemd activation environment
**Code Examples**:
```bash
# Required for compositor startup notification
exec uwsm finalize WAYLAND_DISPLAY DISPLAY
```
**Caveats**: 
- Advanced user tool with additional quirks
- Requires dbus-broker for proper environment cleanup
- 10-second timeout for unit startup

### Source: [Hyprland Wiki - Systemd Startup](https://wiki.hyprland.org/Useful-Utilities/Systemd-start/)
**Relevance**: Official Hyprland documentation for UWSM integration
**Key Points**:
- UWSM available in Arch repositories as `uwsm`
- Requires launching apps via `uwsm app --` prefix to run as systemd units
- XDG Autostart handled by systemd automatically
- Display managers show "Hyprland (uwsm-managed)" entry
**Code Examples**:
```bash
# Shell profile integration
if uwsm check may-start && uwsm select; then
    exec uwsm start default
fi

# Hyprland config for app launching
exec-once = uwsm app -- mycommand --arg1
bind = SUPER, E, exec, uwsm app -- pcmanfm-qt.desktop
```
**Caveats**: Issues with environment variables, multi-GPU setups, and dispatchers

### Source: User's Hyprland Configuration Analysis
**Relevance**: Current configuration may have compatibility issues with UWSM
**Key Points**:
- Complex startup orchestrator script (`startup-orchestrator.sh`) manages initialization
- Multiple monitor configuration (3 monitors via HDMI-A-1, DP-1, DP-3)
- Quickshell/Heimdall integration with state management
- Custom environment preloader and systemd integration already present
- Uses `systemctl --user import-environment` and `dbus-update-activation-environment`
**Code Examples**:
```bash
# From execs.conf
exec-once = systemctl --user import-environment $(env | grep -E '^(XDG_|WAYLAND_|DISPLAY|...)' | cut -d= -f1)
exec-once = dbus-update-activation-environment --systemd $(env | grep -E '^(XDG_|WAYLAND_|DISPLAY|...)' | cut -d= -f1)
exec-once = systemctl --user start graphical-session.target
```
**Caveats**: Potential conflict between custom startup orchestrator and UWSM's session management

## Critical Differences: Normal vs UWSM Session

### 1. **Session Management Architecture**
- **Normal Hyprland**: Direct process execution, compositor manages its own lifecycle
- **UWSM Session**: Systemd-managed units with dependency chains and proper shutdown sequences

### 2. **Environment Variable Handling**
- **Normal**: Environment inherited from shell, exported via Hyprland config
- **UWSM**: Environment managed through systemd activation environment, requires explicit export

### 3. **Startup Sequence**
- **Normal**: 
  1. Shell → Hyprland binary
  2. Hyprland sources config
  3. exec-once commands run directly
- **UWSM**:
  1. Shell → uwsm start
  2. Systemd units activated
  3. Environment preloader service
  4. Compositor service (Type=notify)
  5. Wait for WAYLAND_DISPLAY signal
  6. graphical-session.target activation

### 4. **Monitor Initialization Timing**
- **Normal**: Monitors initialized immediately when Hyprland starts
- **UWSM**: Potential race condition between monitor initialization and systemd readiness notification

## Identified Issues Causing Monitor Shutdown

### 1. **Missing Startup Notification**
The user's Hyprland configuration lacks `uwsm finalize` command, causing:
- Systemd to timeout waiting for service readiness
- Potential premature shutdown of compositor unit
- Monitor outputs being disabled during cleanup

### 2. **Conflicting Startup Scripts**
The `startup-orchestrator.sh` script:
- Manages its own systemd integration
- May conflict with UWSM's environment management
- Creates duplicate graphical-session.target activation

### 3. **Environment Variable Race Conditions**
Critical variables may not be available when needed:
- `WAYLAND_DISPLAY` not exported to systemd in time
- Display-related environment variables missing during monitor initialization
- Quickshell/Heimdall starting before proper environment setup

### 4. **Systemd Service Dependencies**
Incorrect service ordering can cause:
- Display portal services starting too early
- Monitor configuration applied before compositor ready
- Graphics drivers not fully initialized

## Potential Solutions

### 1. **Add UWSM Finalization**
Add to Hyprland config:
```bash
exec-once = uwsm finalize WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE
```

### 2. **Disable Conflicting Scripts**
When using UWSM, disable:
- Custom startup-orchestrator.sh
- Manual systemd environment imports
- Direct graphical-session.target activation

### 3. **Configure UWSM Wait Variables**
Set environment variables for UWSM to wait for:
```bash
export UWSM_WAIT_VARNAMES="WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE"
export UWSM_WAIT_VARNAMES_SETTLETIME=0.5
```

### 4. **Monitor-Specific Configuration**
Ensure monitor configuration happens after compositor initialization:
```bash
exec-once = sleep 1 && hyprctl dispatch dpms on
```

### 5. **Use UWSM App Launcher**
Replace all `exec` and `exec-once` with UWSM equivalents:
```bash
exec-once = uwsm app -- ~/.config/hypr/programs/restore-wallpaper.sh
```

## Additional Observations

### Crash Log Analysis
The systemd journal shows Hyprland crashes related to layer surface animations, suggesting:
- Quickshell/Heimdall components may be unmapping during shutdown
- Potential race condition in cleanup sequence
- Need for proper shutdown ordering

### Current Monitor Status
All three monitors are currently active and working in normal (non-UWSM) mode:
- HDMI-A-1: 1920x1200@119.91Hz
- DP-1: 2560x1440@75.00Hz  
- DP-3: 2560x1440@144.00Hz (VRR enabled)

## Recommendations

1. **Test Minimal UWSM Configuration**: Start with basic Hyprland config without custom scripts
2. **Gradual Migration**: Move components to UWSM management one at a time
3. **Monitor Systemd Logs**: Use `journalctl --user -u wayland-wm@*.service -f` during testing
4. **Verify Environment**: Check `systemctl --user show-environment` for required variables
5. **Consider Alternative**: If issues persist, consider using Hyprland's native session management

## Conclusion

The monitor shutdown issues in UWSM mode likely stem from:
1. Missing startup notification causing systemd timeout
2. Conflicting session management between custom scripts and UWSM
3. Race conditions in environment variable availability
4. Improper shutdown sequencing of graphical components

Proper UWSM integration requires significant changes to the existing Hyprland configuration, particularly removing custom systemd integration in favor of UWSM's managed approach.