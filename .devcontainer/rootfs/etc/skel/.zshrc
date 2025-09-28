# Kalilix Zsh Configuration

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Mise configuration
export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
if [ -f "$HOME/.local/bin/mise" ]; then
    eval "$($HOME/.local/bin/mise activate zsh)"
fi

# Nix configuration
export PATH="/nix/var/nix/profiles/default/bin:$PATH"
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Kalilix environment
export KALILIX_ROOT="/workspace"
export KALILIX_SHELL="${KALILIX_SHELL:-base}"

# Aliases
alias kx='mise run kx'
alias kx-info='mise run info'
alias kx-shell='mise run shell'
alias kx-status='mise run status'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Welcome message
if [ -z "$KALILIX_SILENT" ]; then
    if [ -f /workspace/.mise.toml ]; then
        echo "🚀 Kalilix Development Environment"
        echo "   Run 'mise run help' for available commands"
        echo ""
    fi
fi