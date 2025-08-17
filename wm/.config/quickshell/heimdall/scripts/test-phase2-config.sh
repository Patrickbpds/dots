#!/bin/bash

# Test Phase 2 configuration enhancements

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../config"
TEST_CONFIG="/tmp/test-phase2-config.json"

echo "=== Phase 2 Configuration Test Suite ==="
echo

# Test 1: UI Components Configuration
echo "Test 1: UI Components Configuration"
cat > "$TEST_CONFIG" << 'EOF'
{
  "version": "2.0.0",
  "modules": {
    "uiComponents": {
      "switch": {
        "widthRatio": 2.0,
        "thumbWidthRatio": 1.5
      },
      "scrollBar": {
        "width": 10,
        "minHeight": 30
      },
      "tooltip": {
        "delay": 1000,
        "timeout": 3000
      }
    }
  }
}
EOF
echo "✓ Created UI components test configuration"

# Test 2: Animation Configuration
echo
echo "Test 2: Animation Configuration"
cat > "$TEST_CONFIG" << 'EOF'
{
  "version": "2.0.0",
  "modules": {
    "animation": {
      "enabled": true,
      "speedMultiplier": 1.5,
      "durations": {
        "fadeIn": 300,
        "fadeOut": 200,
        "slideIn": 400
      },
      "transitions": {
        "page": {
          "type": "fade",
          "duration": 500
        },
        "modal": {
          "type": "fade-scale",
          "duration": 300
        }
      },
      "ripple": {
        "enabled": true,
        "duration": 800,
        "opacity": 0.2
      }
    }
  }
}
EOF
echo "✓ Created animation test configuration"

# Test 3: Services Integration Configuration
echo
echo "Test 3: Services Integration Configuration"
cat > "$TEST_CONFIG" << 'EOF'
{
  "version": "2.0.0",
  "modules": {
    "servicesIntegration": {
      "weather": {
        "enabled": true,
        "provider": "openweathermap",
        "apiKey": "test-key",
        "location": "London",
        "updateInterval": 3600000
      },
      "systemMonitor": {
        "enabled": true,
        "updateInterval": 2000,
        "monitorCPU": true,
        "monitorMemory": true,
        "cpuWarningThreshold": 75
      },
      "notifications": {
        "enabled": true,
        "maxNotifications": 20,
        "defaultTimeout": 8000,
        "position": "top-left"
      }
    }
  }
}
EOF
echo "✓ Created services integration test configuration"

# Test 4: Behavior Configuration
echo
echo "Test 4: Behavior Configuration"
cat > "$TEST_CONFIG" << 'EOF'
{
  "version": "2.0.0",
  "modules": {
    "behavior": {
      "interaction": {
        "click": {
          "longPressDelay": 800,
          "doubleClickInterval": 500
        },
        "swipe": {
          "enabled": true,
          "minDistance": 75,
          "leftAction": "previous",
          "rightAction": "next"
        }
      },
      "keyboard": {
        "enabled": true,
        "vimMode": true,
        "global": {
          "launcher": "Meta+Return",
          "dashboard": "Meta+Shift+D"
        }
      },
      "search": {
        "enabled": true,
        "liveSearch": true,
        "searchDelay": 200,
        "fuzzySearch": true,
        "maxResults": 100
      },
      "performance": {
        "enableGPU": true,
        "lazyLoading": true,
        "virtualScrolling": true
      }
    }
  }
}
EOF
echo "✓ Created behavior test configuration"

# Test 5: Combined Configuration
echo
echo "Test 5: Combined Configuration (All Phase 2 modules)"
cat > "$TEST_CONFIG" << 'EOF'
{
  "version": "2.0.0",
  "modules": {
    "uiComponents": {
      "busyIndicator": {
        "defaultSize": 64,
        "strokeWidth": 6
      },
      "dialog": {
        "minWidth": 400,
        "minHeight": 300
      }
    },
    "animation": {
      "enabled": true,
      "speedMultiplier": 0.8,
      "hover": {
        "enabled": true,
        "duration": 200,
        "scale": 1.1
      }
    },
    "servicesIntegration": {
      "audio": {
        "enabled": true,
        "volumeStep": 10,
        "showVolumeOSD": true
      },
      "bluetooth": {
        "enabled": false,
        "autoConnect": false
      }
    },
    "behavior": {
      "mouse": {
        "naturalScroll": true,
        "scrollSpeed": 5
      },
      "accessibility": {
        "enabled": true,
        "largeText": true,
        "textScale": 1.2
      }
    }
  }
}
EOF
echo "✓ Created combined test configuration"

echo
echo "=== Test Summary ==="
echo "All Phase 2 test configurations created successfully."
echo
echo "Configuration modules added:"
echo "1. UIComponentsConfig - UI component dimensions and properties"
echo "2. AnimationConfig - Animation durations, curves, and transitions"
echo "3. ServicesIntegrationConfig - Service endpoints, intervals, and settings"
echo "4. BehaviorConfig - Interaction patterns, shortcuts, and behaviors"
echo
echo "To test:"
echo "1. Copy test configurations to scheme.json"
echo "2. Run quickshell and verify configurations are loaded"
echo "3. Check that components use the new configuration values"
echo "4. Verify no errors in console output"

# Clean up
rm -f "$TEST_CONFIG"

echo
echo "✓ Phase 2 test setup complete"