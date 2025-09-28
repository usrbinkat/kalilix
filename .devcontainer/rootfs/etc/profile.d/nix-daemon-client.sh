#!/bin/sh
# Set NIX_REMOTE only for user sessions, never for system services
# This prevents the nix-daemon from trying to connect to itself (fork bomb)

# Only set NIX_REMOTE for:
# - Non-root users
# - Root users that came through sudo (have SUDO_USER set)
# - Interactive sessions
if [ "$UID" != "0" ] || [ -n "$SUDO_USER" ] || [ -n "$PS1" ]; then
    export NIX_REMOTE=daemon
fi

# Nix paths are managed by 01-system-paths.sh to avoid duplication