# Kalilix Fish Shell Configuration

# Mise configuration
set -gx PATH $HOME/.local/share/mise/shims $HOME/.local/bin $PATH
if test -f $HOME/.local/bin/mise
    $HOME/.local/bin/mise activate fish | source
end

# Nix configuration
set -gx PATH /nix/var/nix/profiles/default/bin $PATH

# Kalilix environment
set -gx KALILIX_ROOT /workspace
set -gx KALILIX_SHELL (test -n "$KALILIX_SHELL"; and echo $KALILIX_SHELL; or echo "base")

# Aliases
alias kx='mise run kx'
alias kx-info='mise run info'
alias kx-shell='mise run shell'
alias kx-status='mise run status'

# Welcome message
if test -z "$KALILIX_SILENT"
    if test -f /workspace/.mise.toml
        echo "🚀 Kalilix Development Environment"
        echo "   Run 'mise run help' for available commands"
        echo ""
    end
end