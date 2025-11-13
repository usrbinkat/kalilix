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
    # Use rlwrap to provide readline features (arrow keys, history) in the libvterm PTY
    exec ${pkgs.rlwrap}/bin/rlwrap ${pkgs.bash}/bin/bash --rcfile ${nvimTerminalBashrc}
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
    # Bash Completion
    # ============================================
    # Source bash-completion if available
    if [ -f ${pkgs.bash-completion}/share/bash-completion/bash_completion ]; then
      source ${pkgs.bash-completion}/share/bash-completion/bash_completion
    fi

    # ============================================
    # Starship Prompt
    # ============================================
    # Initialize starship prompt
    if command -v starship &>/dev/null; then
      eval "$(starship init bash)"
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
  inherit nvimTerminalBashrc nvimTerminalBashWrapper;
}
