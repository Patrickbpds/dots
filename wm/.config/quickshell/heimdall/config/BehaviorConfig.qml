import QtQuick

QtObject {
    id: root
    
    // Interaction patterns
    property QtObject interaction: QtObject {
        // Click behavior
        property QtObject click: QtObject {
            property int singleClickDelay: 250  // Max delay for single click
            property int doubleClickInterval: 400  // Max interval between clicks for double-click
            property int longPressDelay: 500  // Delay for long press
            property int clickRadius: 5  // Movement tolerance in pixels
            property bool vibrateFeedback: false  // Haptic feedback on click
        }
        
        // Drag behavior
        property QtObject drag: QtObject {
            property bool enabled: true
            property int threshold: 10  // Pixels before drag starts
            property real sensitivity: 1.0  // Drag sensitivity multiplier
            property bool showGhost: true  // Show ghost image while dragging
            property real ghostOpacity: 0.5
            property bool snapToGrid: false
            property int gridSize: 10
        }
        
        // Swipe gestures
        property QtObject swipe: QtObject {
            property bool enabled: true
            property int minDistance: 50  // Minimum swipe distance in pixels
            property int maxDuration: 300  // Maximum swipe duration in ms
            property real minVelocity: 0.5  // Minimum velocity for swipe
            property string leftAction: "back"
            property string rightAction: "forward"
            property string upAction: "refresh"
            property string downAction: "close"
        }
        
        // Pinch gestures
        property QtObject pinch: QtObject {
            property bool enabled: true
            property real minScale: 0.5
            property real maxScale: 3.0
            property real sensitivity: 1.0
            property bool smoothScaling: true
        }
        
        // Hover behavior
        property QtObject hover: QtObject {
            property bool enabled: true
            property int enterDelay: 0  // Delay before hover state
            property int exitDelay: 0  // Delay before leaving hover state
            property bool showTooltip: true
            property int tooltipDelay: 500
            property bool highlightOnHover: true
        }
        
        // Focus behavior
        property QtObject focus: QtObject {
            property bool enabled: true
            property bool showIndicator: true
            property bool trapFocus: false  // Trap focus within component
            property bool autoFocus: false  // Auto-focus first element
            property string traversalMode: "natural"  // "natural", "horizontal", "vertical"
        }
    }
    
    // Keyboard shortcuts and navigation
    property QtObject keyboard: QtObject {
        property bool enabled: true
        property bool vimMode: false  // Enable vim-style navigation
        property bool emacsMode: false  // Enable emacs-style navigation
        
        // Navigation keys
        property QtObject navigation: QtObject {
            property string up: "Up"
            property string down: "Down"
            property string left: "Left"
            property string right: "Right"
            property string pageUp: "PageUp"
            property string pageDown: "PageDown"
            property string home: "Home"
            property string end: "End"
            property string tab: "Tab"
            property string shiftTab: "Shift+Tab"
        }
        
        // Action keys
        property QtObject actions: QtObject {
            property string select: "Return"
            property string cancel: "Escape"
            property string deleteKey: "Delete"
            property string cut: "Ctrl+X"
            property string copy: "Ctrl+C"
            property string paste: "Ctrl+V"
            property string undo: "Ctrl+Z"
            property string redo: "Ctrl+Shift+Z"
            property string selectAll: "Ctrl+A"
            property string find: "Ctrl+F"
            property string replace: "Ctrl+H"
        }
        
        // Global shortcuts
        property QtObject global: QtObject {
            property string launcher: "Meta+Space"
            property string dashboard: "Meta+D"
            property string controlCenter: "Meta+C"
            property string notifications: "Meta+N"
            property string lock: "Meta+L"
            property string logout: "Meta+Shift+L"
            property string screenshot: "Print"
            property string volumeUp: "XF86AudioRaiseVolume"
            property string volumeDown: "XF86AudioLowerVolume"
            property string volumeMute: "XF86AudioMute"
        }
        
        // Key repeat
        property QtObject repeat: QtObject {
            property bool enabled: true
            property int delay: 500  // Initial delay before repeat
            property int rate: 30  // Repeat rate in ms
        }
    }
    
    // Mouse behavior
    property QtObject mouse: QtObject {
        property bool naturalScroll: false  // Reverse scroll direction
        property int scrollSpeed: 3  // Lines per scroll
        property real scrollMultiplier: 1.0
        property bool smoothScroll: true
        property int wheelDelta: 120  // Standard wheel delta
        property bool middleClickPaste: true
        property string rightClickAction: "contextMenu"  // "contextMenu", "back", "none"
        property int cursorSize: 24
        property bool cursorAutoHide: true
        property int cursorHideDelay: 3000
    }
    
    // Touch behavior
    property QtObject touch: QtObject {
        property bool enabled: true
        property int tapRadius: 20  // Touch tap radius
        property bool multiTouch: true
        property int maxTouchPoints: 10
        property bool edgeSwipe: true
        property int edgeSwipeThreshold: 20
        property bool kineticScroll: true
        property real friction: 0.9
    }
    
    // Window behavior
    property QtObject window: QtObject {
        property bool rememberPosition: true
        property bool rememberSize: true
        property bool centerOnOpen: false
        property bool snapToEdges: true
        property int snapDistance: 10
        property bool showInTaskbar: true
        property bool alwaysOnTop: false
        property bool skipTaskbar: false
        property bool skipPager: false
        property string focusPolicy: "click"  // "click", "hover", "none"
        property bool raiseonFocus: true
    }
    
    // State management
    property QtObject state: QtObject {
        property bool persistent: true  // Save state between sessions
        property bool autoSave: true
        property int autoSaveInterval: 60000  // Auto-save interval in ms
        property string statePath: "~/.config/quickshell/heimdall/state"
        property bool compressState: true
        property int maxStateHistory: 10
        property bool restoreOnCrash: true
    }
    
    // Search behavior
    property QtObject search: QtObject {
        property bool enabled: true
        property bool liveSearch: true  // Search as you type
        property int searchDelay: 300  // Delay before search starts
        property bool fuzzySearch: true
        property bool caseSensitive: false
        property bool regexSearch: false
        property bool highlightMatches: true
        property int maxResults: 50
        property bool searchHistory: true
        property int historySize: 100
    }
    
    // Accessibility
    property QtObject accessibility: QtObject {
        property bool enabled: false
        property bool screenReader: false
        property bool highContrast: false
        property bool reducedMotion: false
        property bool largeText: false
        property real textScale: 1.0
        property bool keyboardOnly: false
        property bool announceChanges: true
        property int announceDelay: 100
    }
    
    // Performance tuning
    property QtObject performance: QtObject {
        property bool enableGPU: true
        property bool enableCaching: true
        property int cacheSize: 100  // MB
        property bool lazyLoading: true
        property int lazyLoadThreshold: 100  // Pixels from viewport
        property bool virtualScrolling: true
        property int virtualBufferSize: 3  // Screens worth of content
        property bool throttleUpdates: true
        property int updateThrottle: 16  // ms (60 FPS)
        property bool reducedEffects: false
    }
    
    // Error handling
    property QtObject errorHandling: QtObject {
        property bool showErrors: true
        property bool logErrors: true
        property string errorLogPath: "~/.config/quickshell/heimdall/errors.log"
        property bool notifyOnError: true
        property int errorNotificationTimeout: 5000
        property bool autoRecover: true
        property int maxRetries: 3
        property bool reportCrashes: false
        property string crashReportUrl: ""
    }
    
    // Update behavior
    property QtObject updates: QtObject {
        property bool autoCheck: true
        property int checkInterval: 86400000  // 24 hours
        property bool autoDownload: false
        property bool autoInstall: false
        property bool notifyAvailable: true
        property string updateChannel: "stable"  // "stable", "beta", "nightly"
        property string updateUrl: ""
    }
    
    // Helper functions
    function getBehavior(category, subcategory) {
        if (root.hasOwnProperty(category)) {
            if (subcategory && root[category].hasOwnProperty(subcategory)) {
                return root[category][subcategory]
            }
            return root[category]
        }
        return null
    }
    
    function isFeatureEnabled(feature) {
        const parts = feature.split(".")
        let obj = root
        
        for (const part of parts) {
            if (obj.hasOwnProperty(part)) {
                obj = obj[part]
            } else {
                return false
            }
        }
        
        return obj.enabled !== false
    }
}