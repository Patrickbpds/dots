# Color Scheme Fixes Implementation

## Summary
Implemented a comprehensive solution to bridge the gap between heimdall-cli's color scheme format and Quickshell's expected format, ensuring the UI displays with proper colors.

## Problem
- heimdall-cli writes `current_scheme.json` with nested color objects containing hex/rgb/hsl/lab values
- Quickshell expects a simpler format with just hex values and Material Design 3 color names
- The mismatch caused the UI to display with broken/default colors

## Solution Components

### 1. Beat Detector Status
- **File**: `/home/arthur/dots/wm/.config/quickshell/heimdall/services/BeatDetector.qml`
- **Status**: Already commented out (lines 12-22)
- No changes needed as the beat_detector binary is not available

### 2. Scheme Sync Service
- **File**: `/home/arthur/dots/wm/.config/hypr/programs/scheme-sync.sh`
- **Purpose**: Watches for changes to heimdall-cli's `current_scheme.json` and converts to Quickshell format
- **Features**:
  - Monitors two possible locations for heimdall-cli schemes
  - Converts complex nested format to simple hex-only format
  - Maps terminal colors to Material Design 3 color names
  - Fills in missing M3 colors with sensible defaults
  - Uses inotifywait for efficient file watching (falls back to polling if not available)
  - Syncs to multiple locations for compatibility

### 3. Updated Init Script
- **File**: `/home/arthur/dots/wm/.config/hypr/programs/init-heimdall-state.sh`
- **Changes**:
  - Added `convert_heimdall_cli_scheme()` function to handle format conversion
  - Modified `find_or_generate_scheme()` to check for heimdall-cli files first
  - Converts heimdall-cli format on the fly during initialization
  - Provides proper Quickshell-format default scheme

### 4. Updated Startup Orchestrator
- **File**: `/home/arthur/dots/wm/.config/hypr/programs/startup-orchestrator.sh`
- **Changes**:
  - Starts the scheme-sync.sh service in background after state initialization
  - Ensures scheme.json exists in all required locations before starting Quickshell
  - Improved scheme file verification and copying logic

### 5. Manual Conversion Tool
- **File**: `/home/arthur/dots/wm/.config/hypr/programs/convert-scheme.sh`
- **Purpose**: Manual testing and debugging tool
- **Features**:
  - Can convert any heimdall-cli format scheme to Quickshell format
  - Interactive mode to find and convert current schemes
  - Apply mode to immediately update all scheme locations
  - Useful for testing and troubleshooting

## Color Mapping Strategy

The conversion maps heimdall-cli terminal colors to Material Design 3 colors:

| heimdall-cli | Quickshell M3 |
|-------------|---------------|
| background | background |
| foreground | onBackground |
| color0 (black) | surfaceContainerLowest |
| color1 (red) | error |
| color2 (green) | tertiary |
| color3 (yellow) | secondary |
| color4 (blue) | primary |
| color5 (magenta) | primary_paletteKeyColor |
| color6 (cyan) | tertiary_paletteKeyColor |
| color7 (white) | surface |
| color8-15 (bright) | Various container/variant colors |

## File Locations

### Input (heimdall-cli)
- Primary: `/home/arthur/.local/state/current_scheme.json`
- Alternative: `/home/arthur/.config/heimdall-cli/current_scheme.json`

### Output (Quickshell)
- `/home/arthur/.local/state/quickshell/user/generated/scheme.json`
- `/home/arthur/.local/state/quickshell/user/generated/colors.json`
- `/home/arthur/.local/share/heimdall/scheme.json`
- `/home/arthur/.local/share/heimdall/colors.json`
- `/home/arthur/.config/quickshell/heimdall/config/scheme.json` (if directory exists)

## Testing

### Test the conversion manually:
```bash
# Convert and display
/home/arthur/dots/wm/.config/hypr/programs/convert-scheme.sh /path/to/scheme.json

# Convert and apply
/home/arthur/dots/wm/.config/hypr/programs/convert-scheme.sh -a

# Check if sync service is running
ps aux | grep scheme-sync
```

### Verify scheme files:
```bash
# Check format
cat /home/arthur/.local/state/quickshell/user/generated/scheme.json | jq .

# Verify all locations have the same content
md5sum /home/arthur/.local/state/quickshell/user/generated/scheme.json \
       /home/arthur/.local/share/heimdall/scheme.json
```

## Integration with Hyprland

The scheme sync service is automatically started by the startup orchestrator when Hyprland starts. It runs continuously in the background, watching for changes to heimdall-cli's scheme files.

## Known Issues and Limitations

1. The color mapping is approximate - some M3 colors may not perfectly match the terminal colors
2. The sync service requires either inotifywait or falls back to polling (5-second intervals)
3. If heimdall-cli changes its format significantly, the conversion script will need updates

## Future Improvements

1. Add support for light mode color mapping
2. Implement more sophisticated color generation for missing M3 colors
3. Add configuration file for custom color mappings
4. Integrate with matugen for better color palette generation