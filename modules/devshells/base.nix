{ pkgs, lib, inputs }:

pkgs.mkShell {
  name = "kalilix-base";

  packages = with pkgs; [
    # Core tools
    git
    gh
    gnumake
    jq
    yq-go

    # Modern CLI replacements
    ripgrep  # grep
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
    # Load .env if exists
    [ -f .env ] && source .env

    # Configure starship if available
    command -v starship &>/dev/null && eval "$(starship init bash)"

    # Show banner
    echo "╔══════════════════════════════════════════════╗"
    echo "║     🚀 Kalilix Development Environment        ║"
    echo "║              Base Shell                       ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""
    echo "Platform: ${KALILIX_PLATFORM:-container}"
    echo "Shell: ${KALILIX_SHELL:-base}"
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
  };
}