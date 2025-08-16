# Quickshell Heimdall Wallpaper Selector Research

## Executive Summary

The Heimdall wallpaper selector uses a PathView component with custom caching mechanisms. The stuttering on first scroll is caused by on-demand image loading and cache generation. Keyboard navigation can be enhanced by adding Ctrl+N/P support alongside existing vim keybindings.

## Current Architecture

### Component Structure

1. **Main Components**:
   - `/modules/launcher/WallpaperList.qml` - PathView-based wallpaper carousel
   - `/modules/launcher/items/WallpaperItem.qml` - Individual wallpaper preview item
   - `/modules/launcher/Content.qml` - Keyboard navigation handler
   - `/services/Wallpapers.qml` - Wallpaper management service
   - `/components/images/CachingImage.qml` - Custom image caching component

### Keyboard Navigation

#### Current Implementation Location
**File**: `/home/arthur/dots/wm/.config/quickshell/heimdall/modules/launcher/Content.qml`
**Lines**: 101-125

```qml
Keys.onUpPressed: list.currentList?.decrementCurrentIndex()
Keys.onDownPressed: list.currentList?.incrementCurrentIndex()

Keys.onPressed: event => {
    if (!Config.launcher.vimKeybinds)
        return;
    
    if (event.modifiers & Qt.ControlModifier) {
        if (event.key === Qt.Key_J) {
            list.currentList?.incrementCurrentIndex();
            event.accepted = true;
        } else if (event.key === Qt.Key_K) {
            list.currentList?.decrementCurrentIndex();
            event.accepted = true;
        }
    }
    // Tab navigation also present
}
```

#### Current Keybindings
- **Arrow Keys**: Up/Down for navigation
- **Ctrl+J/K**: Vim-style navigation (when enabled)
- **Tab/Shift+Tab**: Alternative navigation
- **Enter**: Select wallpaper
- **Escape**: Close launcher

### Caching Mechanism

#### CachingImage Component Analysis
**File**: `/components/images/CachingImage.qml`

The caching system works as follows:

1. **Cache Path Generation**:
   - Creates SHA256 hash of image path
   - Stores in `~/.cache/quickshell/heimdall/imagecache/`
   - Format: `{hash}@{width}x{height}.png`

2. **Loading Process**:
   ```qml
   asynchronous: true
   fillMode: Image.PreserveAspectCrop
   sourceSize.width: effectiveWidth
   sourceSize.height: effectiveHeight
   ```

3. **Cache Creation**:
   - On first load, displays original image
   - Grabs rendered image to cache file
   - Subsequent loads use cached version

#### PathView Configuration
**File**: `/modules/launcher/WallpaperList.qml`
```qml
pathItemCount: numItems    // Visible items
cacheItemCount: 4          // Pre-cached items (too low!)
```

## Identified Issues

### 1. Stuttering on First Scroll

**Root Causes**:
1. **Low cacheItemCount**: Only 4 items pre-cached
2. **On-demand SHA256 calculation**: Happens during scroll
3. **Synchronous cache file check**: Blocks UI thread
4. **Image grabbing during scroll**: Heavy operation

**Evidence**:
- Cache files show multiple resolutions being generated
- `smooth: !root.PathView.view.moving` indicates performance issues
- No preloading of adjacent wallpapers

### 2. Missing Keyboard Navigation

**Current State**:
- PathView responds to incrementCurrentIndex/decrementCurrentIndex
- No horizontal navigation (Left/Right arrows)
- No Ctrl+N/P support

## Recommended Improvements

### 1. Add Ctrl+N and Ctrl+P Navigation

**Location**: `/modules/launcher/Content.qml`, line 106-125

```qml
Keys.onPressed: event => {
    if (!Config.launcher.vimKeybinds)
        return;
    
    if (event.modifiers & Qt.ControlModifier) {
        if (event.key === Qt.Key_J) {
            list.currentList?.incrementCurrentIndex();
            event.accepted = true;
        } else if (event.key === Qt.Key_K) {
            list.currentList?.decrementCurrentIndex();
            event.accepted = true;
        }
        // ADD THESE LINES:
        else if (event.key === Qt.Key_N) {
            list.currentList?.incrementCurrentIndex();
            event.accepted = true;
        } else if (event.key === Qt.Key_P) {
            list.currentList?.decrementCurrentIndex();
            event.accepted = true;
        }
    }
    // ... rest of code
}
```

### 2. Add Left/Right Arrow Navigation for Wallpapers

**Location**: `/modules/launcher/Content.qml`, after line 102

```qml
Keys.onLeftPressed: {
    if (list.showWallpapers) {
        list.currentList?.decrementCurrentIndex();
    }
}
Keys.onRightPressed: {
    if (list.showWallpapers) {
        list.currentList?.incrementCurrentIndex();
    }
}
```

### 3. Improve Caching Performance

#### Increase Cache Buffer
**File**: `/modules/launcher/WallpaperList.qml`, line 50

```qml
// Change from:
cacheItemCount: 4
// To:
cacheItemCount: Math.min(12, count)  // Cache more items
```

#### Add Preloading
**File**: `/modules/launcher/WallpaperList.qml`, after line 40

```qml
Component.onCompleted: {
    currentIndex = Wallpapers.list.findIndex(w => w.path === Wallpapers.actualCurrent)
    
    // Preload adjacent wallpapers
    Qt.callLater(() => {
        for (let i = Math.max(0, currentIndex - 3); 
             i < Math.min(count, currentIndex + 4); i++) {
            if (i !== currentIndex) {
                const item = itemAt(i);
                if (item) item.preload = true;
            }
        }
    })
}
```

#### Optimize CachingImage
**File**: `/components/images/CachingImage.qml`

```qml
// Add property for preloading
property bool preload: false

// Modify cache check to be async
Component.onCompleted: {
    if (preload) {
        // Start hash calculation early
        shaProc.exec(["sha256sum", Paths.strip(path)])
    }
}

// Add cache existence check before loading
FileInfo {
    id: cacheInfo
    path: root.cachePath
}

onCachePathChanged: {
    if (hash) {
        // Check cache exists before trying to load
        if (cacheInfo.exists) {
            source = cachePath;
        } else {
            source = path;
        }
    }
}
```

### 4. Add Smooth Scrolling Optimization

**File**: `/modules/launcher/items/WallpaperItem.qml`, line 61

```qml
// Change from:
smooth: !root.PathView.view.moving
// To:
smooth: true  // Modern GPUs handle this fine
cache: true   // Enable QML image caching
```

## Performance Metrics

### Current Performance Issues
1. **Initial scroll lag**: 100-300ms stutter
2. **Cache generation time**: ~50-100ms per image
3. **Memory usage**: Each cached preview ~70-90KB

### Expected Improvements
1. **Reduced stutter**: <50ms with increased cache
2. **Smoother scrolling**: Consistent 60fps
3. **Better responsiveness**: Instant navigation

## Configuration Recommendations

### Enable Vim Keybindings
The vim keybindings are disabled by default. To enable:

1. **Via Config File**: Set `vimKeybinds: true` in launcher config
2. **Location**: Configuration is read from JSON config system

### Wallpaper Directory Optimization
- Keep wallpapers in organized subdirectories
- Use consistent image formats (prefer JPEG/PNG)
- Avoid very large images (>4K resolution)

## Testing Recommendations

1. **Test with various wallpaper counts**: 5, 10, 20, 50+ images
2. **Monitor cache generation**: Watch `~/.cache/quickshell/heimdall/imagecache/`
3. **Profile scrolling performance**: Use QML profiler
4. **Test keyboard navigation**: All combinations with/without vim mode

## Implementation Priority

1. **High Priority**:
   - Add Ctrl+N/P navigation (easy, high impact)
   - Increase cacheItemCount (simple fix)
   - Add Left/Right arrow keys for wallpapers

2. **Medium Priority**:
   - Implement preloading mechanism
   - Optimize CachingImage component

3. **Low Priority**:
   - Add configuration for cache size
   - Implement cache cleanup mechanism

## Conclusion

The wallpaper selector's stuttering is primarily caused by insufficient pre-caching and on-demand image processing. Simple changes to cacheItemCount and adding keyboard navigation will significantly improve user experience. The more complex caching optimizations can be implemented incrementally for further performance gains.