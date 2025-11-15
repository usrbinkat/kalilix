{ pkgs, lib, inputs }:

let
  # Import npm packages from node2nix
  npmPkgs = import ../packages/npm {
    inherit pkgs;
    inherit (pkgs.stdenv.hostPlatform) system;
    nodejs = pkgs.nodejs_22;  # Override to use Node.js 22 LTS
  };

  # Import the wrapped pulumi-mcp-server that handles cache directories properly
  pulumiMcpServerWrapped = import ../packages/npm/pulumi-mcp-wrapper.nix { inherit pkgs; };

  # Shared bash configuration
  bashConfig = import ./bash-config.nix { inherit pkgs; };

  # Tmux configuration module
  tmuxModule = import ../programs/tmux/config.nix { inherit pkgs lib; };

  # Neovim configuration module
  neovimModule = import ./neovim.nix { inherit pkgs lib inputs; };

  # Hyfetch configuration module
  hyfetchModule = import ../programs/hyfetch/config.nix { inherit pkgs lib; };
in
pkgs.mkShell {
  name = "kalilix-base";

  buildInputs = with pkgs; [
    # npm packages from node2nix
    npmPkgs."@anthropic-ai/claude-code"
    npmPkgs."server-perplexity-ask"
    # Use the wrapped version of pulumi-mcp-server that handles cache directories
    pulumiMcpServerWrapped

    # Locale support (Linux only - macOS uses system locales)
  ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
    pkgs.glibcLocales
  ] ++ neovimModule.neovim-packages ++ (with pkgs; [
    # Core tools
    git
    gh
    gnumake
    jq
    yq-go

    # Modern CLI replacements
    ripgrep  # grep (also required by Claude Code)
    fd       # find
    bat      # cat
    eza      # ls
    bottom   # top
    dust     # du
    procs    # ps

    # Terminal tools
    direnv
    starship
    atuin
    fzf

    # Nix tools
    nil
    nixpkgs-fmt
    nix-tree
    nix-diff
    cachix
    nodePackages.node2nix

    # System tools
    htop
    ncdu
    tldr
    tree
    wget
    curl
    unzip
    zip
  ]) ++ tmuxModule.packages ++ hyfetchModule.packages ++ bashConfig.bashPackages;

  shellHook = ''
    ${bashConfig.shellInitScript}

    # Load .env if exists
    [ -f .env ] && source .env

    # Note: mise is already activated in shell profiles (.bashrc/.zshrc)
    # Don't re-activate here to avoid infinite loop with hooks

    # Tmux module shell hook
    ${tmuxModule.shellHook}

    # Hyfetch module shell hook
    ${hyfetchModule.shellHook}

    # Show banner
    echo "╔══════════════════════════════════════════════╗"
    echo "║     🚀 Kalilix Development Environment        ║"
    echo "║              Base Shell                       ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""
    echo "Platform: ''${KALILIX_PLATFORM:-container}"
    echo "Shell: ''${KALILIX_SHELL:-base}"
    echo ""
    echo "Available tools:"
    echo "  nvim                    - Neovim with full LSP support"
    echo "  tmux                    - Tmux with Catppuccin theme"
    echo "  tmuxp load .tmuxp.yaml  - Start project tmux session"
    echo ""
    echo "Available commands:"
    echo "  mise tasks              - Show all available tasks"
    echo "  mise run help           - Show Kalilix help"
    echo ""
    echo "To enter a specific development shell:"
    echo "  nix develop .#python  - Python environment"
    echo "  nix develop .#go      - Go environment"
    echo "  nix develop .#rust    - Rust environment"
    echo "  nix develop .#node    - Node.js environment"
    echo "  nix develop .#devops  - DevOps tools"
    echo "  nix develop .#full    - All languages"
  '';

  env = {
    KALILIX_SHELL = "base";
    EDITOR = "vim";
    PAGER = "bat";
    LANG = "C.UTF-8";
    # Note: LOCALE_ARCHIVE is set in shellHook (Linux-only)
    # Don't set LC_* variables in env, let shellHook handle them
  };
}
