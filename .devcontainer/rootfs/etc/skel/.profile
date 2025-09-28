# ~/.profile: executed by the command interpreter for login shells.

# the default umask is set in /etc/profile
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# User's private bin directories
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Mise shims
if [ -d "$HOME/.local/share/mise/shims" ] ; then
    PATH="$HOME/.local/share/mise/shims:$PATH"
fi

# Nix
if [ -d "/nix/var/nix/profiles/default/bin" ] ; then
    PATH="/nix/var/nix/profiles/default/bin:$PATH"
fi

export PATH