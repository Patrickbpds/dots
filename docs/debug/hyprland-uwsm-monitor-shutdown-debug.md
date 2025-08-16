# Hyprland UWSM Monitor Shutdown Debug Investigation
Severity: **High**

## Issue Description

### Symptoms
- Monitors shut down immediately after UWSM session start
- Black/blank screens with no display output
- System appears to be running but no visual output
- Issue only occurs with UWSM-managed sessions
- Normal Hyprland sessions work correctly

### Impact
- Complete loss of graphical interface when using UWSM
- Unable to use systemd-managed Wayland session
- Forced to use legacy session management

### Frequency
- Consistent: Occurs every time UWSM session is started
- Environment-specific: Only affects UWSM mode

## Investigation Plan

### Phase 1: Information Gathering

#### 1.1 Check Current Session Status
```bash
# Check if currently in UWSM session
uwsm check active
echo "UWSM active: $?"

# Check systemd user session status
systemctl --user status

# List all UWSM-related services
systemctl --user list-units '*uwsm*' '*wayland*' '*graphical*'

# Check for failed services
systemctl --user --failed
```

#### 1.2 Collect System Logs
```bash
# Create debug directory
mkdir -p ~/uwsm-debug
cd ~/uwsm-debug

# Export current timestamp
export DEBUG_TIME=$(date +%Y%m%d_%H%M%S)

# Collect systemd journal (last boot)
journalctl --user -b 0 > journal_user_${DEBUG_TIME}.log
journalctl -b 0 > journal_system_${DEBUG_TIME}.log

# Collect UWSM-specific logs
journalctl --user -u 'wayland-wm@*' -n 1000 > uwsm_service_${DEBUG_TIME}.log
journalctl --user -u 'wayland-session-pre@*' -n 1000 > uwsm_pre_${DEBUG_TIME}.log
journalctl --user -u 'wayland-session@*' -n 1000 > uwsm_session_${DEBUG_TIME}.log

# Collect Hyprland crash logs if they exist
cp ~/.local/share/hyprland/hyprlandCrashReport*.txt . 2>/dev/null || echo "No crash reports found"

# Check environment variables
systemctl --user show-environment > environment_${DEBUG_TIME}.txt
```

#### 1.3 Monitor Configuration Analysis
```bash
# Check current monitor status (if in working session)
hyprctl monitors -j > monitors_current.json

# Check monitor configuration
grep -E "monitor\s*=" ~/.config/hypr/hyprland/*.conf > monitor_config.txt

# Check DRM/KMS status
sudo dmesg | grep -E "(drm|amdgpu|nvidia|intel|monitor|HDMI|DP)" > drm_status.txt

# List connected displays
ls -la /sys/class/drm/*/status | xargs -I {} sh -c 'echo -n "{}: "; cat {}' > display_status.txt
```

### Phase 2: Systematic Testing

#### 2.1 Test Minimal UWSM Configuration

Create a minimal test configuration:

```bash
# Backup current configuration
cp -r ~/.config/hypr ~/.config/hypr.backup.${DEBUG_TIME}

# Create minimal test config
cat > ~/.config/hypr/hyprland-uwsm-test.conf << 'EOF'
# Minimal UWSM-compatible Hyprland config
monitor=,preferred,auto,1

# CRITICAL: UWSM startup notification
exec-once = uwsm finalize WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP

# Basic environment setup (let UWSM handle most of it)
env = XCURSOR_SIZE,24
env = GDK_BACKEND,wayland,x11
env = QT_QPA_PLATFORM,wayland;xcb

# Simple keybinds for testing
bind = SUPER, Q, killactive
bind = SUPER, Return, exec, uwsm app -- foot
bind = SUPER SHIFT, E, exit

# Basic window rules
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
}

# Minimal decoration
decoration {
    rounding = 10
    blur {
        enabled = false
    }
}

# Basic input
input {
    kb_layout = us
    follow_mouse = 1
}
EOF

# Create UWSM launch script
cat > ~/test-uwsm-hyprland.sh << 'EOF'
#!/bin/bash
# Test UWSM Hyprland launch with debugging

# Enable debug output
export HYPRLAND_LOG_WLR=1
export UWSM_LOG_LEVEL=debug

# Set wait variables for UWSM
export UWSM_WAIT_VARNAMES="WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE"
export UWSM_WAIT_VARNAMES_SETTLETIME=1

# Use test config
export HYPRLAND_CONFIG_FILE=~/.config/hypr/hyprland-uwsm-test.conf

# Start with UWSM
exec uwsm start -D Hyprland
EOF

chmod +x ~/test-uwsm-hyprland.sh
```

#### 2.2 Monitor-Specific Testing

Test each monitor individually:

```bash
# Test HDMI-A-1 only
cat > ~/.config/hypr/test-hdmi.conf << 'EOF'
monitor=HDMI-A-1,1920x1200@120,0x0,1
monitor=DP-1,disable
monitor=DP-3,disable

exec-once = uwsm finalize WAYLAND_DISPLAY DISPLAY
exec-once = sleep 2 && hyprctl dispatch dpms on HDMI-A-1
EOF

# Test DP-1 only
cat > ~/.config/hypr/test-dp1.conf << 'EOF'
monitor=DP-1,2560x1440@75,0x0,1
monitor=HDMI-A-1,disable
monitor=DP-3,disable

exec-once = uwsm finalize WAYLAND_DISPLAY DISPLAY
exec-once = sleep 2 && hyprctl dispatch dpms on DP-1
EOF

# Test DP-3 only
cat > ~/.config/hypr/test-dp3.conf << 'EOF'
monitor=DP-3,2560x1440@144,0x0,1,vrr,1
monitor=HDMI-A-1,disable
monitor=DP-1,disable

exec-once = uwsm finalize WAYLAND_DISPLAY DISPLAY
exec-once = sleep 2 && hyprctl dispatch dpms on DP-3
EOF
```

#### 2.3 Service Dependency Testing

Create custom systemd service for debugging:

```bash
# Create debug service
cat > ~/.config/systemd/user/hyprland-debug.service << 'EOF'
[Unit]
Description=Hyprland Debug Service
After=wayland-session-pre@Hyprland.target
Before=wayland-session@Hyprland.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'echo "=== HYPRLAND DEBUG START ===" | systemd-cat -t hyprland-debug'
ExecStart=/bin/bash -c 'systemctl --user show-environment | systemd-cat -t hyprland-debug'
ExecStart=/bin/bash -c 'ls -la /sys/class/drm/*/status | xargs -I {} sh -c "echo -n \"{}: \"; cat {}"' | systemd-cat -t hyprland-debug'
ExecStart=/bin/bash -c 'echo "=== HYPRLAND DEBUG END ===" | systemd-cat -t hyprland-debug'

[Install]
WantedBy=wayland-session@Hyprland.target
EOF

# Enable debug service
systemctl --user daemon-reload
systemctl --user enable hyprland-debug.service
```

### Phase 3: Real-Time Debugging

#### 3.1 Live Monitoring Setup

Open multiple terminals (TTY) for monitoring:

**Terminal 1 - System Journal:**
```bash
# Switch to TTY2 (Ctrl+Alt+F2)
journalctl -f
```

**Terminal 2 - User Journal:**
```bash
# Switch to TTY3 (Ctrl+Alt+F3)
journalctl --user -f
```

**Terminal 3 - UWSM Service:**
```bash
# Switch to TTY4 (Ctrl+Alt+F4)
watch -n 1 'systemctl --user status wayland-wm@Hyprland.service'
```

**Terminal 4 - Monitor Status:**
```bash
# Switch to TTY5 (Ctrl+Alt+F5)
watch -n 1 'cat /sys/class/drm/*/status 2>/dev/null | grep -c connected'
```

#### 3.2 Start UWSM Session with Debugging

```bash
# From TTY1, start UWSM with maximum debugging
export HYPRLAND_LOG_WLR=1
export UWSM_LOG_LEVEL=debug
export WAYLAND_DEBUG=1

# Start and capture output
uwsm start -D Hyprland 2>&1 | tee ~/uwsm-start-debug.log
```

### Phase 4: Root Cause Analysis

#### 4.1 Check for Timeout Issues

```bash
# Check if service is timing out
journalctl --user -u wayland-wm@Hyprland.service | grep -E "(timeout|Timeout|TIMEOUT)"

# Check service configuration
systemctl --user cat wayland-wm@Hyprland.service

# Check for missing finalize
journalctl --user -u wayland-wm@Hyprland.service | grep -E "(finalize|notify|ready)"
```

#### 4.2 Environment Variable Issues

```bash
# During UWSM session attempt, check environment
systemctl --user show-environment | grep -E "WAYLAND_DISPLAY|DISPLAY|HYPRLAND"

# Check if variables are being exported
journalctl --user -u wayland-session-pre@Hyprland.service | grep -E "export|environment"
```

#### 4.3 Graphics Driver Issues

```bash
# Check for GPU errors
sudo dmesg | grep -E "(gpu|GPU|drm|DRM)" | tail -50

# Check for mode setting issues
sudo journalctl -b 0 | grep -E "(modeset|modesetting|CRTC|crtc)"

# Verify GPU is active
cat /sys/class/drm/card*/device/power_state
```

## Solution Implementation

### Fix 1: Add UWSM Finalization

**File:** `~/.config/hypr/hyprland/execs.conf`

```bash
# Add at the beginning of exec-once commands
exec-once = uwsm finalize WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP XDG_SESSION_TYPE

# Comment out conflicting systemd commands
#exec-once = systemctl --user import-environment ...
#exec-once = dbus-update-activation-environment ...
#exec-once = systemctl --user start graphical-session.target
```

### Fix 2: Disable Startup Orchestrator for UWSM

**File:** `~/.config/hypr/programs/startup-orchestrator.sh`

```bash
#!/bin/bash
# Add UWSM detection at the beginning
if uwsm check active; then
    echo "UWSM session detected, skipping orchestrator"
    exit 0
fi

# ... rest of the original script ...
```

### Fix 3: Create UWSM-Compatible Configuration

**File:** `~/.config/hypr/hyprland-uwsm.conf`

```bash
# UWSM-compatible Hyprland configuration
source = ~/.config/hypr/hyprland/monitors.conf
source = ~/.config/hypr/hyprland/settings.conf
source = ~/.config/hypr/hyprland/rules.conf
source = ~/.config/hypr/hyprland/keybinds.conf
source = ~/.config/hypr/hyprland/theme.conf

# UWSM-specific initialization
exec-once = uwsm finalize WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP

# Use UWSM app launcher for all programs
exec-once = uwsm app -- ~/.config/hypr/programs/restore-wallpaper.sh
exec-once = uwsm app -- /usr/lib/polkit-kde-authentication-agent-1
exec-once = uwsm app -- hypridle

# Delay monitor-dependent programs
exec-once = sleep 2 && uwsm app -- quickshell -c ~/.config/quickshell/heimdall/shell.qml

# Remove or comment out these lines:
# exec-once = ~/.config/hypr/programs/startup-orchestrator.sh
# exec-once = systemctl --user import-environment ...
# exec-once = dbus-update-activation-environment ...
```

### Fix 4: Configure UWSM Environment

**File:** `~/.config/uwsm/env`

```bash
# UWSM environment configuration
UWSM_WAIT_VARNAMES="WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE"
UWSM_WAIT_VARNAMES_SETTLETIME=1
UWSM_FINALIZE_VARNAMES="WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"

# Hyprland-specific
HYPRLAND_LOG_WLR=0
HYPRLAND_NO_RT=1

# Graphics settings
WLR_DRM_NO_ATOMIC=1
WLR_NO_HARDWARE_CURSORS=1
```

### Fix 5: Create Fallback Script

**File:** `~/hyprland-launcher.sh`

```bash
#!/bin/bash
# Intelligent Hyprland launcher with UWSM fallback

echo "Hyprland Launcher - Detecting best launch method..."

# Function to test UWSM
test_uwsm() {
    if ! command -v uwsm &> /dev/null; then
        return 1
    fi
    
    # Check if UWSM services are available
    if ! systemctl --user list-unit-files | grep -q "wayland-wm@.service"; then
        return 1
    fi
    
    # Check for known issues
    if [ -f ~/.config/hypr/disable-uwsm ]; then
        echo "UWSM disabled by user preference"
        return 1
    fi
    
    return 0
}

# Try UWSM first
if test_uwsm; then
    echo "Starting Hyprland with UWSM..."
    
    # Set environment for UWSM
    export UWSM_WAIT_VARNAMES="WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE"
    export UWSM_WAIT_VARNAMES_SETTLETIME=1
    
    # Use UWSM config if it exists
    if [ -f ~/.config/hypr/hyprland-uwsm.conf ]; then
        export HYPRLAND_CONFIG_FILE=~/.config/hypr/hyprland-uwsm.conf
    fi
    
    exec uwsm start -D Hyprland
else
    echo "Starting Hyprland directly (UWSM not available or disabled)..."
    exec Hyprland
fi
```

## Validation

### Test 1: Verify UWSM Finalization
```bash
# Start UWSM session and check for finalization
uwsm start -D Hyprland &
sleep 5
journalctl --user -u wayland-wm@Hyprland.service | grep "finalize"
# Expected: Should see "uwsm finalize" execution
```

### Test 2: Monitor Activation
```bash
# After UWSM start, check monitor status
hyprctl monitors
# Expected: All three monitors should be listed and active
```

### Test 3: Service Status
```bash
# Check all UWSM services are running
systemctl --user status wayland-wm@Hyprland.service
systemctl --user status wayland-session@Hyprland.target
# Expected: All services should be "active (running)" or "active (exited)"
```

### Test 4: Environment Variables
```bash
# Verify critical environment variables
systemctl --user show-environment | grep -E "WAYLAND_DISPLAY|DISPLAY"
# Expected: Both variables should be set with valid values
```

### Performance Impact
- UWSM adds ~1-2 seconds to startup time
- Systemd management provides better crash recovery
- Resource usage is comparable to direct launch

## Prevention

### Recommendations

1. **Always Test Configuration Changes**
   - Use minimal config first
   - Add components incrementally
   - Monitor logs during testing

2. **Maintain Dual Configurations**
   - Keep working non-UWSM config as backup
   - Create separate UWSM-specific config
   - Use launcher script to select appropriate mode

3. **Monitor System Updates**
   - UWSM updates may change requirements
   - Hyprland updates may affect compatibility
   - Keep changelog notes for both

4. **Documentation**
   - Document any custom modifications
   - Keep notes on what works/doesn't work
   - Share findings with community

### Monitoring

Set up monitoring for UWSM sessions:

```bash
# Create monitoring script
cat > ~/.config/hypr/monitor-uwsm.sh << 'EOF'
#!/bin/bash
# Monitor UWSM session health

while true; do
    if uwsm check active; then
        # Check service status
        if ! systemctl --user is-active wayland-wm@Hyprland.service &>/dev/null; then
            notify-send -u critical "UWSM Error" "Hyprland service failed"
            systemctl --user status wayland-wm@Hyprland.service > /tmp/uwsm-error.log
        fi
        
        # Check monitors
        MONITOR_COUNT=$(hyprctl monitors -j 2>/dev/null | jq length)
        if [ "$MONITOR_COUNT" -lt 3 ]; then
            notify-send -u warning "Monitor Issue" "Only $MONITOR_COUNT monitors active"
        fi
    fi
    sleep 30
done
EOF

chmod +x ~/.config/hypr/monitor-uwsm.sh
```

## Quick Reference Commands

```bash
# Check UWSM status
uwsm check active

# View UWSM logs
journalctl --user -u wayland-wm@Hyprland.service -f

# Restart UWSM session
systemctl --user restart wayland-wm@Hyprland.service

# Stop UWSM session
uwsm stop

# Clear UWSM state
systemctl --user reset-failed wayland-wm@Hyprland.service

# Test configuration
Hyprland -c ~/.config/hypr/hyprland-uwsm.conf --test

# Emergency fallback to normal Hyprland
pkill -9 uwsm; Hyprland
```

## Conclusion

The monitor shutdown issue in UWSM mode is primarily caused by:
1. Missing `uwsm finalize` command causing systemd timeout
2. Conflicting startup scripts interfering with UWSM session management
3. Race conditions in environment variable propagation
4. Improper service ordering and dependencies

The provided fixes address each of these issues systematically. Start with Fix 1 (adding finalization) as it's the most critical, then progressively apply other fixes based on test results. The fallback launcher script ensures you always have a working Hyprland session regardless of UWSM status.