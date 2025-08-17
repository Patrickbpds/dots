import QtQuick

QtObject {
    id: root
    
    // Switch component configuration
    property QtObject switch_: QtObject {
        property real widthRatio: 1.7  // Width to height ratio
        property real thumbWidthRatio: 1.3  // Thumb width ratio when pressed
        property real iconStartX: 0.15  // Icon start X position ratio
        property real iconEndX: 0.85    // Icon end X position ratio
        property int strokeWidth: 2     // Icon stroke width
    }
    
    // Slider component configuration
    property QtObject slider: QtObject {
        property int handleSize: 20     // Slider handle size
        property int trackHeight: 4     // Slider track height
        property real handleScale: 1.2  // Handle scale when pressed
    }
    
    // ScrollBar configuration
    property QtObject scrollBar: QtObject {
        property int width: 8           // ScrollBar width
        property int minHeight: 20      // Minimum thumb height
        property real hoverScale: 1.5   // Scale factor on hover
        property int margin: 2          // Margin from edge
    }
    
    // BusyIndicator configuration
    property QtObject busyIndicator: QtObject {
        property int defaultSize: 48    // Default size
        property int strokeWidth: 4     // Stroke width
        property int rotationDuration: 1000  // Full rotation duration in ms
    }
    
    // RadioButton configuration
    property QtObject radioButton: QtObject {
        property int indicatorSize: 20  // Indicator size
        property real innerCircleRatio: 0.5  // Inner circle size ratio
        property int rippleSize: 40     // Ripple effect size
    }
    
    // SpinBox configuration
    property QtObject spinBox: QtObject {
        property int buttonWidth: 32    // Up/down button width
        property int stepSize: 1        // Default step size
        property int accelerationDelay: 300  // Delay before acceleration
    }
    
    // TextField configuration
    property QtObject textField: QtObject {
        property int cursorWidth: 2     // Cursor width
        property int cursorBlinkRate: 500  // Cursor blink rate in ms
        property int selectionHandleSize: 20  // Touch selection handle size
    }
    
    // ToolTip configuration
    property QtObject toolTip: QtObject {
        property int delay: 500         // Show delay in ms
        property int timeout: 5000      // Auto-hide timeout in ms
        property int maxWidth: 300      // Maximum width
        property int offset: 8          // Offset from cursor
    }
    
    // Dialog configuration
    property QtObject dialog: QtObject {
        property int minWidth: 300      // Minimum dialog width
        property int minHeight: 200     // Minimum dialog height
        property int buttonSpacing: 8   // Button spacing
        property int contentMargin: 24  // Content margin
    }
    
    // List configuration
    property QtObject list: QtObject {
        property int itemHeight: 48     // Default item height
        property int itemSpacing: 0     // Item spacing
        property int sectionHeight: 32  // Section header height
        property bool alternatingRows: false  // Alternating row colors
    }
    
    // Grid configuration
    property QtObject grid: QtObject {
        property int cellWidth: 100     // Default cell width
        property int cellHeight: 100    // Default cell height
        property int spacing: 8         // Grid spacing
        property int columns: 4         // Default column count
    }
    
    // Tab configuration
    property QtObject tab: QtObject {
        property int height: 48         // Tab height
        property int minWidth: 90       // Minimum tab width
        property int maxWidth: 360      // Maximum tab width
        property int indicatorHeight: 3 // Selected indicator height
    }
    
    // Menu configuration
    property QtObject menu: QtObject {
        property int itemHeight: 36     // Menu item height
        property int minWidth: 200      // Minimum menu width
        property int maxWidth: 400      // Maximum menu width
        property int submenuDelay: 300  // Submenu show delay
        property int iconSize: 20       // Menu icon size
        property int separatorHeight: 1 // Separator height
    }
    
    // Progress configuration
    property QtObject progress: QtObject {
        property int barHeight: 4       // Progress bar height
        property int circularSize: 48   // Circular progress size
        property int strokeWidth: 4     // Circular stroke width
        property bool indeterminate: false  // Indeterminate mode
    }
    
    // Badge configuration
    property QtObject badge: QtObject {
        property int size: 20           // Badge size
        property int fontSize: 12       // Badge font size
        property int maxCount: 99       // Maximum count to display
        property string overflowText: "99+"  // Text for overflow
    }
    
    // Chip configuration
    property QtObject chip: QtObject {
        property int height: 32         // Chip height
        property int iconSize: 18       // Chip icon size
        property int deleteIconSize: 18 // Delete icon size
        property int spacing: 8         // Internal spacing
    }
    
    // Avatar configuration
    property QtObject avatar: QtObject {
        property int smallSize: 32      // Small avatar size
        property int mediumSize: 48     // Medium avatar size
        property int largeSize: 64      // Large avatar size
        property int borderWidth: 2     // Border width
    }
    
    // Divider configuration
    property QtObject divider: QtObject {
        property int thickness: 1       // Divider thickness
        property int margin: 8          // Margin around divider
        property real opacity: 0.12     // Divider opacity
    }
    
    // FloatingActionButton configuration
    property QtObject fab: QtObject {
        property int size: 56           // FAB size
        property int miniSize: 40       // Mini FAB size
        property int iconSize: 24       // Icon size
        property int extendedPadding: 16  // Extended FAB padding
    }
}