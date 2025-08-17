#!/bin/bash

# Integration script for enhanced configuration system
# This script helps integrate the new configuration components

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HEIMDALL_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$HEIMDALL_DIR/config"
UTILS_DIR="$HEIMDALL_DIR/utils"

echo "========================================="
echo "Enhanced Configuration Integration"
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

# Check if components exist
check_components() {
    echo "Checking components..."
    
    local all_exist=true
    
    if [ -f "$UTILS_DIR/ConfigPropertyAssigner.qml" ]; then
        print_status "OK" "ConfigPropertyAssigner.qml exists"
    else
        print_status "FAIL" "ConfigPropertyAssigner.qml not found"
        all_exist=false
    fi
    
    if [ -f "$CONFIG_DIR/ConfigV2.qml" ]; then
        print_status "OK" "ConfigV2.qml exists"
    else
        print_status "FAIL" "ConfigV2.qml not found"
        all_exist=false
    fi
    
    if [ -f "$UTILS_DIR/TypeConverter.qml" ]; then
        print_status "OK" "TypeConverter.qml exists"
    else
        print_status "FAIL" "TypeConverter.qml not found"
        all_exist=false
    fi
    
    if [ -f "$UTILS_DIR/HotReloadManager.qml" ]; then
        print_status "OK" "HotReloadManager.qml exists"
    else
        print_status "FAIL" "HotReloadManager.qml not found"
        all_exist=false
    fi
    
    if [ "$all_exist" = true ]; then
        return 0
    else
        return 1
    fi
}

# Backup current Config.qml
backup_config() {
    echo ""
    echo "Backing up current configuration..."
    
    if [ -f "$CONFIG_DIR/Config.qml" ]; then
        local backup_name="Config.qml.bak.$(date +%Y%m%d_%H%M%S)"
        cp "$CONFIG_DIR/Config.qml" "$CONFIG_DIR/$backup_name"
        print_status "OK" "Backed up to $backup_name"
        echo "$CONFIG_DIR/$backup_name"
    else
        print_status "WARN" "No Config.qml to backup"
        echo ""
    fi
}

# Integrate enhanced config
integrate_config() {
    echo ""
    echo "Integration options:"
    echo "1. Test mode - Use ConfigV2.qml alongside Config.qml"
    echo "2. Replace mode - Replace Config.qml with ConfigV2.qml"
    echo "3. Info only - Show integration instructions"
    echo ""
    read -p "Select option (1-3): " option
    
    case $option in
        1)
            echo ""
            echo "Test Mode Integration"
            echo "--------------------"
            echo "ConfigV2.qml is ready for testing."
            echo ""
            echo "To use it in your QML files, import and reference ConfigV2 instead of Config:"
            echo "  import '../config' as Config"
            echo "  // Use Config.ConfigV2 instead of Config.Config"
            echo ""
            print_status "OK" "Test mode ready"
            ;;
            
        2)
            echo ""
            echo "Replace Mode Integration"
            echo "-----------------------"
            
            # Backup first
            local backup_file=$(backup_config)
            
            # Replace Config.qml with ConfigV2.qml
            if [ -f "$CONFIG_DIR/ConfigV2.qml" ]; then
                cp "$CONFIG_DIR/ConfigV2.qml" "$CONFIG_DIR/Config.qml"
                print_status "OK" "Replaced Config.qml with enhanced version"
                
                if [ -n "$backup_file" ]; then
                    echo ""
                    echo "To revert if needed:"
                    echo "  cp '$backup_file' '$CONFIG_DIR/Config.qml'"
                fi
            else
                print_status "FAIL" "ConfigV2.qml not found"
                return 1
            fi
            ;;
            
        3)
            echo ""
            echo "Integration Instructions"
            echo "-----------------------"
            echo ""
            echo "The enhanced configuration system provides:"
            echo "  • Nested object support (e.g., launcher.sizes.itemWidth)"
            echo "  • Type conversion (string to number, boolean, color, etc.)"
            echo "  • Hot reload with debouncing"
            echo "  • Validation and rollback"
            echo "  • Backup management"
            echo ""
            echo "To integrate manually:"
            echo "1. Backup current Config.qml"
            echo "2. Copy ConfigV2.qml to Config.qml"
            echo "3. Restart quickshell"
            echo "4. Test with nested configuration"
            echo ""
            echo "Example configuration structure:"
            echo '{'
            echo '  "modules": {'
            echo '    "launcher": {'
            echo '      "sizes": {'
            echo '        "itemWidth": 200'
            echo '      }'
            echo '    }'
            echo '  }'
            echo '}'
            ;;
            
        *)
            print_status "FAIL" "Invalid option"
            return 1
            ;;
    esac
}

# Test the configuration
test_config() {
    echo ""
    read -p "Run configuration tests? (y/n): " run_tests
    
    if [ "$run_tests" = "y" ] || [ "$run_tests" = "Y" ]; then
        echo ""
        echo "Running tests..."
        
        if [ -f "$SCRIPT_DIR/test-nested-config.sh" ]; then
            bash "$SCRIPT_DIR/test-nested-config.sh"
        else
            print_status "FAIL" "Test script not found"
        fi
    fi
}

# Main execution
main() {
    echo "This script will help integrate the enhanced configuration system."
    echo ""
    
    # Check components
    if ! check_components; then
        echo ""
        print_status "FAIL" "Missing required components"
        echo "Please ensure all components are created first."
        exit 1
    fi
    
    # Integrate
    integrate_config
    
    # Offer to test
    test_config
    
    echo ""
    echo "========================================="
    echo "Integration complete!"
    echo ""
    echo "Configuration files location:"
    echo "  $HOME/.config/heimdall/shell.json"
    echo ""
    echo "Test configuration available at:"
    echo "  $HOME/.config/heimdall/test-config.json"
    echo ""
    echo "For more information, see:"
    echo "  $HEIMDALL_DIR/../docs/plans/heimdall-config-plan.md"
    echo "========================================="
}

# Run main function
main "$@"