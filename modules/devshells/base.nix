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
in
pkgs.mkShell {
  name = "kalilix-base";

  buildInputs = with pkgs; [
    # npm packages from node2nix
    npmPkgs."@anthropic-ai/claude-code"
    npmPkgs."server-perplexity-ask"
    # Use the wrapped version of pulumi-mcp-server that handles cache directories
    pulumiMcpServerWrapped

    # Locale support
    glibcLocales

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
    tmux
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
  ];

  shellHook = ''
    # Set up locale archive path for Nix environments
    # This provides the locale data within the Nix shell
    export LOCALE_ARCHIVE="${pkgs.glibcLocales}/lib/locale/locale-archive"

    # Fix locale settings - use C.UTF-8 which is always available
    # This prevents setlocale warnings in containers
    export LANG=C.UTF-8
    export LC_CTYPE=C.UTF-8
    export LC_COLLATE=C.UTF-8
    # Unset LC_ALL to avoid conflicts
    unset LC_ALL 2>/dev/null || true

    # Load .env if exists
    [ -f .env ] && source .env

    # Configure starship if available
    command -v starship &>/dev/null && eval "$(starship init bash)"

    # Activate mise for automatic environment management
    if command -v mise &>/dev/null; then
      eval "$(mise activate bash)"
    fi

    # Show banner
    echo "╔══════════════════════════════════════════════╗"
    echo "║     🚀 Kalilix Development Environment        ║"
    echo "║              Base Shell                       ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""
    echo "Platform: ''${KALILIX_PLATFORM:-container}"
    echo "Shell: ''${KALILIX_SHELL:-base}"
    echo ""
    echo "Available commands:"
    echo "  mise tasks    - Show all available tasks"
    echo "  mise run help - Show Kalilix help"
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

    # Locale settings - point to Nix's locale archive
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    LANG = "C.UTF-8";
    # Don't set LC_* variables in env, let shellHook handle them
  };
}
