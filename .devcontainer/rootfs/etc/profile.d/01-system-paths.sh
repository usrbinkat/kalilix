#!/bin/sh
# Single source of truth for system PATH configuration
# This file is sourced by all shells to ensure consistent PATH across contexts

# Base system paths
BASE_PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Nix paths
NIX_PATH="/nix/var/nix/profiles/default/bin"

# Mise paths
MISE_SHIMS="$HOME/.local/share/mise/shims"
MISE_BIN="$HOME/.local/bin"

# Construct final PATH - Nix and mise take precedence
export PATH="${NIX_PATH}:${MISE_SHIMS}:${MISE_BIN}:${BASE_PATH}"

# Additional user paths
if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi

# NPM global packages (for tools like Claude Code CLI)
if [ -d "$HOME/.npm-global/bin" ]; then
    export PATH="$HOME/.npm-global/bin:$PATH"
fi