#!/bin/bash

# Test script for nested configuration support
# This script tests the enhanced configuration system with nested objects

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/heimdall"
CONFIG_FILE="$CONFIG_DIR/shell.json"
TEST_CONFIG="$CONFIG_DIR/test-config.json"

echo "========================================="
echo "Heimdall Nested Configuration Test"
echo "========================================="
echo ""

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    
    if [ "$status" = "OK" ]; then
        echo -e "\033[32m✓\033[0m $message"
    elif [ "$status" = "FAIL" ]; then
        echo -e "\033[31m✗\033[0m $message"
    else
        echo -e "\033[33m⚠\033[0m $message"
    fi
}

# Check if quickshell is running
check_quickshell() {
    if pgrep -f "qs.*heimdall" > /dev/null; then
        print_status "OK" "Quickshell is running"
        return 0
    else
        print_status "WARN" "Quickshell is not running"
        return 1
    fi
}

# Backup current configuration
backup_config() {
    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" "$CONFIG_FILE.bak.$(date +%Y%m%d_%H%M%S)"
        print_status "OK" "Backed up current configuration"
    else
        print_status "WARN" "No existing configuration to backup"
    fi
}

# Test 1: Empty configuration
test_empty_config() {
    echo ""
    echo "Test 1: Empty Configuration"
    echo "----------------------------"
    
    echo '{}' > "$CONFIG_FILE"
    print_status "OK" "Created empty configuration"
    
    sleep 1
    
    if check_quickshell; then
        print_status "OK" "Quickshell handles empty config"
    else
        print_status "FAIL" "Quickshell crashed with empty config"
        return 1
    fi
}

# Test 2: Simple flat configuration
test_flat_config() {
    echo ""
    echo "Test 2: Flat Configuration"
    echo "--------------------------"
    
    cat > "$CONFIG_FILE" << 'EOF'
{
  "version": "1.0.0",
  "modules": {
    "launcher": {
      "enabled": true,
      "vimKeybinds": true
    }
  }
}
EOF
    
    print_status "OK" "Applied flat configuration"
    sleep 1
    
    if check_quickshell; then
        print_status "OK" "Quickshell handles flat config"
    else
        print_status "FAIL" "Quickshell crashed with flat config"
        return 1
    fi
}

# Test 3: Nested configuration
test_nested_config() {
    echo ""
    echo "Test 3: Nested Configuration"
    echo "----------------------------"
    
    if [ -f "$TEST_CONFIG" ]; then
        cp "$TEST_CONFIG" "$CONFIG_FILE"
        print_status "OK" "Applied nested test configuration"
    else
        print_status "FAIL" "Test configuration not found at $TEST_CONFIG"
        return 1
    fi
    
    sleep 1
    
    if check_quickshell; then
        print_status "OK" "Quickshell handles nested config"
        
        # Check if the configuration was loaded (by checking logs)
        if journalctl -u quickshell --since "1 minute ago" 2>/dev/null | grep -q "launcher.sizes"; then
            print_status "OK" "Nested properties detected in logs"
        else
            print_status "WARN" "Could not verify nested properties in logs"
        fi
    else
        print_status "FAIL" "Quickshell crashed with nested config"
        return 1
    fi
}

# Test 4: Hot reload with changes
test_hot_reload() {
    echo ""
    echo "Test 4: Hot Reload"
    echo "------------------"
    
    # Initial config
    cat > "$CONFIG_FILE" << 'EOF'
{
  "version": "1.0.0",
  "modules": {
    "launcher": {
      "enabled": true,
      "sizes": {
        "itemWidth": 100
      }
    }
  }
}
EOF
    
    print_status "OK" "Set initial configuration"
    sleep 2
    
    # Modify config
    cat > "$CONFIG_FILE" << 'EOF'
{
  "version": "1.0.0",
  "modules": {
    "launcher": {
      "enabled": true,
      "sizes": {
        "itemWidth": 200,
        "itemHeight": 50
      }
    }
  }
}
EOF
    
    print_status "OK" "Modified configuration"
    sleep 2
    
    if check_quickshell; then
        print_status "OK" "Quickshell survived hot reload"
    else
        print_status "FAIL" "Quickshell crashed during hot reload"
        return 1
    fi
}

# Test 5: Invalid configuration handling
test_invalid_config() {
    echo ""
    echo "Test 5: Invalid Configuration"
    echo "-----------------------------"
    
    # Save valid config first
    cp "$CONFIG_FILE" "$CONFIG_FILE.valid"
    
    # Apply invalid JSON
    echo '{ invalid json }' > "$CONFIG_FILE"
    print_status "OK" "Applied invalid JSON"
    
    sleep 2
    
    if check_quickshell; then
        print_status "OK" "Quickshell survived invalid config"
    else
        print_status "FAIL" "Quickshell crashed with invalid config"
        # Restore valid config
        cp "$CONFIG_FILE.valid" "$CONFIG_FILE"
        return 1
    fi
    
    # Restore valid config
    cp "$CONFIG_FILE.valid" "$CONFIG_FILE"
    rm "$CONFIG_FILE.valid"
}

# Test 6: Performance with large config
test_large_config() {
    echo ""
    echo "Test 6: Large Configuration"
    echo "---------------------------"
    
    # Generate large config
    cat > "$CONFIG_FILE" << 'EOF'
{
  "version": "1.0.0",
  "modules": {
EOF
    
    # Add many modules
    for i in {1..10}; do
        if [ $i -gt 1 ]; then echo "," >> "$CONFIG_FILE"; fi
        cat >> "$CONFIG_FILE" << EOF
    "module$i": {
      "enabled": true,
      "nested": {
        "level1": {
          "level2": {
            "level3": {
              "value": $i
            }
          }
        }
      }
    }
EOF
    done
    
    echo '  }' >> "$CONFIG_FILE"
    echo '}' >> "$CONFIG_FILE"
    
    print_status "OK" "Applied large configuration"
    sleep 2
    
    if check_quickshell; then
        print_status "OK" "Quickshell handles large config"
    else
        print_status "FAIL" "Quickshell crashed with large config"
        return 1
    fi
}

# Main test execution
main() {
    echo "Starting configuration tests..."
    echo ""
    
    # Check prerequisites
    if ! check_quickshell; then
        echo ""
        echo "Please start quickshell first:"
        echo "  qs -c heimdall -n &"
        exit 1
    fi
    
    # Backup current config
    backup_config
    
    # Run tests
    local failed=0
    
    test_empty_config || ((failed++))
    test_flat_config || ((failed++))
    test_nested_config || ((failed++))
    test_hot_reload || ((failed++))
    test_invalid_config || ((failed++))
    test_large_config || ((failed++))
    
    # Summary
    echo ""
    echo "========================================="
    echo "Test Summary"
    echo "========================================="
    
    if [ $failed -eq 0 ]; then
        print_status "OK" "All tests passed!"
        
        # Apply the full test configuration
        if [ -f "$TEST_CONFIG" ]; then
            echo ""
            echo "Applying full test configuration..."
            cp "$TEST_CONFIG" "$CONFIG_FILE"
            print_status "OK" "Test configuration applied"
            echo ""
            echo "You can now test the nested configuration features:"
            echo "  - Check launcher sizes: launcher.sizes.itemWidth"
            echo "  - Check colors: launcher.colors.background"
            echo "  - Check animations: appearance.animations.duration"
        fi
    else
        print_status "FAIL" "$failed test(s) failed"
        echo ""
        echo "Please check the implementation and try again."
    fi
    
    echo ""
    echo "Configuration file: $CONFIG_FILE"
    echo "Test complete."
}

# Run main function
main "$@"