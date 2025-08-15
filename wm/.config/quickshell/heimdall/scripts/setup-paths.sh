#!/bin/bash
# Setup script for Quickshell Heimdall path alignment
# Creates necessary directories and symlinks for compatibility

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "Quickshell Heimdall Path Setup"
echo "==============================="
echo ""

# Function to create directory if it doesn't exist
create_dir() {
    local DIR="$1"
    if [ ! -d "$DIR" ]; then
        mkdir -p "$DIR"
        echo -e "${GREEN}✓ Created directory: $DIR${NC}"
    else
        echo -e "  Directory exists: $DIR"
    fi
}

# Function to create symlink
create_symlink() {
    local TARGET="$1"
    local LINK="$2"
    
    if [ -L "$LINK" ]; then
        # Symlink exists, check if it points to the right place
        CURRENT_TARGET=$(readlink "$LINK")
        if [ "$CURRENT_TARGET" = "$TARGET" ]; then
            echo -e "  Symlink correct: $LINK -> $TARGET"
        else
            echo -e "${YELLOW}⚠ Updating symlink: $LINK${NC}"
            rm "$LINK"
            ln -sf "$TARGET" "$LINK"
            echo -e "${GREEN}✓ Updated symlink: $LINK -> $TARGET${NC}"
        fi
    elif [ -e "$LINK" ]; then
        echo -e "${RED}✗ Path exists but is not a symlink: $LINK${NC}"
        echo "  Please backup and remove it manually"
    else
        ln -sf "$TARGET" "$LINK"
        echo -e "${GREEN}✓ Created symlink: $LINK -> $TARGET${NC}"
    fi
}

# Step 1: Create state directories
echo "Creating state directories..."
create_dir "$HOME/.local/state/quickshell/user/generated"
create_dir "$HOME/.local/state/quickshell/user/generated/wallpaper"
create_dir "$HOME/.local/state/quickshell/user/generated/colors"
create_dir "$HOME/.local/state/quickshell/user/generated/config"

# Step 2: Create cache directories
echo ""
echo "Creating cache directories..."
create_dir "$HOME/.cache/quickshell"
create_dir "$HOME/.cache/quickshell/thumbnails"

# Step 3: Create config backup directory
echo ""
echo "Creating backup directory..."
create_dir "$HOME/.config/quickshell/heimdall/backups"

# Step 4: Create compatibility symlinks
echo ""
echo "Creating compatibility symlinks..."
create_symlink "$HOME/.local/state/quickshell/user/generated" "$HOME/.local/state/heimdall"

# Step 5: Check for existing wallpaper state
echo ""
echo "Checking wallpaper state..."
WALLPAPER_FILE="$HOME/.local/state/quickshell/user/generated/wallpaper/path.txt"
if [ -f "$WALLPAPER_FILE" ]; then
    CURRENT_WALLPAPER=$(cat "$WALLPAPER_FILE")
    echo -e "  Current wallpaper: $CURRENT_WALLPAPER"
    
    # Verify wallpaper exists
    if [ -f "$CURRENT_WALLPAPER" ]; then
        echo -e "${GREEN}✓ Wallpaper file exists${NC}"
    else
        echo -e "${YELLOW}⚠ Wallpaper file not found: $CURRENT_WALLPAPER${NC}"
    fi
else
    echo -e "${YELLOW}⚠ No wallpaper state file found${NC}"
    
    # Try to find a default wallpaper
    DEFAULT_WALLPAPER="$HOME/Pictures/Wallpapers/Autumn-Alley.jpg"
    if [ -f "$DEFAULT_WALLPAPER" ]; then
        echo "$DEFAULT_WALLPAPER" > "$WALLPAPER_FILE"
        echo -e "${GREEN}✓ Created wallpaper state with default${NC}"
    fi
fi

# Step 6: Set up environment variables
echo ""
echo "Setting up environment variables..."
ENV_FILE="$HOME/.config/quickshell/heimdall/env.sh"
cat > "$ENV_FILE" << 'EOF'
#!/bin/bash
# Environment variables for Quickshell Heimdall

export HEIMDALL_STATE_DIR="$HOME/.local/state/quickshell/user/generated"
export QS_CONFIG_NAME="heimdall"
export HEIMDALL_BACKEND="swww"
export QUICKSHELL_CONFIG_PATH="$HOME/.config/quickshell/heimdall"
EOF

chmod +x "$ENV_FILE"
echo -e "${GREEN}✓ Created environment file: $ENV_FILE${NC}"

# Step 7: Check for required programs
echo ""
echo "Checking required programs..."
MISSING_PROGRAMS=()

check_program() {
    local PROGRAM="$1"
    if command -v "$PROGRAM" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $PROGRAM found"
    else
        echo -e "  ${RED}✗${NC} $PROGRAM not found"
        MISSING_PROGRAMS+=("$PROGRAM")
    fi
}

check_program "quickshell"
check_program "heimdall"
check_program "swww"
check_program "hyprlock"
check_program "jq"

if [ ${#MISSING_PROGRAMS[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Warning: Some programs are missing:${NC}"
    for prog in "${MISSING_PROGRAMS[@]}"; do
        echo "  - $prog"
    done
    echo "Some features may not work correctly."
fi

# Step 8: Verify configuration
echo ""
echo "Verifying configuration..."
CONFIG_FILE="$HOME/.config/quickshell/heimdall/shell.json"
if [ -f "$CONFIG_FILE" ]; then
    echo -e "  Configuration file exists: $CONFIG_FILE"
    
    # Validate if validator exists
    VALIDATOR="$HOME/.config/quickshell/heimdall/scripts/validate-config.py"
    if [ -f "$VALIDATOR" ]; then
        if python3 "$VALIDATOR" "$CONFIG_FILE" > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Configuration is valid${NC}"
        else
            echo -e "${YELLOW}⚠ Configuration validation failed${NC}"
            echo "  Run: python3 $VALIDATOR $CONFIG_FILE"
        fi
    fi
else
    echo -e "${YELLOW}⚠ Configuration file not found${NC}"
    echo "  Run migration script to create it"
fi

# Summary
echo ""
echo "==============================="
echo "Setup Summary"
echo "==============================="
echo -e "${GREEN}✓ Directories created${NC}"
echo -e "${GREEN}✓ Symlinks established${NC}"
echo -e "${GREEN}✓ Environment configured${NC}"

if [ ${#MISSING_PROGRAMS[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ All required programs found${NC}"
else
    echo -e "${YELLOW}⚠ Some programs missing${NC}"
fi

echo ""
echo "Next steps:"
echo "1. Source the environment file: source $ENV_FILE"
echo "2. Run the migration script if needed: $HOME/.config/quickshell/heimdall/scripts/migrate-config.py"
echo "3. Restart Quickshell to apply changes"

echo ""
echo "Setup complete!"