{ pkgs, system, inputs, lib }:

let
  # Import base configuration
  base = import ./base.nix { inherit pkgs lib inputs; };

  # Import neovim configuration
  neovimModule = import ./neovim.nix { inherit pkgs lib inputs; };

  # Import security tools
  securityTools = import ../packages/security-tools/default.nix { inherit pkgs lib; };

  # Helper to extend base shell
  extendShell = name: config:
    base.overrideAttrs (old: {
      name = "kalilix-${name}";
      buildInputs = old.buildInputs ++ config.packages;
      shellHook = old.shellHook + "\n" + config.shellHook;
      # mkShell doesn't expose env via overrideAttrs, so we set it directly
      env = (old.env or { }) // (config.env or { }) // { KALILIX_SHELL = name; };
    });

in
{
  # Default shell is base
  default = base;

  # Python development
  python = extendShell "python" {
    packages = with pkgs; [
      (unstable.python312.withPackages (ps: [
        ps.pip
        ps.ipython
        ps.pytest
        ps.black
        ps.mypy
        # MCP packages
        ps.mcp # Official Python SDK for Model Context Protocol
        ps.fastmcp # Fast, Pythonic way to build MCP servers
        ps.mcpadapt # MCP servers tool
        ps.django-mcp-server # Django MCP Server
        ps.fastapi-mcp # FastAPI MCP integration
      ]))
      ruff
      uv
    ];

    shellHook = ''
      echo "🐍 Python 3.12 Development Environment"

      # Create venv if it doesn't exist
      if [ ! -d .venv ]; then
        echo "Creating virtual environment..."
        uv venv
      fi

      # Always activate venv
      source .venv/bin/activate

      # Install MCP servers if not already installed
      if ! command -v mcp-server-git &>/dev/null; then
        echo "Installing MCP servers..."
        uv pip install -q mcp-server-git mcp-server-fetch 2>/dev/null || true
      fi

      # Install from requirements/pyproject if exists
      [ -f pyproject.toml ] && uv sync 2>/dev/null || true
      [ -f requirements.txt ] && uv pip install -q -r requirements.txt 2>/dev/null || true
    '';

    env = {
      UV_SYSTEM_PYTHON = "1";
      PYTHONDONTWRITEBYTECODE = "1";
    };
  };

  # Go development
  go = extendShell "go" {
    packages = with pkgs; [
      go_1_23
      gopls
      golangci-lint
      delve
      go-tools
    ];

    shellHook = ''
      echo "🐹 Go 1.23 Development Environment"
      export GOPATH="$PWD/.go"
      export PATH="$GOPATH/bin:$PATH"
      [ -f go.mod ] && go mod download 2>/dev/null || true
    '';

    env = {
      GO111MODULE = "on";
      CGO_ENABLED = "1";
    };
  };

  # Rust development
  rust = extendShell "rust" {
    packages = with pkgs; [
      (rust-bin.stable.latest.default.override {
        extensions = [ "rust-src" "rust-analyzer" ];
      })
      cargo-edit
      cargo-watch
      cargo-audit
      sccache
    ];

    shellHook = ''
      echo "🦀 Rust Stable Development Environment"
      export CARGO_HOME="$PWD/.cargo"
      export PATH="$CARGO_HOME/bin:$PATH"
    '';

    env = {
      RUST_BACKTRACE = "1";
      RUSTC_WRAPPER = "sccache";
    };
  };

  # Node.js development
  node = extendShell "node" {
    packages = with pkgs; [
      nodejs_22
      nodePackages.pnpm
      nodePackages.typescript
      nodePackages.typescript-language-server
      yarn
    ];

    shellHook = ''
      echo "🟢 Node.js 22 Development Environment"
      [ -f package.json ] && pnpm install 2>/dev/null || true
    '';

    env = {
      NODE_ENV = "development";
    };
  };

  # DevOps/Cloud tools
  devops = extendShell "devops" {
    packages = with pkgs; [
      # Container tools
      docker-client
      docker-compose
      dive

      # Kubernetes
      kubectl
      kubernetes-helm
      k9s

      # IaC
      pulumi-bin
      ansible

      # Cloud CLIs
      awscli2
      azure-cli
      google-cloud-sdk

      # Security
      trivy
      cosign

      # MCP servers (from unstable)
      unstable.github-mcp-server # GitHub's official MCP Server
      unstable.gitea-mcp-server # Gitea MCP Server
      unstable.mcp-k8s-go # MCP server for Kubernetes
      unstable.mcp-grafana # MCP server for Grafana
    ];

    shellHook = ''
      echo "⚙️  DevOps & Cloud Tools Environment"
      command -v kubectl &>/dev/null && echo "K8s context: $(kubectl config current-context 2>/dev/null || echo 'none')"
    '';

    env = {
      PULUMI_SKIP_UPDATE_CHECK = "true";
    };
  };

  # Kali Security Testing Environment
  kali = extendShell "kali" {
    packages = securityTools.nixpkgsSecurityTools ++ (with pkgs; [
      # Additional CLI security tools
      masscan # Mass IP port scanner
      gobuster # Directory/file and DNS brute forcer
      sqlmap # SQL injection testing tool
      dirb # Web content scanner
      nikto # Web server scanner
      theharvester # Information gathering tool
      whatweb # Web technology identifier
      wpscan # WordPress security scanner
      enum4linux # SMB/CIFS enumeration tool (classic)
      enum4linux-ng # SMB/CIFS enumeration tool (modern Python rewrite)
      dnsenum # DNS enumeration tool
      john # John the Ripper password cracker
      thc-hydra # Network authentication cracker
      metasploit # Exploitation framework
      volatility2-bin # Memory forensics framework (classic)
      volatility3 # Memory forensics framework (modern)
      radare2 # Reverse engineering framework
    ]);

    shellHook = ''
      echo "🔒 Kali Security Testing Environment"
      echo "   Web Fuzzing: ffuf"
      echo "   Network Scanning: nmap, masscan"
      echo "   Web Security: burpsuite, sqlmap, gobuster, dirb, nikto"
      echo "   SMB/CIFS Enumeration: enum4linux, enum4linux-ng"
      echo "   DNS Enumeration: dnsenum"
      echo "   Wireless: aircrack-ng"
      echo "   Password: hashcat, john, hydra"
      echo "   Exploitation: metasploit"
      echo "   Forensics: volatility2, volatility3"
      echo "   Reverse Engineering: radare2"
      echo "   Network Analysis: wireshark, tcpdump"
      echo ""

      # Create Kali-style directory structure
      export KALI_CONFIG_DIR="$HOME/.config/kali"
      export WORDLISTS="$HOME/.local/share/wordlists"
      export KALI_TOOLS_DIR="$HOME/.local/share/kali-tools"

      mkdir -p "$KALI_CONFIG_DIR" "$WORDLISTS" "$KALI_TOOLS_DIR"

      echo "   Config: $KALI_CONFIG_DIR"
      echo "   Wordlists: $WORDLISTS"
      echo "   Tools: $KALI_TOOLS_DIR"
      echo ""
      echo "🎯 Ready for security testing (CLI tools only)"
    '';

    env = {
      # Kali-specific environment variables
      KALI_ROOT = "$HOME/.local/share/kali";
      BURP_USER_CONFIG_FILE = "$HOME/.config/kali/burp.config";
      # Disable some GUI warnings for CLI usage
      NO_AT_BRIDGE = "1";
    };
  };

  # Full polyglot environment
  full = extendShell "full" {
    packages = with pkgs; [
      # Combine all language tools
      (unstable.python312.withPackages (ps: [
        ps.pip
        ps.ipython
        ps.pytest
        ps.black
        ps.mypy
        # MCP packages
        ps.mcp
        ps.fastmcp
        ps.mcpadapt
        ps.django-mcp-server
        ps.fastapi-mcp
      ]))
      go_1_23
      nodejs_22
      (rust-bin.stable.latest.default.override {
        extensions = [ "rust-src" "rust-analyzer" ];
      })
      ruff
      uv

      # Additional tools
      docker-client
      kubectl
      pulumi-bin

      # MCP servers
      unstable.github-mcp-server
      unstable.mcp-k8s-go
    ];

    shellHook = ''
      echo "🚀 Full Polyglot Development Environment"
      echo "   All language toolchains loaded"

      # Setup Python venv with MCP servers
      if [ ! -d .venv ]; then
        echo "Creating Python virtual environment..."
        uv venv
      fi
      source .venv/bin/activate

      # Install MCP servers if not already installed
      if ! command -v mcp-server-git &>/dev/null; then
        echo "Installing MCP servers..."
        uv pip install -q mcp-server-git mcp-server-fetch 2>/dev/null || true
      fi

      # Install from requirements/pyproject if exists
      [ -f pyproject.toml ] && uv sync 2>/dev/null || true
      [ -f requirements.txt ] && uv pip install -q -r requirements.txt 2>/dev/null || true
    '';

    env = {
      KALILIX_FULL = "true";
    };
  };

  # Neovim development environment
  neovim = extendShell "neovim" {
    packages = neovimModule.neovim-packages ++ (with pkgs; [
      # Required dependencies for telescope
      ripgrep # For live_grep
      fd # For find_files

      # Formatters (Phase 2)
      nixpkgs-fmt # Nix
      black # Python
      isort # Python imports
      rustfmt # Rust (usually from rust toolchain)
      go # Go (includes gofmt and goimports)
      nodePackages.prettier # JS/TS/Markdown/YAML/JSON
      shfmt # Bash/Shell

      # Phase 3 dependencies
      lazygit # Git TUI for toggleterm integration
    ]);

    shellHook = ''
      echo "📝 Neovim Development Environment"
      echo "   Launch: nvim"
      echo "   Config: nixvim-managed (immutable)"
      echo "   LSP: Python, Go, Rust, Node, Nix, Bash, YAML, JSON, Markdown, Lua"
      echo "   Features: Completion, Snippets, Auto-format on save"
      echo "   Git: gitsigns, fugitive, diffview, lazygit"
      echo "   Tools: toggleterm, rest.nvim, markdown-preview, which-key"
      echo ""
      echo "   ClaudeCode MCP Integration:"
      echo "     <leader>cc - Start Claude Code server"
      echo "     <leader>cs - Show Claude Code status"
      echo "     <leader>cq - Stop Claude Code server"
      echo ""
    '';

    env = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
