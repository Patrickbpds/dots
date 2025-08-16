# Quickshell Heimdall Symlinked Wallpapers Research

## Executive Summary
The Quickshell Heimdall wallpaper selector cannot display symlinked wallpapers because the `find` command in `Wallpapers.qml` explicitly searches for regular files only (`-type f`), excluding symbolic links. This affects users who organize wallpapers using symlinks, as demonstrated in the current setup where 15 out of 16 wallpapers are symlinks.

## Problem Analysis

### Current Implementation
The wallpaper discovery mechanism is located in `/home/arthur/dots/wm/.config/quickshell/heimdall/services/Wallpapers.qml` at line 89:

```qml
command: ["find", Paths.expandTilde(Config.paths.wallpaperDir), "-type", "d", "-path", '*/.*', "-prune", "-o", "-not", "-name", '.*', "-type", "f", "-print"]
```

This command:
- Searches the wallpaper directory (default: `~/Pictures/Wallpapers`)
- Excludes hidden directories (`-path '*/.*' -prune`)
- Excludes hidden files (`-not -name '.*'`)
- **Only finds regular files** (`-type f`)
- Does NOT include symbolic links

### Current Directory Structure
Analysis of `~/Pictures/Wallpapers/` reveals:
- **1 regular file**: `port.png`
- **15 symbolic links**: All pointing to `../../dots/media/Pictures/Wallpapers/`
- All symlinks are valid and resolve to actual image files
- Symlinks follow the pattern: `[Name].[jpg|png]` → `../../dots/media/Pictures/Wallpapers/[Name].[jpg|png]`

### Impact
- Only 1 out of 16 wallpapers appears in the selector
- Users cannot select symlinked wallpapers through the Heimdall UI
- The wallpaper selector appears nearly empty despite having many valid wallpapers

## Root Cause
The `find` command uses `-type f` which matches only regular files. In Unix/Linux:
- `-type f`: Matches regular files only
- `-type l`: Matches symbolic links only
- `-type f -o -type l`: Matches both regular files and symbolic links

## Solution

### Primary Fix
Replace the find command in `Wallpapers.qml` line 89:

**Current:**
```qml
command: ["find", Paths.expandTilde(Config.paths.wallpaperDir), "-type", "d", "-path", '*/.*', "-prune", "-o", "-not", "-name", '.*', "-type", "f", "-print"]
```

**Fixed:**
```qml
command: ["find", Paths.expandTilde(Config.paths.wallpaperDir), "-type", "d", "-path", '*/.*', "-prune", "-o", "-not", "-name", '.*', "\\(", "-type", "f", "-o", "-type", "l", "\\)", "-print"]
```

### Alternative Approaches

#### Option 1: Follow Symlinks (Recommended)
Add `-L` flag to make find follow symbolic links:
```qml
command: ["find", "-L", Paths.expandTilde(Config.paths.wallpaperDir), "-type", "d", "-path", '*/.*', "-prune", "-o", "-not", "-name", '.*', "-type", "f", "-print"]
```
- **Pros**: Simpler syntax, treats symlinks transparently as files
- **Cons**: May follow circular symlinks (though unlikely in wallpaper directories)

#### Option 2: Explicit Symlink Support
Use the parenthesized OR expression as shown in the primary fix.
- **Pros**: Explicit about supporting both file types
- **Cons**: Slightly more complex syntax

## Testing Verification

### Test Commands
```bash
# Current behavior (finds 1 file)
find ~/Pictures/Wallpapers -type d -path '*/.*' -prune -o -not -name '.*' -type f -print | wc -l
# Result: 1

# Fixed behavior (finds 16 files)
find ~/Pictures/Wallpapers -type d -path '*/.*' -prune -o -not -name '.*' \( -type f -o -type l \) -print | wc -l
# Result: 16

# With -L flag (follows symlinks)
find -L ~/Pictures/Wallpapers -type d -path '*/.*' -prune -o -not -name '.*' -type f -print | wc -l
# Result: 16
```

## Additional Considerations

### 1. Image Validation
The `Images.isValidImageByName()` function (line 91) only checks file extensions, not file existence or readability. This is fine as it works with symlink names.

### 2. File Watching
The `inotifywait` command (line 99) monitors the wallpaper directory for changes. This should work with symlinks but may need testing for:
- Creating new symlinks
- Modifying symlink targets
- Deleting symlinks

### 3. Heimdall CLI Integration
The Heimdall CLI is called with the file path (line 22):
```qml
Quickshell.execDetached(["heimdall", "wallpaper", "-f", path]);
```
This should work with symlink paths as the shell/OS will resolve them.

### 4. Preview Generation
The preview system (line 76) passes the path to heimdall:
```qml
command: ["heimdall", "wallpaper", "-p", root.previewPath]
```
This should also work with symlinks as long as the heimdall CLI can resolve them.

## Risks and Mitigations

### Risk 1: Circular Symlinks
**Risk**: If using `-L` flag, circular symlinks could cause infinite loops.
**Mitigation**: 
- Use explicit OR condition instead of `-L`
- Or add `-maxdepth` limit if using `-L`
- Wallpaper directories rarely have complex symlink structures

### Risk 2: Broken Symlinks
**Risk**: Symlinks pointing to non-existent files could appear in the list.
**Mitigation**: 
- The image validation already filters by extension
- Could add additional validation in QML to check file readability
- Broken symlinks would fail gracefully when selected

### Risk 3: Performance
**Risk**: Following symlinks might impact performance.
**Mitigation**: 
- Impact is negligible for typical wallpaper counts (<1000 files)
- Find command runs once at startup and on directory changes
- No performance difference observed in testing

## Recommended Implementation

### Step 1: Update Wallpapers.qml
Change line 89 to use Option 1 (with `-L` flag) for simplicity:
```qml
command: ["find", "-L", Paths.expandTilde(Config.paths.wallpaperDir), "-type", "d", "-path", '*/.*', "-prune", "-o", "-not", "-name", '.*', "-type", "f", "-print"]
```

### Step 2: Test the Change
1. Restart Quickshell/Heimdall
2. Open the launcher
3. Type `:wallpaper ` (with space)
4. Verify all 16 wallpapers appear
5. Test selecting a symlinked wallpaper
6. Verify wallpaper changes correctly

### Step 3: Monitor for Issues
- Check if file watching still works when adding/removing symlinks
- Verify preview generation works for symlinked wallpapers
- Ensure no performance degradation

## Conclusion
The issue is a simple oversight in the find command that can be fixed with a one-line change. The fix is low-risk and backward-compatible, as it will continue to find regular files while also including symlinks. This will restore full functionality to users who organize their wallpapers using symbolic links, which is a common practice for dotfile management and wallpaper organization.

## References
- **Source File**: `/home/arthur/dots/wm/.config/quickshell/heimdall/services/Wallpapers.qml`
- **Line Number**: 89
- **Find Manual**: `man find` - Options `-type`, `-L`
- **Current Setup**: 15 symlinks in `~/Pictures/Wallpapers/` pointing to `../../dots/media/Pictures/Wallpapers/`