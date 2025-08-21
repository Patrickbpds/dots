#!/usr/bin/env zsh

export XDG_CONFIG_HOME="$HOME/.config"
export ZSH_CONFIG_DIR="$XDG_CONFIG_HOME/zsh"

# Load Helpers
[[ -f "$ZSH_CONFIG_DIR/helpers.zsh" ]] && source "$ZSH_CONFIG_DIR/helpers.zsh"

# Load Package Manager (zinit)
[[ -f "$ZSH_CONFIG_DIR/zinit.zsh" ]] && source "$ZSH_CONFIG_DIR/zinit.zsh"

# Source all config files
if [ -d "$ZSH_CONFIG_DIR/config" ] && [ "$(ls -A "$ZSH_CONFIG_DIR/config")" ]; then
  for file in "$ZSH_CONFIG_DIR/config/"*; do
    source "$file"
  done
fi

# Load All work private files
if [ -d "$ZSH_CONFIG_DIR/work" ] && [ "$(ls -A "$ZSH_CONFIG_DIR/work")" ]; then
  for file in "$ZSH_CONFIG_DIR/work/"*; do
    source "$file"
  done
fi

# Load All Programs from /programs
if [ -d "$ZSH_CONFIG_DIR/programs" ] && [ "$(ls -A "$ZSH_CONFIG_DIR/programs")" ]; then
  for file in "$ZSH_CONFIG_DIR/programs/"*; do
    source "$file"
  done
fi

# If software-development is not a directory, create it
if [ ! -d ~/software-development ]; then
    mkdir -p ~/software-development/work
fi

# Settings

# Vim Keybindings
bindkey -v
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

export KEYTIMEOUT=1

# History
HISTSIZE=1000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Sources
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
