import QtQuick

QtObject {
    id: root
    
    // Global animation settings
    property bool enabled: true         // Master switch for all animations
    property real speedMultiplier: 1.0  // Global speed multiplier (0.5 = half speed, 2.0 = double speed)
    
    // Duration presets (in milliseconds)
    property QtObject durations: QtObject {
        property int instant: 0
        property int fast: 150
        property int normal: 300
        property int slow: 500
        property int verySlow: 800
        property int expressiveDefaultSpatial: 400
        property int expressiveDefaultNonSpatial: 300
        
        // Component-specific durations
        property int fadeIn: 200
        property int fadeOut: 150
        property int slideIn: 300
        property int slideOut: 250
        property int expand: 350
        property int collapse: 300
        property int ripple: 600
        property int hover: 150
        property int focus: 200
    }
    
    // Easing curves
    property QtObject curves: QtObject {
        // Standard Material 3 curves
        property var emphasized: [0.2, 0.0, 0.0, 1.0]
        property var emphasizedDecelerate: [0.05, 0.7, 0.1, 1.0]
        property var emphasizedAccelerate: [0.3, 0.0, 0.8, 0.15]
        property var standard: [0.2, 0.0, 0.0, 1.0]
        property var standardDecelerate: [0.0, 0.0, 0.0, 1.0]
        property var standardAccelerate: [0.3, 0.0, 1.0, 1.0]
        property var expressiveDefaultSpatial: [0.2, 0.0, 0.0, 1.0]
        property var expressiveDefaultNonSpatial: [0.2, 0.0, 0.0, 1.0]
        
        // Additional easing options
        property int linear: Easing.Linear
        property int inQuad: Easing.InQuad
        property int outQuad: Easing.OutQuad
        property int inOutQuad: Easing.InOutQuad
        property int inCubic: Easing.InCubic
        property int outCubic: Easing.OutCubic
        property int inOutCubic: Easing.InOutCubic
        property int inQuart: Easing.InQuart
        property int outQuart: Easing.OutQuart
        property int inOutQuart: Easing.InOutQuart
        property int inQuint: Easing.InQuint
        property int outQuint: Easing.OutQuint
        property int inOutQuint: Easing.InOutQuint
        property int inExpo: Easing.InExpo
        property int outExpo: Easing.OutExpo
        property int inOutExpo: Easing.InOutExpo
        property int inCirc: Easing.InCirc
        property int outCirc: Easing.OutCirc
        property int inOutCirc: Easing.InOutCirc
        property int inElastic: Easing.InElastic
        property int outElastic: Easing.OutElastic
        property int inOutElastic: Easing.InOutElastic
        property int inBack: Easing.InBack
        property int outBack: Easing.OutBack
        property int inOutBack: Easing.InOutBack
        property int inBounce: Easing.InBounce
        property int outBounce: Easing.OutBounce
        property int inOutBounce: Easing.InOutBounce
    }
    
    // Transition types configuration
    property QtObject transitions: QtObject {
        // Page transitions
        property QtObject page: QtObject {
            property string type: "slide"  // "slide", "fade", "scale", "flip", "none"
            property int duration: 300
            property var easing: curves.emphasized
            property string direction: "horizontal"  // "horizontal", "vertical"
        }
        
        // Modal transitions
        property QtObject modal: QtObject {
            property string type: "fade-scale"  // "fade", "scale", "fade-scale", "slide-up", "none"
            property int duration: 250
            property var easing: curves.emphasizedDecelerate
            property real scaleFrom: 0.9
            property real scaleTo: 1.0
        }
        
        // List item transitions
        property QtObject listItem: QtObject {
            property string type: "fade-slide"  // "fade", "slide", "fade-slide", "none"
            property int duration: 200
            property int stagger: 50  // Delay between items
            property var easing: curves.standardDecelerate
        }
        
        // Tab transitions
        property QtObject tab: QtObject {
            property string type: "slide"  // "slide", "fade", "none"
            property int duration: 300
            property var easing: curves.standard
        }
        
        // Tooltip transitions
        property QtObject tooltip: QtObject {
            property string type: "fade"  // "fade", "scale", "fade-scale", "none"
            property int fadeInDuration: 150
            property int fadeOutDuration: 75
            property var easing: curves.standardDecelerate
        }
        
        // Menu transitions
        property QtObject menu: QtObject {
            property string type: "fade-scale"  // "fade", "scale", "fade-scale", "slide", "none"
            property int duration: 200
            property var easing: curves.emphasizedDecelerate
            property real scaleOrigin: 0.95
        }
    }
    
    // Spring animations configuration
    property QtObject spring: QtObject {
        property real damping: 0.8
        property real mass: 1.0
        property real stiffness: 100.0
        property real velocity: 0.0
        property real epsilon: 0.01
        property int modulus: 0
    }
    
    // Parallax effects
    property QtObject parallax: QtObject {
        property bool enabled: true
        property real factor: 0.5  // Parallax movement factor
        property int duration: 300
        property var easing: curves.standard
    }
    
    // Ripple effects
    property QtObject ripple: QtObject {
        property bool enabled: true
        property int duration: 600
        property real maxRadius: 100
        property real opacity: 0.12
        property var easing: curves.standardDecelerate
    }
    
    // Hover effects
    property QtObject hover: QtObject {
        property bool enabled: true
        property int duration: 150
        property real scale: 1.05
        property real opacity: 0.08
        property var easing: curves.standard
    }
    
    // Focus effects
    property QtObject focus: QtObject {
        property bool enabled: true
        property int duration: 200
        property int glowRadius: 4
        property real glowOpacity: 0.12
        property var easing: curves.emphasizedDecelerate
    }
    
    // Scroll animations
    property QtObject scroll: QtObject {
        property bool smoothScrolling: true
        property int duration: 250
        property var easing: curves.standardDecelerate
        property bool bounceEffect: true
        property real bounceDamping: 0.5
    }
    
    // Loading animations
    property QtObject loading: QtObject {
        property string type: "spinner"  // "spinner", "dots", "pulse", "skeleton"
        property int duration: 1000
        property int dotCount: 3
        property int dotDelay: 200
    }
    
    // Helper functions
    function getDuration(baseDuration) {
        if (!enabled) return 0
        return Math.round(baseDuration * speedMultiplier)
    }
    
    function getStaggerDelay(index, baseDelay) {
        if (!enabled) return 0
        return Math.round(index * baseDelay * speedMultiplier)
    }
    
    function isEnabled(specificAnimation) {
        return enabled && specificAnimation
    }
}