pragma Singleton

import Quickshell
import Quickshell.Hyprland

Singleton {
    // Use monitor names (connector names like DP-1, HDMI-A-1) as keys
    // These remain stable across monitor sleep/resume cycles
    property var screensByName: new Map()
    property var fallbackVisibilities: null

    function load(screen: ShellScreen, visibilities: var): void {
        const monitor = Hyprland.monitorFor(screen);
        if (monitor && monitor.name) {
            // Use the stable monitor name (connector name) as the primary key
            const monitorName = monitor.name;
            screensByName.set(monitorName, visibilities);
            console.log(`[Visibilities] Registered monitor: ${monitorName}`);
        }
        
        // Keep the first loaded visibilities as fallback
        if (!fallbackVisibilities) {
            fallbackVisibilities = visibilities;
        }
    }

    function getForActive(): PersistentProperties {
        const monitor = Hyprland.focusedMonitor;
        
        // Try to get by monitor name (most stable identifier)
        if (monitor && monitor.name) {
            const monitorName = monitor.name;
            let result = screensByName.get(monitorName);
            
            if (result) {
                return result;
            } else {
                console.warn(`[Visibilities] No visibilities found for monitor: ${monitorName}, using fallback`);
            }
        }
        
        // Use fallback if available
        if (fallbackVisibilities) {
            return fallbackVisibilities;
        }
        
        // This shouldn't happen, but log it
        console.error("[Visibilities] No visibilities available at all!");
        return null;
    }
}