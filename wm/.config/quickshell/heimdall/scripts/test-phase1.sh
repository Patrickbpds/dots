#!/bin/bash
# Comprehensive test script for Phase 1 acceptance criteria
# Tests all critical fixes implemented in Phase 1

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

echo "Phase 1 Acceptance Tests"
echo "========================"
echo ""

# Function to run a test
run_test() {
    local TEST_NAME="$1"
    local TEST_CMD="$2"
    
    echo -n "Testing: $TEST_NAME... "
    
    if eval "$TEST_CMD"; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test 1: Logout command has username
echo "1. Session Commands Tests"
echo "--------------------------"

test_logout_command() {
    local SESSION_CONFIG="/home/arthur/dots/wm/.config/quickshell/heimdall/config/SessionConfig.qml"
    
    # Check if file exists
    [ -f "$SESSION_CONFIG" ] || return 1
    
    # Check if it contains the fix
    grep -q 'Quickshell.env("USER")' "$SESSION_CONFIG" || return 1
    
    # Check for fallback
    grep -q 'hyprctl.*dispatch.*exit' "$SESSION_CONFIG" || return 1
    
    return 0
}

run_test "Logout command fix" test_logout_command

# Test 2: Wallpaper persistence scripts
echo ""
echo "2. Wallpaper Persistence Tests"
echo "-------------------------------"

test_wallpaper_sync() {
    local SYNC_SCRIPT="/home/arthur/dots/wm/.config/hypr/programs/wallpaper-sync.sh"
    [ -f "$SYNC_SCRIPT" ] && [ -x "$SYNC_SCRIPT" ]
}

test_wallpaper_restore() {
    local RESTORE_SCRIPT="/home/arthur/dots/wm/.config/hypr/programs/restore-wallpaper.sh"
    [ -f "$RESTORE_SCRIPT" ] && [ -x "$RESTORE_SCRIPT" ]
}

test_wallpaper_state() {
    local STATE_FILE="$HOME/.local/state/quickshell/user/generated/wallpaper/path.txt"
    [ -f "$STATE_FILE" ] && [ -s "$STATE_FILE" ]
}

run_test "Wallpaper sync script exists" test_wallpaper_sync
run_test "Wallpaper restore script exists" test_wallpaper_restore
run_test "Wallpaper state file exists" test_wallpaper_state

# Test 3: Startup sequence
echo ""
echo "3. Startup Sequence Tests"
echo "-------------------------"

test_startup_orchestrator() {
    local ORCHESTRATOR="/home/arthur/dots/wm/.config/hypr/programs/startup-orchestrator.sh"
    [ -f "$ORCHESTRATOR" ] && [ -x "$ORCHESTRATOR" ]
}

test_startup_config() {
    local EXECS_CONF="/home/arthur/dots/wm/.config/hypr/hyprland/execs.conf"
    [ -f "$EXECS_CONF" ] && grep -q "startup-orchestrator.sh" "$EXECS_CONF"
}

run_test "Startup orchestrator exists" test_startup_orchestrator
run_test "Startup orchestrator configured" test_startup_config

# Test 4: Docker Desktop fix
echo ""
echo "4. Docker Desktop Tests"
echo "-----------------------"

test_docker_script() {
    local DOCKER_SCRIPT="/home/arthur/dots/wm/.config/hypr/programs/docker-desktop.sh"
    [ -f "$DOCKER_SCRIPT" ] && [ -x "$DOCKER_SCRIPT" ]
}

test_docker_no_systemd() {
    local DOCKER_SCRIPT="/home/arthur/dots/wm/.config/hypr/programs/docker-desktop.sh"
    [ -f "$DOCKER_SCRIPT" ] && ! grep -q "systemctl.*--user.*stop" "$DOCKER_SCRIPT"
}

run_test "Docker Desktop script exists" test_docker_script
run_test "Docker script avoids systemd manipulation" test_docker_no_systemd

# Test 5: Base JSON configuration
echo ""
echo "5. JSON Configuration Tests"
echo "---------------------------"

test_json_exists() {
    local JSON_FILE="/home/arthur/dots/wm/.config/quickshell/heimdall/shell.json"
    [ -f "$JSON_FILE" ]
}

test_json_valid() {
    local JSON_FILE="/home/arthur/dots/wm/.config/quickshell/heimdall/shell.json"
    local VALIDATOR="/home/arthur/dots/wm/.config/quickshell/heimdall/scripts/validate-config.py"
    
    if [ -f "$VALIDATOR" ] && [ -f "$JSON_FILE" ]; then
        python3 "$VALIDATOR" "$JSON_FILE" > /dev/null 2>&1
    else
        return 1
    fi
}

test_json_has_fixes() {
    local JSON_FILE="/home/arthur/dots/wm/.config/quickshell/heimdall/shell.json"
    [ -f "$JSON_FILE" ] || return 1
    
    # Check for key sections
    python3 -c "
import json
with open('$JSON_FILE') as f:
    config = json.load(f)
    assert 'version' in config
    assert 'system' in config
    assert 'commands' in config
    assert 'wallpaper' in config
    assert 'hotReload' in config
" 2>/dev/null
}

run_test "shell.json exists" test_json_exists
run_test "shell.json is valid" test_json_valid
run_test "shell.json has required sections" test_json_has_fixes

# Test 6: All scripts are executable
echo ""
echo "6. Script Permissions Tests"
echo "---------------------------"

test_scripts_executable() {
    local SCRIPTS=(
        "/home/arthur/dots/wm/.config/hypr/programs/wallpaper-sync.sh"
        "/home/arthur/dots/wm/.config/hypr/programs/restore-wallpaper.sh"
        "/home/arthur/dots/wm/.config/hypr/programs/startup-orchestrator.sh"
        "/home/arthur/dots/wm/.config/hypr/programs/docker-desktop.sh"
    )
    
    for script in "${SCRIPTS[@]}"; do
        [ -x "$script" ] || return 1
    done
    return 0
}

run_test "All scripts are executable" test_scripts_executable

# Summary
echo ""
echo "========================"
echo "Test Summary"
echo "========================"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ All Phase 1 acceptance criteria met!${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}✗ Some acceptance criteria not met${NC}"
    exit 1
fi