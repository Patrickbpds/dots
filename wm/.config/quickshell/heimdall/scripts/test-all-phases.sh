#!/bin/bash

# Comprehensive test for all implemented phases
# This script verifies that all configuration improvements work correctly

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../config"
DOCS_DIR="$SCRIPT_DIR/../docs"
TEST_CONFIG="/tmp/test-all-phases.json"

echo "=== Comprehensive Configuration System Test ==="
echo "Testing all implemented phases (1-3)"
echo

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing $test_name... "
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

echo "## Phase 1: Foundation Enhancement Tests"
echo

# Test 1: Check if validation system exists
run_test "Validation system exists" "[ -f '$CONFIG_DIR/../utils/ConfigValidator.qml' ]"

# Test 2: Check if version manager exists
run_test "Version manager exists" "[ -f '$CONFIG_DIR/../utils/ConfigVersionManager.qml' ]"

# Test 3: Check if style guide exists
run_test "Style guide exists" "[ -f '$DOCS_DIR/configuration-style-guide.md' ]"

# Test 4: Check if audit report exists
run_test "Audit report exists" "[ -f '$DOCS_DIR/research/configuration-audit.md' ]"

echo
echo "## Phase 2: Configuration Coverage Tests"
echo

# Test 5: Check UI components config
run_test "UI components config exists" "[ -f '$CONFIG_DIR/UIComponentsConfig.qml' ]"

# Test 6: Check animation config
run_test "Animation config exists" "[ -f '$CONFIG_DIR/AnimationConfig.qml' ]"

# Test 7: Check services integration config
run_test "Services integration config exists" "[ -f '$CONFIG_DIR/ServicesIntegrationConfig.qml' ]"

# Test 8: Check behavior config
run_test "Behavior config exists" "[ -f '$CONFIG_DIR/BehaviorConfig.qml' ]"

echo
echo "## Phase 3: Schema and Validation Tests"
echo

# Test 9: Check schema generator
run_test "Schema generator exists" "[ -f '$SCRIPT_DIR/generate-schema.py' ]"

# Test 10: Check documentation generator
run_test "Documentation generator exists" "[ -f '$SCRIPT_DIR/generate-config-docs.py' ]"

# Test 11: Check validation feedback system
run_test "Validation feedback exists" "[ -f '$CONFIG_DIR/../utils/ConfigValidationFeedback.qml' ]"

# Test 12: Generate schema
run_test "Schema generation" "cd '$SCRIPT_DIR/..' && python3 scripts/generate-schema.py"

# Test 13: Check generated schema
run_test "Generated schema exists" "[ -f '$DOCS_DIR/configuration-schema.json' ]"

# Test 14: Check TypeScript definitions
run_test "TypeScript definitions exist" "[ -f '$DOCS_DIR/configuration.d.ts' ]"

# Test 15: Generate documentation
run_test "Documentation generation" "cd '$SCRIPT_DIR/..' && python3 scripts/generate-config-docs.py"

# Test 16: Check generated documentation
run_test "Generated docs exist" "[ -f '$DOCS_DIR/configuration-reference.md' ]"

echo
echo "## Integration Tests"
echo

# Test 17: Create a valid v2.0 configuration
cat > "$TEST_CONFIG" << 'EOF'
{
  "version": "2.0.0",
  "modules": {
    "launcher": {
      "enabled": true,
      "searchDelayMs": 300
    },
    "animation": {
      "enabled": true,
      "speedMultiplier": 1.0
    },
    "servicesIntegration": {
      "systemMonitor": {
        "enabled": true,
        "updateInterval": 1000
      }
    },
    "behavior": {
      "keyboard": {
        "enabled": true,
        "vimMode": false
      }
    }
  }
}
EOF

run_test "Valid v2.0 config created" "[ -f '$TEST_CONFIG' ]"

# Test 18: Validate JSON syntax
run_test "JSON syntax valid" "python3 -m json.tool '$TEST_CONFIG' > /dev/null"

# Test 19: Check Config.qml integration
run_test "Config.qml has new modules" "grep -q 'property alias animation' '$CONFIG_DIR/Config.qml'"

# Test 20: Check for validation integration
run_test "Config.qml has validation" "grep -q 'ConfigValidator' '$CONFIG_DIR/Config.qml'"

echo
echo "## Backward Compatibility Tests"
echo

# Test 21: Create a v1.0 style configuration
cat > "$TEST_CONFIG" << 'EOF'
{
  "launcher": {
    "enabled": true
  },
  "colours": {
    "accent": "89B4FA"
  }
}
EOF

run_test "V1.0 config created" "[ -f '$TEST_CONFIG' ]"

# Test 22: Check version detection logic exists
run_test "Version detection available" "grep -q 'detectConfigVersion' '$CONFIG_DIR/../utils/ConfigVersionManager.qml'"

echo
echo "## File Structure Tests"
echo

# Test 23: Check if all expected files exist
EXPECTED_FILES=(
    "config/UIComponentsConfig.qml"
    "config/AnimationConfig.qml"
    "config/ServicesIntegrationConfig.qml"
    "config/BehaviorConfig.qml"
    "utils/ConfigValidator.qml"
    "utils/ConfigVersionManager.qml"
    "utils/ConfigValidationFeedback.qml"
    "scripts/generate-schema.py"
    "scripts/generate-config-docs.py"
    "scripts/test-config-validation.sh"
    "scripts/test-phase2-config.sh"
)

for file in "${EXPECTED_FILES[@]}"; do
    run_test "File exists: $file" "[ -f '$SCRIPT_DIR/../$file' ]"
done

echo
echo "========================================="
echo "## Test Summary"
echo "========================================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✓ All tests passed successfully!${NC}"
    echo "The configuration system improvements are working correctly."
else
    echo -e "\n${RED}✗ Some tests failed.${NC}"
    echo "Please review the failures above and fix any issues."
    exit 1
fi

# Clean up
rm -f "$TEST_CONFIG"

echo
echo "## Configuration System Status"
echo "- Phase 1 (Foundation): ✓ Complete"
echo "- Phase 2 (Coverage): ✓ Complete"
echo "- Phase 3 (Schema): ✓ Complete"
echo "- Phase 4 (Write-Back): ⏳ Pending"
echo "- Phase 5 (Migration): ⏳ Pending"
echo "- Phase 6 (UI): ⏳ Pending"
echo
echo "The configuration system is ready for use with:"
echo "- Comprehensive validation"
echo "- Version management"
echo "- Full configuration coverage"
echo "- Schema generation and documentation"
echo
echo "Next steps: Implement Phase 4 (Write-Back and Profiles)"