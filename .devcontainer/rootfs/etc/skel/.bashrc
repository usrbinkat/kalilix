# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History configuration
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=10000
HISTFILESIZE=20000

# Window size check
shopt -s checkwinsize

# Prompt
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

# Terminal title
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac

# Color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Load bash aliases if exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Bash completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# ============================================================================
# Kalilix Development Environment Configuration
# ============================================================================

# Mise configuration - automatically activates tools and environments
export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
if [ -f "$HOME/.local/bin/mise" ]; then
    eval "$($HOME/.local/bin/mise activate bash)"
fi

# NPM global packages configuration (for Claude Code)
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"

# Nix configuration
export PATH="/nix/var/nix/profiles/default/bin:$PATH"
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Nix wrappers for container mode (--init none requires root)
# These allow the debian user to run nix commands transparently via sudo
# Using sudo -E to preserve environment including working directory
alias nix='sudo -E nix'
alias nix-shell='sudo -E nix-shell'
alias nix-build='sudo -E nix-build'
alias nix-env='sudo -E nix-env'
alias nix-store='sudo -E nix-store'
alias nix-collect-garbage='sudo -E nix-collect-garbage'

# Kalilix environment
export KALILIX_ROOT="/workspace"
export KALILIX_SHELL="${KALILIX_SHELL:-base}"

# Kalilix aliases
alias kx='mise run kx'
alias kx-info='mise run info'
alias kx-shell='mise run shell'
alias kx-status='mise run status'

# Welcome message (only in interactive shells)
if [ -n "$PS1" ] && [ -z "$KALILIX_SILENT" ]; then
    if [ -f /workspace/.mise.toml ]; then
        echo "🚀 Kalilix Development Environment"
        echo "   Run 'mise run help' for available commands"
        echo ""
    fi
fi