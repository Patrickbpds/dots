#!/bin/bash
# Test script for configuration validation
# Tests various invalid configurations to ensure validator catches errors

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR="$SCRIPT_DIR/validate-config.py"
TEMP_DIR="/tmp/quickshell-config-tests"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Create temp directory
mkdir -p "$TEMP_DIR"

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local TEST_NAME="$1"
    local CONFIG_JSON="$2"
    local SHOULD_PASS="$3"
    
    echo -n "Testing: $TEST_NAME... "
    
    # Write test configuration
    echo "$CONFIG_JSON" > "$TEMP_DIR/test.json"
    
    # Run validator
    python3 "$VALIDATOR" "$TEMP_DIR/test.json" > /dev/null 2>&1
    RESULT=$?
    
    if [ "$SHOULD_PASS" = "true" ]; then
        if [ $RESULT -eq 0 ]; then
            echo -e "${GREEN}✓ PASSED${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}✗ FAILED (should have passed)${NC}"
            python3 "$VALIDATOR" "$TEMP_DIR/test.json"
            ((TESTS_FAILED++))
        fi
    else
        if [ $RESULT -ne 0 ]; then
            echo -e "${GREEN}✓ PASSED (correctly rejected)${NC}"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}✗ FAILED (should have been rejected)${NC}"
            ((TESTS_FAILED++))
        fi
    fi
}

echo "Running Configuration Validation Tests"
echo "======================================"
echo ""

# Test 1: Valid minimal configuration
run_test "Valid minimal config" '{
    "version": "1.0.0"
}' "true"

# Test 2: Missing version
run_test "Missing version" '{
    "appearance": {}
}' "false"

# Test 3: Invalid version format
run_test "Invalid version format" '{
    "version": "1.0"
}' "false"

# Test 4: Invalid bar position
run_test "Invalid bar position" '{
    "version": "1.0.0",
    "bar": {
        "position": "left"
    }
}' "false"

# Test 5: Invalid bar height
run_test "Invalid bar height (negative)" '{
    "version": "1.0.0",
    "bar": {
        "height": -10
    }
}' "false"

# Test 6: Invalid command type
run_test "Invalid command type" '{
    "version": "1.0.0",
    "commands": {
        "terminal": 123
    }
}' "false"

# Test 7: Invalid startup delay
run_test "Invalid startup delay" '{
    "version": "1.0.0",
    "system": {
        "startup": {
            "sequence": [
                {"name": "test", "delay": -100}
            ]
        }
    }
}' "false"

# Test 8: Missing startup sequence fields
run_test "Missing startup name" '{
    "version": "1.0.0",
    "system": {
        "startup": {
            "sequence": [
                {"delay": 100}
            ]
        }
    }
}' "false"

# Test 9: Invalid audio increment
run_test "Invalid audio increment" '{
    "version": "1.0.0",
    "services": {
        "audio": {
            "increment": 0
        }
    }
}' "false"

# Test 10: Invalid hot-reload debounce
run_test "Invalid debounce value" '{
    "version": "1.0.0",
    "hotReload": {
        "debounceMs": -500
    }
}' "false"

# Test 11: Valid complete configuration
run_test "Valid complete config" '{
    "version": "1.0.0",
    "metadata": {
        "created": "2025-08-12T00:00:00Z",
        "profile": "default"
    },
    "appearance": {
        "rounding": {
            "small": 12,
            "normal": 17
        }
    },
    "bar": {
        "position": "top",
        "height": 30
    },
    "commands": {
        "terminal": "kitty",
        "logout": ["loginctl", "terminate-user", "arthur"]
    },
    "hotReload": {
        "enabled": true,
        "debounceMs": 500
    }
}' "true"

# Test 12: Invalid module enabled type
run_test "Invalid module enabled type" '{
    "version": "1.0.0",
    "modules": {
        "dashboard": {
            "enabled": "yes"
        }
    }
}' "false"

# Test 13: Invalid font size
run_test "Invalid font size" '{
    "version": "1.0.0",
    "appearance": {
        "font": {
            "size": {
                "normal": 0
            }
        }
    }
}' "false"

# Test 14: Invalid wallpaper mode
run_test "Invalid wallpaper mode" '{
    "version": "1.0.0",
    "wallpaper": {
        "mode": "invalid"
    }
}' "false"

# Test 15: Valid wallpaper config
run_test "Valid wallpaper config" '{
    "version": "1.0.0",
    "wallpaper": {
        "current": "~/Pictures/test.jpg",
        "mode": "fill",
        "transition": {
            "type": "fade",
            "duration": 300
        }
    }
}' "true"

echo ""
echo "======================================"
echo -e "Results: ${GREEN}$TESTS_PASSED passed${NC}, ${RED}$TESTS_FAILED failed${NC}"

# Clean up
rm -rf "$TEMP_DIR"

# Exit with error if any tests failed
if [ $TESTS_FAILED -gt 0 ]; then
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi