{ pkgs, ... }:
let
  # ==============================================================================
  # SELF-CONTAINED FLAKE APPROACH
  # ==============================================================================
  # This approach creates a complete bashrc in the Nix store
  # Works on any platform without requiring host bashrc modifications
  # Includes starship if available, falls back to colored prompt
  terminalInitScriptContent = ''
    # Prevent mise infinite loop - don't activate mise in neovim terminals
    export __MISE_NVIM_TERMINAL=1

    # Try to initialize starship if available
    if command -v starship &>/dev/null; then
      eval "$(starship init bash)"
      # CRITICAL: Override to use raw ANSI codes (no \[\] readline markers)
      # This fixes rendering in Neovim's terminal (libvterm)
      export STARSHIP_SHELL="sh"
    else
      # Fallback: Simple colored prompt
      # Raw ANSI codes (no \[\] readline markers - libvterm doesn't support them)
      PS1='\033[01;32m\u@\h\033[00m:\033[01;34m\w\033[00m\$ '
    fi

    # Bash completion from Nix
    if [ -f ${pkgs.bash-completion}/share/bash-completion/bash_completion ]; then
      source ${pkgs.bash-completion}/share/bash-completion/bash_completion 2>/dev/null || true
    fi
  '';

  nvimTerminalBashrc = pkgs.writeTextFile {
    name = "nvim-terminal-bashrc";
    text = terminalInitScriptContent;
    executable = false;
  };

  nvimTerminalBashWrapper = pkgs.writeShellScript "nvim-terminal-bash" ''
    # Set consistent INPUTRC for nested shells
    export INPUTRC="${bashInputrc}"
    # Use rlwrap to provide readline features (arrow keys, history) in the libvterm PTY
    exec ${pkgs.rlwrap}/bin/rlwrap ${pkgs.bash}/bin/bash --rcfile ${nvimTerminalBashrc}
  '';

  # Inputrc for consistent readline behavior across all bash instances
  bashInputrc = pkgs.writeText "kalilix-bash-inputrc" ''
    # Enable proper key bindings
    set enable-keypad on
    set input-meta on
    set output-meta on
    set convert-meta off

    # Arrow keys for history navigation
    "\e[A": previous-history
    "\e[B": next-history
    "\e[C": forward-char
    "\e[D": backward-char

    # Home/End keys
    "\e[H": beginning-of-line
    "\e[F": end-of-line

    # Delete key
    "\e[3~": delete-char

    # Completion settings
    set completion-ignore-case on
    set show-all-if-ambiguous on
    set colored-stats on
  '';

in
{
  # Shared bash configuration for both nix shells and neovim terminals
  # This ensures consistent behavior across all environments

  # Bash initialization script (for shellHook in nix shells)
  shellInitScript = ''
    # ============================================
    # Locale Configuration
    # ============================================
    ${pkgs.lib.optionalString pkgs.stdenv.isLinux ''
      export LOCALE_ARCHIVE="${pkgs.glibcLocales}/lib/locale/locale-archive"
    ''}
    export LANG=C.UTF-8
    export LC_CTYPE=C.UTF-8
    export LC_COLLATE=C.UTF-8
    unset LC_ALL 2>/dev/null || true

    # ============================================
    # Readline Configuration
    # ============================================
    # Set a proper INPUTRC to avoid conflicts in nested shells
    export INPUTRC="${bashInputrc}"

    # ============================================
    # Bash Completion
    # ============================================
    # Only load bash-completion if we have proper bash with progcomp support
    # Check if running in bash and if programmable completion is available
    if [ -n "$BASH_VERSION" ]; then
      # Check if programmable completion is available
      if shopt -q progcomp 2>/dev/null; then
        # Source bash-completion if available (guard against multiple sourcing)
        if [ -z "$__BASH_COMPLETION_LOADED" ] && [ -f ${pkgs.bash-completion}/share/bash-completion/bash_completion ]; then
          source ${pkgs.bash-completion}/share/bash-completion/bash_completion 2>/dev/null || true
          export __BASH_COMPLETION_LOADED=1
        fi
      fi
    fi

    # ============================================
    # Starship Prompt
    # ============================================
    # Initialize starship prompt only if we have a proper terminal
    # and we're not in a nested shell that might have issues
    if command -v starship &>/dev/null && [ -t 0 ] && [ -z "$STARSHIP_SHELL" ]; then
      eval "$(starship init bash)"
    elif [ -t 0 ]; then
      # Fallback to simple prompt if starship isn't available or suitable
      # Use plain format without readline escape sequences if they're not supported
      if [ -n "$BASH_VERSION" ] && [[ "$TERM" != "dumb" ]]; then
        PS1='\u@\h:\w\$ '
      else
        PS1='$ '
      fi
    fi

    # ============================================
    # Environment Detection
    # ============================================
    # Set NVIM_TERMINAL if we're in a neovim terminal
    # (This variable is set by toggleterm in neovim.nix)
  '';

  # Packages required for the shared bash environment
  bashPackages = with pkgs; [
    bash-completion
    starship
  ];

  # Export the Nix store path to the terminal bashrc file and wrapper script
  # These are used by neovim.nix for toggleterm configuration
  inherit nvimTerminalBashrc nvimTerminalBashWrapper bashInputrc;
}
