#!/bin/bash
# Setup state directories for Quickshell Heimdall

echo "Setting up Quickshell Heimdall state directories..."

# Create state directories
mkdir -p ~/.local/state/quickshell/user/generated/{wallpaper,colors,config}
mkdir -p ~/.cache/quickshell/heimdall

# Create symlinks for backward compatibility
mkdir -p ~/.local/state/heimdall
ln -sfn ~/.local/state/quickshell/user/generated/wallpaper ~/.local/state/heimdall/wallpaper
ln -sfn ~/.local/state/quickshell/user/generated/colors ~/.local/state/heimdall/colors

# Check for current wallpaper and copy if exists
if [ -f ~/.local/state/heimdall/wallpaper/path.txt ]; then
    echo "Found existing wallpaper configuration, preserving..."
    cp ~/.local/state/heimdall/wallpaper/path.txt ~/.local/state/quickshell/user/generated/wallpaper/path.txt
elif [ -f ~/Pictures/Wallpapers/Autumn-Alley.jpg ]; then
    echo "Setting default wallpaper..."
    echo "$HOME/Pictures/Wallpapers/Autumn-Alley.jpg" > ~/.local/state/quickshell/user/generated/wallpaper/path.txt
fi

# Check for color scheme and copy if exists
if [ -f ~/.local/state/heimdall/scheme.json ]; then
    echo "Found existing color scheme, preserving..."
    cp ~/.local/state/heimdall/scheme.json ~/.local/state/quickshell/user/generated/colors/scheme.json
fi

echo "State directories setup complete!"
echo ""
echo "Created directories:"
echo "  ~/.local/state/quickshell/user/generated/wallpaper"
echo "  ~/.local/state/quickshell/user/generated/colors"
echo "  ~/.local/state/quickshell/user/generated/config"
echo "  ~/.cache/quickshell/heimdall"
echo ""
echo "Created symlinks:"
echo "  ~/.local/state/heimdall -> ~/.local/state/quickshell/user/generated"