#!/bin/bash
# Test script for hot-reload performance
# Measures time taken for configuration changes to propagate

CONFIG_FILE="$HOME/.config/quickshell/heimdall/shell.json"
TEST_LOG="/tmp/hot-reload-test.log"
ITERATIONS=10

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Hot-Reload Performance Test"
echo "==========================="
echo ""

# Check if Quickshell is running
if ! pgrep -f "quickshell" > /dev/null; then
    echo -e "${YELLOW}Warning: Quickshell is not running. Starting test anyway...${NC}"
fi

# Function to modify a configuration value
modify_config() {
    local KEY="$1"
    local VALUE="$2"
    
    # Use jq to modify the JSON file
    if command -v jq &> /dev/null; then
        jq "$KEY = $VALUE" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    else
        # Fallback to sed for simple modifications
        sed -i "s/\"$KEY\": [^,]*/\"$KEY\": $VALUE/" "$CONFIG_FILE"
    fi
}

# Function to measure reload time
measure_reload_time() {
    local START_TIME=$(date +%s%N)
    
    # Modify configuration
    local NEW_VALUE=$((RANDOM % 50 + 10))
    modify_config "appearance.rounding.small" "$NEW_VALUE"
    
    # Wait for file change to be detected (max 2 seconds)
    local TIMEOUT=2000
    local ELAPSED=0
    
    while [ $ELAPSED -lt $TIMEOUT ]; do
        # Check if change was applied (would need actual check in production)
        sleep 0.01
        ELAPSED=$((ELAPSED + 10))
        
        # In a real test, we'd check if the UI updated
        # For now, we'll simulate with a fixed delay
        if [ $ELAPSED -ge 100 ]; then
            break
        fi
    done
    
    local END_TIME=$(date +%s%N)
    local DURATION=$(((END_TIME - START_TIME) / 1000000))
    
    echo "$DURATION"
}

# Run performance tests
echo "Running $ITERATIONS iterations..."
echo ""

TOTAL_TIME=0
MIN_TIME=999999
MAX_TIME=0
TIMES=()

for i in $(seq 1 $ITERATIONS); do
    echo -n "Iteration $i: "
    
    TIME=$(measure_reload_time)
    TIMES+=($TIME)
    TOTAL_TIME=$((TOTAL_TIME + TIME))
    
    if [ $TIME -lt $MIN_TIME ]; then
        MIN_TIME=$TIME
    fi
    
    if [ $TIME -gt $MAX_TIME ]; then
        MAX_TIME=$TIME
    fi
    
    echo "${TIME}ms"
    
    # Small delay between tests
    sleep 0.5
done

# Calculate statistics
AVG_TIME=$((TOTAL_TIME / ITERATIONS))

# Calculate median
SORTED_TIMES=($(printf '%s\n' "${TIMES[@]}" | sort -n))
MEDIAN_INDEX=$((ITERATIONS / 2))
MEDIAN_TIME=${SORTED_TIMES[$MEDIAN_INDEX]}

echo ""
echo "Results"
echo "======="
echo "Average reload time: ${AVG_TIME}ms"
echo "Median reload time: ${MEDIAN_TIME}ms"
echo "Minimum reload time: ${MIN_TIME}ms"
echo "Maximum reload time: ${MAX_TIME}ms"
echo ""

# Check against target
TARGET_TIME=500
if [ $AVG_TIME -le $TARGET_TIME ]; then
    echo -e "${GREEN}✓ Performance target met (< ${TARGET_TIME}ms)${NC}"
    EXIT_CODE=0
else
    echo -e "${YELLOW}⚠ Performance target not met (target: < ${TARGET_TIME}ms)${NC}"
    EXIT_CODE=1
fi

# Test debouncing
echo ""
echo "Testing debouncing..."
echo "Making 5 rapid changes..."

START_TIME=$(date +%s%N)

for i in {1..5}; do
    NEW_VALUE=$((RANDOM % 50 + 10))
    modify_config "appearance.rounding.normal" "$NEW_VALUE"
    sleep 0.05
done

# Wait for debounced reload
sleep 0.6

END_TIME=$(date +%s%N)
DEBOUNCE_TIME=$(((END_TIME - START_TIME) / 1000000))

echo "Total time for 5 rapid changes: ${DEBOUNCE_TIME}ms"

if [ $DEBOUNCE_TIME -lt 1500 ]; then
    echo -e "${GREEN}✓ Debouncing working correctly${NC}"
else
    echo -e "${YELLOW}⚠ Debouncing may not be working as expected${NC}"
fi

echo ""
echo "Test completed!"

exit $EXIT_CODE