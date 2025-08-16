#!/bin/bash

# Heimdall Configuration Test Script
# Tests the configuration management functionality

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Configuration paths
NEW_CONFIG="$HOME/.config/heimdall/shell.json"
OLD_CONFIG="$HOME/.config/quickshell/heimdall/shell.json"
TEST_DIR="/tmp/heimdall-config-test"

echo "========================================="
echo "Heimdall Configuration Test Suite"
echo "========================================="
echo ""

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing: $test_name... "
    
    if eval "$test_command" &> /dev/null; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((TESTS_FAILED++))
    fi
}

# Test 1: Check if new config location exists
echo -e "${BLUE}Test Group 1: Configuration Location${NC}"
run_test "New config directory exists" "[ -d '$HOME/.config/heimdall' ]"
run_test "New config file exists" "[ -f '$NEW_CONFIG' ]"

# Test 2: Validate JSON structure
echo ""
echo -e "${BLUE}Test Group 2: JSON Validation${NC}"
if command -v jq &> /dev/null; then
    run_test "Valid JSON syntax" "jq empty '$NEW_CONFIG'"
    run_test "Has version field" "jq -e '.version' '$NEW_CONFIG'"
    run_test "Has metadata field" "jq -e '.metadata' '$NEW_CONFIG'"
    run_test "Has system field" "jq -e '.system' '$NEW_CONFIG'"
    run_test "Has appearance field" "jq -e '.appearance' '$NEW_CONFIG'"
    run_test "Has bar field" "jq -e '.bar' '$NEW_CONFIG'"
    run_test "Has modules field" "jq -e '.modules' '$NEW_CONFIG'"
    run_test "Has commands field" "jq -e '.commands' '$NEW_CONFIG'"
else
    echo -e "${YELLOW}Skipping JSON validation tests (jq not installed)${NC}"
fi

# Test 3: Check Quickshell configuration updates
echo ""
echo -e "${BLUE}Test Group 3: Quickshell Integration${NC}"
CONFIG_QML="$HOME/dots/wm/.config/quickshell/heimdall/config/Config.qml"
CONFIG_ENHANCED_QML="$HOME/dots/wm/.config/quickshell/heimdall/config/ConfigEnhanced.qml"

if [ -f "$CONFIG_QML" ]; then
    run_test "Config.qml updated" "grep -q '/.config/heimdall/shell.json' '$CONFIG_QML'"
else
    echo -e "${YELLOW}Config.qml not found${NC}"
fi

if [ -f "$CONFIG_ENHANCED_QML" ]; then
    run_test "ConfigEnhanced.qml updated" "grep -q '/.config/heimdall/shell.json' '$CONFIG_ENHANCED_QML'"
else
    echo -e "${YELLOW}ConfigEnhanced.qml not found${NC}"
fi

# Test 4: Check backup functionality
echo ""
echo -e "${BLUE}Test Group 4: Backup System${NC}"
BACKUP_DIR="$HOME/.config/heimdall/backups"
run_test "Backup directory exists" "[ -d '$BACKUP_DIR' ]"

# Test 5: Version check
echo ""
echo -e "${BLUE}Test Group 5: Version Management${NC}"
if command -v jq &> /dev/null && [ -f "$NEW_CONFIG" ]; then
    VERSION=$(jq -r '.version' "$NEW_CONFIG" 2>/dev/null || echo "unknown")
    echo "Configuration version: $VERSION"
    run_test "Version format valid" "echo '$VERSION' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$'"
fi

# Test 6: Required properties
echo ""
echo -e "${BLUE}Test Group 6: Required Properties${NC}"
if command -v jq &> /dev/null && [ -f "$NEW_CONFIG" ]; then
    # Check for essential properties
    run_test "Has terminal command" "jq -e '.commands.terminal' '$NEW_CONFIG'"
    run_test "Has wallpaper config" "jq -e '.wallpaper' '$NEW_CONFIG'"
    run_test "Has system paths" "jq -e '.system.paths' '$NEW_CONFIG'"
    run_test "Has bar height" "jq -e '.bar.height' '$NEW_CONFIG'"
fi

# Summary
echo ""
echo "========================================="
echo "Test Summary"
echo "========================================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}✗ Some tests failed. Please review the configuration.${NC}"
    exit 1
fi