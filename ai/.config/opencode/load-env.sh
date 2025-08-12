#!/bin/bash
# Load environment variables for opencode
# This script sources the .env file and exports the variables

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load the .env file if it exists
if [ -f "$SCRIPT_DIR/.env" ]; then
    export $(grep -v '^#' "$SCRIPT_DIR/.env" | xargs)
    echo "Environment variables loaded from .env"
else
    echo "Warning: .env file not found at $SCRIPT_DIR/.env"
fi

# Run opencode with all arguments passed to this script
exec opencode "$@"