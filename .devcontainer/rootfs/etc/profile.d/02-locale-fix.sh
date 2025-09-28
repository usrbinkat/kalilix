#!/bin/sh
# Fix locale issues in container environments
# LC_ALL overrides all other locale settings and can cause issues with Nix

# Unset LC_ALL if it's set - it's too restrictive
unset LC_ALL 2>/dev/null || true

# Ensure LANG is set to a reasonable default
# Use C.UTF-8 as it's always available in containers
if [ -z "$LANG" ]; then
    export LANG=C.UTF-8
fi

# Only export LC_* variables if they're not already set
[ -z "$LC_CTYPE" ] && export LC_CTYPE="$LANG"
[ -z "$LC_COLLATE" ] && export LC_COLLATE="$LANG"