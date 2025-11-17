# Kalilix

**Nix-powered polyglot development environment with cross-platform reproducibility and security tooling**

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Nix](https://img.shields.io/badge/Nix-5277C3?logo=nixos&logoColor=white)](https://nixos.org)
[![Built with Mise](https://img.shields.io/badge/Built%20with-Mise-4A9EFF)](https://mise.jdx.dev)

---

## What is Kalilix?

Kalilix provides **deterministic, reproducible development environments** without virtualization overhead. Built on Nix flakes, it delivers 9 specialized shells (Python, Go, Rust, Node.js, DevOps, Security, Neovim, and more) running natively across macOS, Linux, WSL, and containers.

**Key Benefits:**
- 🎯 **Zero Setup Friction** - 4 commands from bare metal to full environment
- 🔄 **Truly Reproducible** - Identical environment on any platform
- 🚀 **No VMs Required** - Native performance, no overhead
- 🛡️ **Security First** - 32 penetration testing tools (Kali-inspired)
- 🌐 **Cross-Platform** - macOS, Linux, WSL, containers, NixOS
- 💼 **Production Grade** - Used for real-world development workflows

---

## Quick Start

### Prerequisites

- **Lix** (Nix variant) - [installation guide](https://lix.systems/install/)
- **Git** (any modern version)

### Installation (4 Commands)

```bash
# 1. Install Lix with Kalilix-optimized configuration
# See https://lix.systems/install/ for more installation options
curl -sSf -L https://install.lix.systems/lix | sh -s -- install \
  --no-confirm \
  --extra-conf "experimental-features = nix-command flakes" \
  --extra-conf "allow-unfree = true" \
  --extra-conf "warn-dirty = false"

# 2. Add Nix to your shell (bash example - adjust for zsh/fish)
cat <<'EOF' | tee -a ~/.bashrc
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
EOF

# 3. Reload shell configuration
source ~/.bashrc

# 4. Enter development environment (no clone required!)
nix develop github:usrbinkat/kalilix
```

**That's it!** You now have a complete polyglot development environment with Python 3.12, Go 1.23, Rust, Node.js 22, DevOps tools, and security utilities.

### Optional: Registry Shortcut

For regular use, add Kalilix to your flake registry for shorter commands:

```bash
# Add to registry
nix registry add kalilix github:usrbinkat/kalilix

# Now use short commands
nix develop kalilix#python
nix develop kalilix#go
nix develop kalilix#rust
nix develop kalilix#devops
nix develop kalilix#kali     # Security tools
nix develop kalilix#neovim   # Full IDE
```

---

## Available Shells

Kalilix provides **9 specialized environments**, each extending a common base:

| Shell | Command | Description |
|-------|---------|-------------|
| **base** | `nix develop kalilix` | Modern CLI tools (26 packages) |
| **python** | `nix develop kalilix#python` | Python 3.12 + uv, ruff, mypy, pytest |
| **go** | `nix develop kalilix#go` | Go 1.23 + gopls, delve, golangci-lint |
| **rust** | `nix develop kalilix#rust` | Rust stable + rust-analyzer, cargo-watch |
| **node** | `nix develop kalilix#node` | Node.js 22 + pnpm, TypeScript, yarn |
| **devops** | `nix develop kalilix#devops` | kubectl, helm, k9s, pulumi, cloud CLIs |
| **kali** | `nix develop kalilix#kali` | 32 security tools (nmap, metasploit, etc.) |
| **neovim** | `nix develop kalilix#neovim` | Full IDE with 10 LSPs, 73ms startup |
| **full** | `nix develop kalilix#full` | All toolchains combined |

### Shell Features

**All shells include:**
- 🔧 Modern CLI: ripgrep, fd, bat, eza, bottom, dust, procs
- 🖥️ Terminal: tmux (Ctrl-a), starship, atuin, fzf, direnv
- 🛠️ Nix Tools: nil, nixpkgs-fmt, cachix, node2nix
- 📦 Version Control: git, gh (GitHub CLI)

**Language shells add:**
- 📦 Package managers and toolchains
- 🔍 LSP servers and debuggers
- ✅ Testing frameworks
- 📝 Linters and formatters
- 🔄 Auto-setup (venv creation, dependency sync)

---

## Common Tasks

### Exploring Available Shells

```bash
# List all available shells
nix flake show github:usrbinkat/kalilix

# Try different shells
nix develop kalilix#python   # Python development
nix develop kalilix#go       # Go development
nix develop kalilix#kali     # Security testing
nix develop kalilix#neovim   # Full IDE experience
```

### Using Specific Versions

```bash
# Specific branch
nix develop github:usrbinkat/kalilix/main#python

# Specific commit (fully reproducible)
nix develop github:usrbinkat/kalilix/30ed44a#go

# Using registry shortcut
nix develop kalilix/30ed44a#rust
```

### Exiting Shells

```bash
# Simply exit the shell
exit

# Or Ctrl+D
```

---

## Development Shells Deep Dive

<details>
<summary><b>🐍 Python Shell</b></summary>

**Python 3.12** with modern tooling and automatic environment setup.

```bash
nix develop kalilix#python
```

**Included Tools:**
- **Package Management**: `uv` (fast pip replacement), `pip`, `setuptools`
- **Linting/Formatting**: `ruff` (replaces black, flake8, isort), `mypy`
- **Testing**: `pytest`, `pytest-cov`, `tox`
- **Additional**: ipython, black

**Auto-Setup:**
- Creates `.venv` using `uv` if `pyproject.toml` or `requirements.txt` exists
- Auto-installs dependencies
- Activates virtual environment
- Sets `PYTHONPATH` for development

**Example Workflow:**
```bash
# Enter shell
nix develop kalilix#python

# .venv is automatically created and activated
python --version  # 3.12.x
uv pip install requests

# Run tests
pytest tests/

# Format code
ruff format .
ruff check --fix .
```

</details>

<details>
<summary><b>🔷 Go Shell</b></summary>

**Go 1.23** with complete development toolchain.

```bash
nix develop kalilix#go
```

**Included Tools:**
- **Toolchain**: `go` 1.23, `gopls` (LSP), `delve` (debugger)
- **Quality**: `golangci-lint`, `staticcheck`, `gotest`
- **Build**: `goreleaser`, `air` (hot reload)

**Auto-Setup:**
- Project-local `GOPATH` (`.go/`)
- Auto-downloads dependencies from `go.mod`
- Sets `GOBIN`, `GOCACHE`

**Example Workflow:**
```bash
# Enter shell
nix develop kalilix#go

# Initialize new project
go mod init example.com/myproject

# Run with hot reload
air

# Lint and test
golangci-lint run
go test ./...
```

</details>

<details>
<summary><b>🦀 Rust Shell</b></summary>

**Rust stable** with performance-focused tooling.

```bash
nix develop kalilix#rust
```

**Included Tools:**
- **Toolchain**: `rustc`, `cargo`, `rust-analyzer` (LSP)
- **Development**: `cargo-watch`, `cargo-edit`, `cargo-audit`
- **Performance**: `sccache` (compilation cache)
- **Testing**: `cargo-nextest`

**Auto-Setup:**
- Compilation caching via `sccache`
- Project-local `CARGO_HOME`
- Optimized build settings

**Example Workflow:**
```bash
# Enter shell
nix develop kalilix#rust

# Create new project
cargo new myproject
cd myproject

# Watch mode with auto-rebuild
cargo watch -x run

# Security audit
cargo audit
```

</details>

<details>
<summary><b>📦 Node.js Shell</b></summary>

**Node.js 22 LTS** with modern JavaScript/TypeScript tooling.

```bash
nix develop kalilix#node
```

**Included Tools:**
- **Runtime**: Node.js 22 LTS
- **Package Managers**: `pnpm` (preferred), `yarn`, `npm`
- **TypeScript**: `typescript`, `ts-node`
- **Build**: `vite`, `webpack`, `esbuild`

**Auto-Setup:**
- Runs `pnpm install` if `package.json` exists
- Sets up `NODE_PATH`

**Example Workflow:**
```bash
# Enter shell
nix develop kalilix#node

# Create new project
pnpm init

# Add dependencies
pnpm add express

# Run TypeScript
ts-node script.ts
```

</details>

<details>
<summary><b>☸️ DevOps Shell</b></summary>

**18 packages** for cloud-native infrastructure and automation.

```bash
nix develop kalilix#devops
```

**Included Tools:**
- **Kubernetes**: `kubectl`, `helm`, `k9s` (TUI), `kustomize`
- **Infrastructure-as-Code**: `pulumi`, `ansible`
- **Cloud CLIs**: `awscli2`, `azure-cli`, `google-cloud-sdk`
- **Security**: `trivy` (vulnerability scanner), `cosign` (signing)
- **Containers**: `docker-client`, `docker-compose`, `dive`

**Example Workflow:**
```bash
# Enter shell
nix develop kalilix#devops

# Kubernetes operations
kubectl get pods --all-namespaces
helm list

# Cloud operations
aws s3 ls
gcloud projects list

# Security scanning
trivy image myimage:latest
```

</details>

<details>
<summary><b>🛡️ Kali Security Shell</b></summary>

**32 security tools** for penetration testing and security research.

```bash
nix develop kalilix#kali
```

**Tool Categories:**

**Web Application Testing (8 tools):**
- `ffuf`, `burpsuite`*, `sqlmap`, `gobuster`, `dirb`, `nikto`, `wpscan`*, `whatweb`

**Network Reconnaissance (3 tools):**
- `nmap`, `masscan`, `netcat`

**Credential Testing (4 tools):**
- `john`, `hashcat`, `thc-hydra`, `medusa`

**SMB Enumeration (2 tools):**
- `enum4linux`, `enum4linux-ng`

**DNS Enumeration (1 tool):**
- `dnsenum`

**Wireless Security (1 tool):**
- `aircrack-ng`

**Memory Forensics (2 tools):**
- `volatility2-bin`*, `volatility3`*

**Reverse Engineering (4 tools):**
- `radare2`, `binwalk`, `objdump`, `strings`

**Exploitation (1 tool):**
- `metasploit`

**Intelligence Gathering (3 tools):**
- `theharvester`, `recon-ng`, `whatweb`

**Protocol Analysis (1 tool):**
- `wireshark`

**Utilities (2 tools):**
- `curl`, `wget`, `socat`, `tcpdump`

\* *Linux-only tools (macOS: 28 tools, Linux: 32 tools)*

**Auto-Setup:**
- Creates Kali-style directory structure
- Configures environment variables
- Supports unfree packages (professional tools)

**Platform Support:**
- ✅ Linux: All 32 tools (CLI + GUI)
- ✅ macOS: 28 tools (excludes burpsuite, wpscan, volatility2-bin, volatility3)
- ✅ WSL2: All 32 tools
- ✅ Containers: All 32 tools

**Example Workflow:**
```bash
# Enter shell
nix develop kalilix#kali

# Network scan
nmap -sV -sC target.example.com

# Web fuzzing
ffuf -w wordlist.txt -u https://target.example.com/FUZZ

# Password cracking
john --wordlist=rockyou.txt hashes.txt

# Memory analysis (Linux only)
volatility3 -f memory.dump windows.pslist
```

**⚠️ Legal Notice:**
Use security tools only on systems you own or have explicit authorization to test. Unauthorized security testing is illegal.

</details>

<details>
<summary><b>✏️ Neovim Shell</b></summary>

**Highly-optimized Neovim** with 10 LSP servers, 73ms startup time.

```bash
nix develop kalilix#neovim
```

**Features:**
- **LSP Support**: Nix, Lua, Bash, YAML, Markdown, JSON, Python, Go, Rust, TypeScript
- **Auto-Format**: 11 formatters with format-on-save (500ms timeout)
- **Git Integration**: gitsigns, fugitive, diffview, lazygit
- **Completion**: nvim-cmp with LSP, snippets, path, buffer sources
- **Additional**: HTTP client (rest.nvim), markdown preview, integrated terminal
- **Performance**: 55% faster startup via lazy loading + byte compilation

**Key Bindings:**
- `<leader>cc` - Open Claude Code (auto-starts server)
- `<leader>co` - Open Claude Code terminal
- `<leader>cs` - Show server status
- `<leader>cq` - Stop server
- `<leader>ff` - Find files (telescope)
- `<leader>fg` - Find in files (grep)
- `<leader>gg` - Open lazygit
- `gd` - Go to definition
- `gr` - Find references
- `K` - Show hover documentation

See [NEOVIM.md](NEOVIM.md) for complete configuration details.

**Example Workflow:**
```bash
# Enter shell
nix develop kalilix#neovim

# Launch Neovim
nvim

# Or with Claude Code integration
# <leader>cc opens AI assistant in terminal
```

</details>

---

## Advanced Installation Options

<details>
<summary><b>📦 Local Clone (For Development)</b></summary>

If you're developing Kalilix itself or want persistent local configuration:

```bash
# 1. Clone repository
git clone https://github.com/usrbinkat/kalilix.git
cd kalilix

# 2. Enter base shell
nix develop

# 3. Or use Mise for workflow automation
mise run setup    # First-time setup
mise run shell    # Enter default shell

# 4. Enter specific shells
nix develop .#python
nix develop .#go
nix develop .#kali

# Or via Mise
mise run dev:python
mise run dev:go
```

**Mise Task Automation:**

```bash
# Discovery
mise tasks              # List all tasks
mise run help           # Show help

# Shells
mise run shell:python   # Python shell
mise run dev:go         # Go shell (alias)

# Nix Operations
mise run nix:update     # Update flake.lock
mise run nix:build      # Build configuration
mise run nix:gc         # Garbage collect

# Container
mise run docker:up      # Start devcontainer
mise run docker:shell   # Enter container
mise run docker:down    # Stop container
```

**74 automated tasks** across 5 modules (main, nix, docker, dev, setup).

</details>

<details>
<summary><b>🐳 Container Development</b></summary>

Systemd-enabled devcontainer with multi-user Nix daemon:

```bash
# Start container (requires Docker)
mise run docker:up

# Enter container
mise run docker:shell

# Inside container, use any shell
nix develop .#python
nix develop .#kali

# View logs
mise run docker:logs

# Stop container
mise run docker:down
```

**Container Features:**
- **Systemd as PID 1**: Proper service management
- **Multi-user Nix daemon**: Isolated builds
- **14 named volumes**: Persistent caches (cargo, go, npm, pip)
- **Docker-outside-of-Docker**: Access host Docker daemon
- **Debian Trixie base**: Modern packages

**Performance:**
- Startup: 3-5s (vs 30-120s for VMs)
- Memory: 100-200MB overhead (vs 2-4GB for VMs)
- I/O: 90-95% native (vs 50-70% for VMs)

</details>

<details>
<summary><b>☁️ GitHub Codespaces</b></summary>

One-click cloud development environment:

1. Open repository in GitHub
2. Click "Code" → "Codespaces" → "Create codespace on main"
3. Wait for initialization (~2 minutes)
4. Environment auto-configures via devcontainer

**Pre-configured:**
- Systemd container
- All Kalilix shells available
- Git configured
- Full tool suite

</details>

<details>
<summary><b>🍎 macOS Specifics</b></summary>

**Installation:**

Follow the [Quick Start](#quick-start) above, but use zsh instead of bash:

```bash
# Step 2 for macOS (zsh default)
cat <<'EOF' | tee -a ~/.zshrc
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
EOF
source ~/.zshrc
```

**Architecture Support:**
- ✅ Apple Silicon (M1/M2/M3)
- ✅ Intel x86_64
- Automatic architecture detection
- Rosetta 2 fallback for x86-only packages

**Security Tools Note:**
- macOS: 28 tools available
- Missing: burpsuite, wpscan, volatility (Linux-only)
- Alternatives: Use Linux VM or container for full tool set

</details>

<details>
<summary><b>🐧 Linux Specifics</b></summary>

**Installation:**

Follow the [Quick Start](#quick-start) above (all distributions supported).

**Optimal Performance:**
- Native Nix installation (no VM layer)
- Direct container support
- All security tools available (GUI + CLI)

</details>

<details>
<summary><b>🪟 WSL2 (Windows)</b></summary>

**Prerequisites:**
- Windows 10/11 with WSL2 enabled
- Ubuntu 22.04+ (or Debian 11+) WSL distribution

**Installation:**

Follow the [Quick Start](#quick-start) above from WSL2 terminal.

**Features:**
- Full Linux compatibility
- All 32 security tools available
- Systemd support (WSL2 required)
- Windows filesystem integration

</details>

<details>
<summary><b>❄️ NixOS</b></summary>

Native flake support - import modules directly:

```nix
# configuration.nix or flake.nix
{
  # Use Lix instead of CppNix
  nix.package = pkgs.lix;

  # Kalilix configuration
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    allow-unfree = true;
    warn-dirty = false;
  };

  # Import Kalilix modules (optional)
  imports = [ /path/to/kalilix/modules ];
}
```

**Usage:**
```bash
# Direct shell access
nix develop github:usrbinkat/kalilix#python

# Or via registry
nix registry add kalilix github:usrbinkat/kalilix
nix develop kalilix#go
```

</details>

---

## Architecture

### Layered Design

```
┌─────────────────────────────────────────────┐
│         User Interface Layer                │
│      (Mise Tasks & Shell Hooks)             │
├─────────────────────────────────────────────┤
│       Development Shell Layer               │
│  (base → python/go/rust/node/devops/kali)   │
├─────────────────────────────────────────────┤
│         Nix Flake Layer                     │
│  (Deterministic Package Management)         │
├─────────────────────────────────────────────┤
│      Platform Abstraction Layer             │
│  (macOS, Linux, NixOS, WSL, Containers)     │
└─────────────────────────────────────────────┘
```

### Key Innovations

#### Technical Architecture Details

**1. Shell Extension Pattern**

Elegant functional composition where specialized shells extend a common base:

```nix
python = base.overrideAttrs (old: {
  buildInputs = old.buildInputs ++ pythonPackages;
  shellHook = old.shellHook + "\n" + pythonSetup;
});
```

**2. Systemd Multi-User Nix Daemon**

First-class systemd integration in containers enabling proper build isolation:
- Systemd as PID 1
- Multi-user Nix daemon via systemd service
- Graceful shutdown with signal handling
- Production-like environment

**3. Claude Code Integration**

Native AI assistance in Neovim via claudecode.nvim plugin:
- Lazy-loaded on command invocation
- Native terminal provider with toggleterm
- Full context awareness

**4. Package Wrapper Pattern**

Custom Nix wrappers solve npm cache issues (see `pulumi-mcp-wrapper.nix`):
- JavaScript-level filesystem interception
- npm cache redirection
- Reusable for other packages

**5. Dual-Channel Strategy**

Combines stable (nixos-25.05) and unstable packages via overlay pattern:
- Stable for core tools
- Unstable for latest versions
- Explicit package source selection

### Project Structure

#### Repository Layout

```bash
kalilix/
├── flake.nix                    # Core Nix flake (entry point)
├── flake.lock                   # Pinned dependencies
├── .mise.toml                   # Task automation root
├── compose.yml                  # Docker composition
├── CLAUDE.md                    # AI assistant guidance
├── NEOVIM.md                    # Neovim configuration guide
│
├── .devcontainer/               # Container environment
│   ├── Dockerfile.systemd       # Systemd-enabled image
│   ├── devcontainer.json        # VS Code config
│   ├── compose/                 # Service definitions
│   └── rootfs/                  # Filesystem overlay
│       └── etc/
│           ├── profile.d/       # Shell initialization
│           ├── sudoers.d/       # Sudo configuration
│           └── systemd/system/  # Systemd units
│
├── modules/                     # Nix modules
│   ├── devshells/
│   │   ├── default.nix          # Shell orchestrator
│   │   ├── base.nix             # Base environment
│   │   ├── neovim.nix           # Neovim configuration
│   │   ├── bash-config.nix      # Shared bash config
│   │   └── security-tools.nix   # Kali security tools
│   ├── packages/
│   │   └── npm/                 # Node packages
│   │       ├── default.nix
│   │       ├── node-packages.nix      # Generated
│   │       ├── node-packages.json     # Declarations
│   │       └── pulumi-mcp-wrapper.nix # Custom wrapper
│   └── programs/
│       ├── tmux/                # Tmux configuration
│       ├── hyfetch/             # Hyfetch configuration
│       └── neovim/              # Neovim modules
│
├── .config/
│   └── mise/
│       ├── tasks/               # Custom scripts
│       │   ├── kx               # CLI interface
│       │   └── nix-bootstrap    # Platform installer
│       └── toml/                # Task modules
│           ├── main.toml        # Primary tasks
│           ├── nix.toml         # Nix operations
│           ├── docker.toml      # Container management
│           ├── dev.toml         # Development workflows
│           └── setup.toml       # Initialization
│
└── docs/
    ├── mcp-server-setup.md
    └── pulumi-mcp-wrapper-implementation.md
```

**Statistics:**
- **Nix Code**: ~2,000 lines authored + 4,180 generated
- **Mise Tasks**: 74 tasks, 1,697 lines across 5 modules
- **Development Shells**: 9 specialized environments
- **Security Tools**: 32 tools (Kali shell)
- **Container Volumes**: 14 for persistence

---

## Configuration

### Environment Variables

<details>
<summary><b>Configuration Options</b></summary>

Key configuration in `.env`:

```bash
# Project Identity
PROJECT_NAME=kalilix
PROJECT_ORG=usrbinkat
PROJECT_ENV=development

# Shell Selection
KALILIX_SHELL=base     # base|python|go|rust|node|devops|kali|full

# Platform (auto-detected)
KALILIX_PLATFORM=auto  # auto|docker|native|wsl

# Nix Configuration
NIX_VERSION=2.24.10
NIX_BUILD_CORES=0      # 0 = use all cores
NIX_MAX_JOBS=auto      # Automatic parallel builds

# Binary Cache
CACHIX_NAME=kalilix
# CACHIX_AUTH_TOKEN=<your-token>  # For pushing to cache

# Feature Flags
KALILIX_AUTO_UPDATE=false
KALILIX_TELEMETRY=false
```

</details>

### Binary Caching

<details>
<summary><b>Cache Configuration</b></summary>

**3-tier caching** for fast builds:

1. **Local Nix store** (`/nix/store`)
2. **Official cache** (cache.nixos.org) - 99% hit rate
3. **Community caches** (nix-community.cachix.org, devenv.cachix.org)

```bash
# Enable project cache (when configured)
mise run nix:cache:enable

# Push to cache (requires CACHIX_AUTH_TOKEN)
mise run nix:cache:push
```

**Performance Impact:**
- Cold start (no cache): ~30-60s for base shell
- Warm start (cached): ~2-5s
- Full environment: <2 minutes vs hours without cache

</details>

### Custom Overlays

<details>
<summary><b>Adding Custom Packages</b></summary>

Create custom overlays to add packages or override versions:

```nix
# my-overlay.nix
final: prev: {
  myCustomTool = prev.callPackage ./my-tool.nix {};

  # Override existing package
  python312 = prev.python312.override {
    # customizations
  };
}
```

Use with:
```bash
nix develop --impure --expr 'import ./flake.nix { overlays = [ ./my-overlay.nix ]; }'
```

</details>

---

## Troubleshooting

<details>
<summary><b>Nix Daemon Not Responding (Container)</b></summary>

```bash
# Check daemon status
sudo systemctl status nix-daemon

# Restart daemon
sudo systemctl restart nix-daemon

# View logs
journalctl -u nix-daemon -n 50
```

</details>

<details>
<summary><b>Permission Denied on Nix Operations</b></summary>

```bash
# Check groups (should include nixbld)
groups

# Fix user groups (requires re-login)
sudo usermod -aG nixbld $USER

# Fix Nix profile ownership
sudo chown -R $USER:$USER ~/.nix-profile
```

</details>

<details>
<summary><b>Flake Evaluation Errors</b></summary>

```bash
# Health check
mise run nix:doctor

# Detailed error trace
nix flake check --impure --show-trace

# Validate syntax
nix flake show
```

</details>

<details>
<summary><b>Container Won't Start</b></summary>

```bash
# Check Docker daemon
docker ps

# View logs
mise run docker:logs

# Rebuild from scratch
mise run docker:rebuild

# Check systemd inside container
mise run docker:shell
systemctl status
```

</details>

<details>
<summary><b>Slow Nix Builds</b></summary>

```bash
# Check cache usage
nix-store --verify --check-contents

# Optimize store
nix-store --optimise

# Garbage collect
mise run nix:gc --aggressive
```

</details>

---

## Contributing

We welcome contributions that maintain the **zero-technical-debt philosophy**.

### Development Setup

```bash
# Fork and clone
git clone https://github.com/yourusername/kalilix.git
cd kalilix

# Create feature branch
git checkout -b feature/your-feature

# Enter full development environment
nix develop .#full

# Make changes and test
mise run test
mise run check:flake

# Commit with conventional commits
git commit -m "feat: add new security tool integration"
```

### Guidelines

1. **Cross-platform compatibility** (macOS, Linux, WSL, containers)
2. **Follow existing patterns** (extendShell, task namespacing)
3. **Update flake.lock** if adding packages
4. **Test across shells** before submitting
5. **Document** new configuration options
6. **Conventional commits** (feat:, fix:, docs:, refactor:)

<details>
<summary><b>Adding Node Packages</b></summary>

1. Edit `modules/packages/npm/node-packages.json`
2. Regenerate Nix expressions:
   ```bash
   cd modules/packages/npm
   nix-shell -p node2nix --run "node2nix -i node-packages.json"
   ```
3. Import in shell: `npmPkgs."package-name"`
4. For cache issues, create wrapper like `pulumi-mcp-wrapper.nix`

</details>

---

## Performance & Optimization

### Build Performance

- **Parallel builds**: Uses all CPU cores (`cores = 0`)
- **Binary caches**: Pre-built packages from 3 sources
- **Incremental builds**: Nix only rebuilds changed dependencies
- **Persistent volumes**: Language caches survive container rebuilds

### Disk Usage

```bash
# Check Nix store size
du -sh /nix/store

# Garbage collect (safe)
mise run nix:gc

# Aggressive cleanup
mise run nix:gc --aggressive

# Remove old generations
nix-collect-garbage --delete-older-than 30d
```

### Memory Optimization

- **Lazy loading**: Shells only load packages when entered
- **Shared dependencies**: Common packages deduplicated
- **Container tuning**: Resource limits in compose.yml

---

## Security

### Container Security

- **No privileged mode**: Uses capabilities instead
- **Minimal capabilities**: Only SYS_ADMIN, SYS_NICE, SYS_RESOURCE, NET_ADMIN
- **Dropped capabilities**: SYS_BOOT, SYS_TIME, MKNOD, AUDIT_WRITE
- **User namespace**: debian user (UID 1000) in nixbld group

### Credential Management

- **Environment-based**: Secrets via `.env` (gitignored)
- **No hardcoded secrets**: All sensitive data externalized
- **Git-ignored configs**: Sensitive files excluded from version control

### Supply Chain Security

- **Reproducible builds**: Nix flakes with lockfile
- **Cryptographic verification**: All packages hash-verified
- **Pinned dependencies**: Exact versions in flake.lock
- **Multi-source verification**: Official + community caches

---

## Philosophy

Kalilix represents a **paradigm shift in development environments**:

1. **Reproducibility as Foundation** - Environments are code, not just code in environments
2. **Tools Adapt to Workflows** - No artificial boundaries between domains
3. **Zero Technical Debt** - Every decision justified, documented
4. **Developer Experience First** - Optimized for productivity and ergonomics
5. **Cross-Platform Consistency** - Same behavior everywhere

This project exists at the **intersection of security operations, software development, and infrastructure automation**. It acknowledges that modern work requires fluid movement between these domains.

By building on **Nix's foundation of reproducible, declarative configuration**, Kalilix provides not just tools, but a **framework for thinking about development environments as code**.

---

## Community & Support

### Resources

- **Documentation**: `docs/` directory
- **AI Guidance**: `CLAUDE.md` for Claude Code
- **Neovim Guide**: `NEOVIM.md` for editor configuration
- **Issues**: [GitHub Issues](https://github.com/usrbinkat/kalilix/issues)

### Getting Help

```bash
# Built-in help
mise run help          # Task overview
mise run info          # Environment details
mise run status        # Health check
mise run nix:doctor    # Nix diagnostics

# Debug mode
MISE_VERBOSE=1 mise run <task>
nix develop --verbose --print-build-logs
```

---

## Acknowledgments

Kalilix builds upon exceptional open source work:

- **Nix & NixOS communities** - Revolutionary package management
- **Kali Linux maintainers** - Security tool curation
- **Determinate Systems** - Reliable Nix installers
- **Mise community** - Modern task automation
- **NixVim community** - Neovim configuration framework

---

## License

Apache License 2.0 - See [LICENSE](LICENSE) for details.

Individual tools and packages maintain their original licenses.

---

**Kalilix**: _Development environments without boundaries. Tools without compromise._

_Built with Nix. Powered by Mise. Enhanced by AI._
