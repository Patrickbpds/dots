#!/bin/bash

# Configuration
ALIAS_SHELL_FILE="$HOME/.config/shell/aliases.sh"

# Function to define aliases based on shell
define_aliases() {
  local current_shell="${SHELL##*/}" # Get the base name of the shell

  if [ ! -f "$ALIAS_SHELL_FILE" ]; then
    echo "Error: Alias shell file not found at $ALIAS_SHELL_FILE" >&2
    return 1
  fi

  case "$current_shell" in
  "bash" | "zsh")
    # For Bash and Zsh, simply source the aliases.sh file.
    # The aliases defined there will become active in the current shell.
    echo "# --- Sourcing aliases from aliases.sh ---"
    . "$ALIAS_SHELL_FILE"
    echo "# --- End sourcing aliases ---"
    ;;

  "fish")
    # Fish does not understand bash's 'alias' command directly.
    # You need to define Fish-specific 'abbr' or 'functions'.
    # For this simple .sh file approach, Fish needs manual parsing or a separate file.
    # The most straightforward way without 'jq' is for Fish to parse it itself
    # or for you to manually convert from aliases.sh to config.fish.
    # Since we don't want external tools, and this is a .sh file,
    # Fish can't directly source it to get bash aliases.
    echo "# --- IMPORTANT: For Fish shell, aliases must be converted manually from aliases.sh"
    echo "# If you want to use the aliases from $ALIAS_SHELL_FILE in Fish, you will need to"
    echo "# parse it and define 'abbr' or 'functions' in your ~/.config/fish/config.fish."
    echo "# A simple way is to read the file and define them:"
    echo "# Example in config.fish:"
    echo "#    cat $ALIAS_SHELL_FILE | while read -l line"
    echo "#        string match -r '^alias (.+?)=' \$line >/dev/null; and set alias_name \$match[1]"
    echo "#        string match -r '=(.*)' \$line >/dev/null; and set alias_cmd \$match[1]"
    echo "#        if test -n \"\$alias_name\"; and test -n \"\$alias_cmd\""
    echo "#            abbr --add \$alias_name \$alias_cmd"
    echo "#        end"
    echo "#    end"
    echo "# --- End Fish shell instructions ---"
    ;;

  "nu") # Nushell
    # Nushell cannot directly source a bash script or its alias commands.
    # It requires its own native definition using 'def' or 'alias'.
    # This approach (plain .sh file) is not portable to Nushell directly.
    # You would need to define aliases in Nushell's config.nu using its syntax.
    echo "# --- IMPORTANT: For Nushell, aliases from aliases.sh are NOT directly compatible."
    echo "# You need to define Nushell 'def' or 'alias' commands directly in your config.nu."
    echo "# Example in config.nu:"
    echo "#    def ll [] { ls -alF }"
    echo "#    def gco [] { git checkout }"
    echo "# You could write a Nushell script to parse $ALIAS_SHELL_FILE if needed."
    echo "# --- End Nushell instructions ---"
    ;;

  *)
    echo "Warning: Shell '$current_shell' is not explicitly supported for direct alias sourcing by this script." >&2
    ;;
  esac
}

# Only run if sourced in a Bash/Zsh context
# This script is primarily useful for Bash/Zsh when using the direct .sh alias file.
# For Fish/Nushell, it acts as an informative guide rather than a functional alias loader
# because their alias syntaxes are fundamentally different.
if [ -n "$ZSH_VERSION" ] || [ -n "$BASH_VERSION" ]; then
  define_aliases
else
  # If executed directly or sourced in non-Bash/Zsh, just give instructions/warnings
  echo "This script is designed to be sourced by Bash or Zsh."
  echo "It attempts to source '$ALIAS_SHELL_FILE'."
  echo "For Fish or Nushell, direct sourcing of this type of alias file is not supported."
  echo "Please check the comments in the script for instructions for other shells."
  define_aliases # Still run define_aliases to print the shell-specific warnings/guidance.
fi
