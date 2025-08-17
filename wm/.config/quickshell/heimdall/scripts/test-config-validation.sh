#!/bin/bash

# Test configuration validation system

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../config"
TEST_CONFIG="/tmp/test-config.json"

echo "=== Configuration Validation Test Suite ==="
echo

# Test 1: Valid configuration
echo "Test 1: Valid configuration"
cat > "$TEST_CONFIG" << 'EOF'
{
  "version": "2.0.0",
  "modules": {
    "launcher": {
      "enabled": true,
      "searchDelayMs": 300,
      "maxResults": 10,
      "position": "center"
    },
    "bar": {
      "height": 40,
      "position": "top"
    }
  },
  "appearance": {
    "theme": "dark",
    "accentColor": "#89B4FA",
    "fontSize": 14,
    "opacity": 0.95
  }
}
EOF

echo "✓ Created valid test configuration"

# Test 2: Invalid version format
echo
echo "Test 2: Invalid version format"
cat > "$TEST_CONFIG" << 'EOF'
{
  "version": "2.0",
  "modules": {}
}
EOF

echo "✓ Created invalid version test configuration"

# Test 3: Out of range values
echo
echo "Test 3: Out of range values"
cat > "$TEST_CONFIG" << 'EOF'
{
  "version": "2.0.0",
  "modules": {
    "launcher": {
      "searchDelayMs": -100,
      "maxResults": 1000
    },
    "bar": {
      "height": 5
    }
  },
  "appearance": {
    "fontSize": 100,
    "opacity": 2.0
  }
}
EOF

echo "✓ Created out-of-range test configuration"

# Test 4: Invalid enum values
echo
echo "Test 4: Invalid enum values"
cat > "$TEST_CONFIG" << 'EOF'
{
  "version": "2.0.0",
  "modules": {
    "launcher": {
      "position": "middle"
    },
    "bar": {
      "position": "left"
    }
  },
  "appearance": {
    "theme": "neon"
  }
}
EOF

echo "✓ Created invalid enum test configuration"

# Test 5: Invalid color format
echo
echo "Test 5: Invalid color format"
cat > "$TEST_CONFIG" << 'EOF'
{
  "version": "2.0.0",
  "appearance": {
    "accentColor": "blue",
    "backgroundColor": "#GGG"
  }
}
EOF

echo "✓ Created invalid color test configuration"

# Test 6: Migration from v1.0.0
echo
echo "Test 6: Migration from v1.0.0"
cat > "$TEST_CONFIG" << 'EOF'
{
  "launcher": {
    "enabled": true
  },
  "session": {
    "type": "hyprland"
  },
  "colours": {
    "accent": "89B4FA",
    "background": "1E1E2E"
  }
}
EOF

echo "✓ Created v1.0.0 format configuration for migration test"

echo
echo "=== Test Summary ==="
echo "All test configurations created successfully."
echo "Validation logic should be tested within the QML environment."
echo
echo "To manually test validation:"
echo "1. Copy test configurations to scheme.json"
echo "2. Run quickshell and check console output for validation messages"
echo "3. Verify that errors and warnings are properly reported"

# Clean up
rm -f "$TEST_CONFIG"

echo
echo "✓ Test setup complete"