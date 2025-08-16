# Hyprland Keybind Configuration Analysis

## Executive Summary

Analysis of Hyprland keybind configurations comparing legacy (`/home/arthur/dots/wm/.config/hypr/`) and new (`/home/arthur/.config/hypr/`) configurations reveals:

- **Both configurations are identical** with 101 keybinds each
- **2 internal conflicts** exist in both configurations
- **No missing keybinds** between configurations
- **No action differences** between configurations

## Configuration Locations

### Legacy Configuration
- Primary: `/home/arthur/dots/wm/.config/hypr/hyprland/keybinds.conf`
- Custom: `/home/arthur/dots/wm/.config/hypr/custom/keybinds.conf`

### New Configuration
- Primary: `/home/arthur/.config/hypr/hyprland/keybinds.conf`
- Custom: `/home/arthur/.config/hypr/custom/keybinds.conf`

## Key Findings

### 1. Configuration Parity
Both legacy and new configurations contain exactly the same keybinds with identical actions. This indicates a successful migration or synchronization between the two locations.

### 2. Identified Conflicts

#### Conflict 1: Super+Alt+L (Restore Lock)
```conf
bindl = Super+Alt, L, exec, heimdall shell -d
bindl = Super+Alt, L, global, heimdall:lock
```
**Issue**: Same key combination bound to two different actions:
- First binding: Executes `heimdall shell -d`
- Second binding: Triggers `heimdall:lock` global action

**Impact**: Only the second binding will be effective as it overrides the first.

#### Conflict 2: Alt+Tab (Window Switching)
```conf
bind = Alt, Tab, cyclenext
bind = Alt, Tab, bringactivetotop,
```
**Issue**: Same key combination bound to two different actions:
- First binding: Cycles to next window
- Second binding: Brings active window to top

**Impact**: Both actions may execute sequentially, which could be intentional for window switching behavior.

### 3. Keybind Categories

#### Shell Integration (Heimdall)
- **Launcher**: Super+Space with interrupt handlers for mouse/keyboard events
- **Session Management**: Ctrl+Alt+Delete
- **Lock Screen**: Ctrl+Super+Alt+L
- **Media Controls**: Play/Pause, Next, Previous via both keyboard shortcuts and media keys
- **Brightness Controls**: XF86MonBrightnessUp/Down
- **Notifications**: Ctrl+Alt+C to clear

#### Window Management
- **Movement**: Super+h/j/k/l (vim-style) and Super+Shift+h/j/k/l
- **Focus**: Super+[h/j/k/l] and Super+[BracketLeft/BracketRight]
- **Closing**: Super+Q (normal), Super+Shift+Alt+Q (force kill)
- **Floating**: Super+Alt+Space
- **Fullscreen**: Super+F (full), Super+D (maximize)
- **Pin**: Super+P
- **Split Ratio**: Super+[Semicolon/Apostrophe]

#### Workspace Management
- **Direct Switch**: Super+[0-9] for workspaces 1-10
- **Move Window**: Super+Shift+[0-9]
- **Navigation**: Page_Up/Down with modifiers
- **Special Workspace**: Super+Alt+S (send), Ctrl+Super+S (toggle)

#### Applications
- **Terminal**: Super+Return → kitty
- **Browser**: Super+W → zen-browser
- **Text Editor**: Super+C → nvim
- **File Explorer**: Super+E → nemo
- **GitHub Desktop**: Super+G
- **System Monitor**: Ctrl+Alt+Escape → qps
- **Audio Control**: Ctrl+Alt+V → pavucontrol

#### Utilities
- **Screenshots**: Print, Super+Shift+S (freeze), Super+Shift+Alt+S (region)
- **Recording**: Super+Alt+R (with sound), Ctrl+Alt+R (no sound), Super+Shift+Alt+R (region)
- **Color Picker**: Super+Shift+C
- **Clipboard**: Super+V (normal), Super+Alt+V (delete mode)
- **Emoji Picker**: Super+Period
- **Volume Control**: XF86Audio keys and Super+Shift+M for mute

### 4. Special Bindings

#### bindin (Input Passthrough)
Used for launcher interrupt handling:
```conf
bindin = Super, catchall, global, heimdall:launcherInterrupt
bindin = Super, mouse:272-277, global, heimdall:launcherInterrupt
bindin = Super, mouse_up/down, global, heimdall:launcherInterrupt
```

#### bindm (Mouse Bindings)
```conf
bindm = Super, mouse:272, movewindow  # Left click drag
bindm = Super, mouse:273, resizewindow # Right click drag
bindm = Super, mouse:274, movewindow  # Middle click drag
```

#### bindd (Double Press)
```conf
bindd = Super, Space, Toggle overview, global, heimdall:launcher
```

#### binde (Repeat on Hold)
```conf
binde = Super, Semicolon, splitratio, -0.1
binde = Super, Apostrophe, splitratio, +0.1
```

## Variables Used

The configuration uses several variables defined in `/home/arthur/.config/hypr/variables.conf`:

```conf
$terminal = kitty
$browser = zen-browser
$textEditor = nvim
$fileExplorer = nemo
$volumeStep = 10

$kbTerminal = Super, Return
$kbBrowser = Super, W
$kbTextEditor = Super, C
$kbFileExplorer = Super, E
$kbSession = Ctrl+Alt, Delete
$kbClearNotifs = Ctrl+Alt, C
$kbShowPanels = Super, K
$kbLock = Ctrl+Super+Alt, L
$kbRestoreLock = Super+Alt, L
```

## Recommendations

### 1. Resolve Conflicts

#### For Super+Alt+L conflict:
Consider combining both actions or removing the duplicate:
```conf
bindl = Super+Alt, L, exec, heimdall shell -d && hyprctl dispatch global heimdall:lock
```
Or remove the first binding if only lock is needed.

#### For Alt+Tab conflict:
This might be intentional for proper Alt+Tab behavior. If not, consider:
```conf
bind = Alt, Tab, cyclenext
bind = Alt, Tab, bringactivetotop
# Could be combined into a single dispatcher chain
```

### 2. Configuration Management

Since both configurations are identical, consider:
1. **Symlink Strategy**: Link one to the other to maintain single source of truth
2. **Remove Redundancy**: If migration is complete, remove legacy configuration
3. **Version Control**: Ensure the active configuration is properly tracked

### 3. Documentation

Consider adding inline documentation for complex keybind chains, especially for:
- The workspace_action.sh script functionality
- The app2unit wrapper purpose
- The heimdall global actions

### 4. Consistency Check

Some keybinds use `exec` directly while others use variables. Consider standardizing approach for maintainability.

## Conclusion

The Hyprland keybind configuration is well-organized and comprehensive, with only minor conflicts that need resolution. The identical nature of both configurations suggests successful migration, but redundancy should be addressed to prevent future synchronization issues.