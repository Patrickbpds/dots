# UWSM Hyprland Monitor Blackout Research - Enhanced

## Executive Summary
Comprehensive research into the Hyprland UWSM monitor blackout issue reveals that the problem stems from missing startup notification in the Hyprland configuration. UWSM (Universal Wayland Session Manager) requires explicit notification when the compositor is ready, which is currently absent in the user's configuration.

## Key Findings

### Source: [UWSM GitHub Repository](https://github.com/Vladimir-csp/uwsm)
**Relevance**: Official documentation and implementation details
**Key Points**:
- UWSM version 0.23.1 is installed on the system at `/usr/bin/uwsm`
- Uses `Type=notify` systemd service requiring explicit readiness signal via `uwsm finalize`
- 10-second timeout for unit startup (TimeoutStartSec=10)
- Service waits for `WAYLAND_DISPLAY` and variables listed in `UWSM_WAIT_VARNAMES`
- Hyprland plugin automatically adds `HYPRLAND_INSTANCE_SIGNATURE` to wait variables
**Code Examples**:
```bash
# From /usr/share/uwsm/plugins/hyprland.sh
UWSM_FINALIZE_VARNAMES="${UWSM_FINALIZE_VARNAMES}${UWSM_FINALIZE_VARNAMES:+ }HYPRLAND_INSTANCE_SIGNATURE HYPRLAND_CMD HYPRCURSOR_THEME HYPRCURSOR_SIZE XCURSOR_SIZE XCURSOR_THEME"
UWSM_WAIT_VARNAMES="${UWSM_WAIT_VARNAMES}${UWSM_WAIT_VARNAMES:+ }HYPRLAND_INSTANCE_SIGNATURE"
```
**Caveats**: Advanced user tool with additional quirks and complexity

### Source: [Hyprland Wiki - Systemd Startup](https://wiki.hyprland.org/Useful-Utilities/Systemd-start/)
**Relevance**: Official Hyprland documentation for UWSM integration
**Key Points**:
- UWSM available in Arch repositories as `uwsm`
- Applications must be launched with `uwsm app --` prefix
- XDG Autostart handled automatically by systemd
- Display managers show "Hyprland (uwsm-managed)" entry
- Known issues with environment variables, multi-GPU setups, and dispatchers
**Code Examples**:
```bash
# Required in Hyprland config
exec-once = uwsm app -- mycommand --arg1
bind = SUPER, E, exec, uwsm app -- pcmanfm-qt.desktop
```
**Caveats**: Documentation warns about compatibility issues but doesn't emphasize the critical `uwsm finalize` requirement

### Source: System Analysis - UWSM Installation
**Relevance**: Current system state and configuration
**Key Points**:
- UWSM 0.23.1 installed at `/usr/bin/uwsm`
- No user configuration found in `~/.config/uwsm/` or `~/.local/share/uwsm/`
- Systemd unit templates present in `/usr/lib/systemd/user/`
- Hyprland UWSM desktop entry exists: `/usr/share/wayland-sessions/hyprland-uwsm.desktop`
- UWSM not currently active (status code 2)
**Code Examples**:
```ini
# /usr/share/wayland-sessions/hyprland-uwsm.desktop
[Desktop Entry]
Name=Hyprland (uwsm-managed)
Comment=An intelligent dynamic tiling Wayland compositor
Exec=uwsm start -- hyprland.desktop
TryExec=uwsm
DesktopNames=Hyprland
Type=Application
```
**Caveats**: System has UWSM properly installed but lacks user-specific configuration

### Source: User's Hyprland Configuration Analysis
**Relevance**: Current configuration incompatible with UWSM requirements
**Key Points**:
- **CRITICAL**: No `uwsm finalize` command in any Hyprland configuration files
- Complex startup orchestrator script manages initialization
- Custom systemd integration conflicts with UWSM's approach
- Startup orchestrator waits for Wayland display but doesn't notify systemd
- No references to UWSM in any configuration files
**Code Examples**:
```bash
# Current execs.conf - Missing critical UWSM finalization
exec-once = ~/.config/hypr/programs/startup-orchestrator.sh
exec-once = fcitx5
exec-once = /usr/lib/polkit-kde-authentication-agent-1
# Commented out systemd integration that conflicts with UWSM:
# exec-once = systemctl --user import-environment ...
# exec-once = dbus-update-activation-environment ...
```
**Caveats**: Extensive custom startup logic needs adaptation for UWSM compatibility

### Source: Systemd Service Template Analysis
**Relevance**: Understanding UWSM's expectations
**Key Points**:
- `wayland-wm@.service` uses `Type=notify` with `NotifyAccess=all`
- Service expects notification from compositor's child process
- Timeout of 10 seconds before service is considered failed
- Service runs in `session.slice` for priority resource allocation
- Proper shutdown sequence via `wayland-session-shutdown.target`
**Code Examples**:
```ini
# From /usr/lib/systemd/user/wayland-wm@.service
[Service]
Type=notify
NotifyAccess=all
ExecStart=/usr/bin/uwsm aux exec -- %I
TimeoutStartSec=10
TimeoutStopSec=10
```
**Caveats**: Strict timing requirements can cause issues if compositor initialization is slow

## Root Cause Analysis

### Primary Issue: Missing Startup Notification
The user's Hyprland configuration completely lacks the `uwsm finalize` command, which is **mandatory** for UWSM operation. Without this:
1. Systemd waits for readiness notification that never comes
2. After 10 seconds, the service times out
3. Systemd considers the service failed and initiates shutdown
4. Monitors receive DPMS off signal during cleanup, causing blackout

### Secondary Issues

#### 1. Conflicting Startup Management
The `startup-orchestrator.sh` script:
- Manages its own environment and systemd integration
- Waits for Wayland display but doesn't notify systemd
- Creates potential race conditions with UWSM's environment management
- Runs Quickshell/Heimdall without UWSM app management

#### 2. Environment Variable Handling
- UWSM expects to manage environment variables through systemd
- Current configuration manually exports variables
- Potential conflicts between manual and UWSM-managed environments

#### 3. Application Launch Method
- Current config launches apps directly via `exec-once`
- UWSM requires apps to be launched via `uwsm app --` for proper session management
- Direct launching bypasses UWSM's slice management

## Configuration Differences

### Working Non-UWSM Session
1. Hyprland starts directly
2. Startup orchestrator manages initialization
3. Environment variables exported manually
4. Applications launched as child processes
5. No systemd service management

### Failed UWSM Session
1. UWSM starts Hyprland as systemd service
2. Service waits for notification (missing)
3. Timeout after 10 seconds
4. Service marked as failed
5. Cleanup initiated, monitors disabled

## Solution Requirements

### Immediate Fix
Add to beginning of `~/.config/hypr/hyprland/execs.conf`:
```bash
# CRITICAL: Notify UWSM that Hyprland is ready
exec-once = uwsm finalize WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
```

### Complete Solution
1. **Create UWSM-compatible configuration**
2. **Modify startup orchestrator** to detect and skip in UWSM sessions
3. **Convert app launches** to use `uwsm app --`
4. **Remove conflicting systemd commands**
5. **Test with minimal configuration first**

## Testing Strategy

### Phase 1: Minimal Test
Create `~/.config/hypr/hyprland-uwsm-test.conf`:
```bash
monitor=,preferred,auto,1
exec-once = uwsm finalize WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE
env = XCURSOR_SIZE,24
bind = SUPER, Q, killactive
bind = SUPER, Return, exec, uwsm app -- foot
bind = SUPER SHIFT, E, exit
```

### Phase 2: Progressive Integration
1. Test with single monitor first
2. Add monitors one by one
3. Integrate essential services
4. Finally add Quickshell/Heimdall

## Monitoring and Debugging

### Real-time Monitoring Commands
```bash
# Watch UWSM service status
watch -n 1 'systemctl --user status wayland-wm@Hyprland.service'

# Monitor systemd journal
journalctl --user -u wayland-wm@Hyprland.service -f

# Check environment variables
systemctl --user show-environment | grep WAYLAND

# Verify UWSM session status
uwsm check active
```

### Debug Environment Variables
```bash
export HYPRLAND_LOG_WLR=1
export UWSM_LOG_LEVEL=debug
export UWSM_WAIT_VARNAMES_SETTLETIME=1
```

## Additional Observations

### UWSM Plugin Behavior
The Hyprland UWSM plugin (`/usr/share/uwsm/plugins/hyprland.sh`):
- Automatically configures required environment variables
- Adds Hyprland-specific variables to finalize and wait lists
- Manages XDG_CURRENT_DESKTOP properly
- No user configuration needed for basic operation

### Desktop Entry Configuration
The `hyprland-uwsm.desktop` entry:
- Properly configured for display manager use
- Uses `uwsm start -- hyprland.desktop` format
- Sets correct DesktopNames for session

## Recommendations

### Immediate Actions
1. **Add `uwsm finalize` to Hyprland config** - Critical first step
2. **Test with minimal configuration** - Verify basic functionality
3. **Monitor systemd journals** - Identify any remaining issues

### Long-term Improvements
1. **Create dedicated UWSM configuration** - Separate from non-UWSM config
2. **Refactor startup orchestrator** - Make UWSM-aware
3. **Document configuration changes** - Maintain compatibility notes
4. **Consider upstream contribution** - Share fixes with community

## Conclusion

The monitor blackout issue is definitively caused by the missing `uwsm finalize` command in the Hyprland configuration. This prevents the systemd service from receiving the required readiness notification, causing a timeout and subsequent cleanup that disables monitor outputs. The solution is straightforward but requires careful implementation due to the complex existing startup orchestration. A phased approach starting with minimal configuration and progressively adding features is recommended to ensure stability.