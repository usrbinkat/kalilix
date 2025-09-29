# Kalilix

A modern, reproducible security and development environment built on Nix flakes, bringing the power of Kali Linux to any platform without virtual machine boundaries.

## Overview

Kalilix reimagines security tooling and development environments through the lens of functional package management. By leveraging Nix flakes, this project delivers Kali Linux's comprehensive toolkit as a composable, customizable, and reproducible environment that runs natively on macOS, Linux, NixOS, WSL, and container platforms.

### Why Kalilix?

Traditional security distributions require dedicated hardware, virtual machines, or dual-boot configurations. These approaches introduce friction, resource overhead, and context-switching penalties that impede workflow efficiency. Kalilix eliminates these boundaries by providing:

- **Native Performance**: Tools run directly on your host system without virtualization overhead
- **Selective Installation**: Import only the tools you need, when you need them
- **Reproducible Environments**: Share exact tool versions and configurations across teams
- **Cross-Platform Consistency**: Identical behavior across macOS, Linux, and WSL
- **Composable Architecture**: Mix security tools with development environments seamlessly

## Architecture

Kalilix employs a layered architecture designed for flexibility and reliability:

```
┌─────────────────────────────────────────────┐
│            User Interface Layer             │
│         (Mise Tasks & Shell Hooks)          │
├─────────────────────────────────────────────┤
│          Development Shell Layer            │
│    (base, python, go, rust, node, devops)  │
├─────────────────────────────────────────────┤
│            Nix Flake Layer                  │
│    (Package Management & Configuration)     │
├─────────────────────────────────────────────┤
│         Platform Abstraction Layer          │
│   (macOS, Linux, NixOS, WSL, Containers)   │
└─────────────────────────────────────────────┘
```

### Core Technologies

- **Nix Flakes**: Provides deterministic package management and system configuration
- **Systemd**: Enables proper service management within containerized environments
- **Mise**: Orchestrates development tasks and workflow automation
- **Debian Trixie**: Serves as the container base for maximum compatibility
- **MCP Servers**: Integrates AI-assisted development capabilities

## Getting Started

### Prerequisites

Kalilix requires minimal initial setup. The system will bootstrap itself with all necessary dependencies.

#### Native Installation (macOS/Linux/WSL)

```bash
# Clone the repository
git clone https://github.com/usrbinkat/kalilix.git
cd kalilix

# The environment auto-initializes via Mise hooks
# Tools install on first use through Nix
```

#### Container Development (GitHub Codespaces/VS Code)

The project includes a fully configured devcontainer that provides:

- Systemd-enabled container with multi-user Nix daemon
- Pre-configured development shells
- Docker-outside-of-Docker support
- Integrated AI assistance through MCP servers

```bash
# Open in VS Code with Dev Containers extension
code kalilix

# Or use GitHub Codespaces directly from the repository
```

### Development Shells

Kalilix provides specialized development environments, each optimized for specific workflows:

```bash
# Enter the base environment (minimal toolset)
nix develop

# Python development with security libraries
nix develop .#python

# Go development environment
nix develop .#go

# Rust development with cargo tools
nix develop .#rust

# Node.js and JavaScript tooling
nix develop .#node

# DevOps and cloud infrastructure tools
nix develop .#devops

# Complete polyglot environment with all toolchains
nix develop .#full
```

Each shell includes:

- Language-specific toolchains and package managers
- Integrated linters and formatters
- Debugging tools and language servers
- Automatic dependency installation
- MCP server integration for AI assistance

## Task Automation

Mise provides comprehensive task automation for common workflows:

```bash
# Display all available tasks
mise tasks

# Show detailed help
mise run help

# System information and status
mise run info

# Enter a specific development shell
mise run shell python

# View current environment status
mise run status
```

### Task Categories

- **Setup Tasks**: Initialize and configure environments
- **Development Tasks**: Build, test, and debug workflows
- **Nix Tasks**: Manage flakes and packages
- **Docker Tasks**: Container and compose operations
- **Maintenance Tasks**: System cleanup and updates

## MCP Integration

Kalilix includes pre-configured Model Context Protocol servers for AI-enhanced development:

- **GitHub**: Repository and issue management
- **Git**: Version control operations
- **Perplexity**: Advanced code search and analysis
- **Fetch**: Web resource retrieval
- **DeepWiki**: Documentation comprehension
- **Pulumi**: Infrastructure-as-code assistance

Configure your API keys in `.mcp.json` (see `.mcp.json.example` for template).

## Project Structure

```
kalilix/
├── flake.nix                 # Core Nix flake configuration
├── flake.lock               # Pinned dependency versions
├── .mise.toml               # Task automation and environment setup
├── compose.yml              # Docker composition root
├── .devcontainer/           # Container development environment
│   ├── Dockerfile.systemd   # Systemd-enabled container image
│   └── compose/            # Container service definitions
├── modules/                 # Nix modules and packages
│   ├── devshells/          # Development environment definitions
│   └── packages/           # Custom package definitions
├── .config/                # Configuration files
│   ├── mise/               # Mise task definitions
│   └── nix/                # Nix-specific configuration
└── scripts/                # Utility and helper scripts
```

## Advanced Configuration

### Environment Variables

The project supports extensive customization through environment variables. Key configuration options:

```bash
# Project identification
PROJECT_NAME=kalilix
PROJECT_ENV=development

# Development shell selection
KALILIX_SHELL=base  # Options: base, python, go, rust, node, devops, full

# Feature flags
KALILIX_AUTO_UPDATE=false
KALILIX_TELEMETRY=false

# Performance tuning
NIX_BUILD_CORES=0     # Use all available cores
NIX_MAX_JOBS=auto     # Automatic parallel builds
```

Copy `.env.example` to `.env` and customize as needed.

### Nix Configuration

The flake provides fine-grained control over package versions and build options:

```nix
# Use specific package versions
nix develop .#python --override-input nixpkgs github:NixOS/nixpkgs/<commit>

# Build with custom overlays
nix develop --impure --expr 'import ./flake.nix { overlays = [ ./my-overlay.nix ]; }'
```

### Container Customization

The systemd-enabled devcontainer supports advanced configurations:

- Custom systemd services via `.devcontainer/rootfs/etc/systemd/system/`
- Additional packages through Dockerfile.systemd modifications
- Volume mounts for persistent development data
- Network configurations for service exposure

## Performance Optimization

Kalilix implements several strategies to minimize overhead and maximize performance:

### Binary Caching

Pre-built packages are cached to eliminate compilation time:

```bash
# Configure Cachix (optional)
cachix use kalilix

# Or use the included binary caches
nix develop --option binary-caches "https://cache.nixos.org https://nix-community.cachix.org"
```

### Persistent Volumes

Development artifacts persist across container rebuilds:

- Nix store and package cache
- Language-specific dependency caches
- Build artifacts and compilation output
- User configuration and history

### Resource Management

The container environment implements intelligent resource allocation:

- Automatic CPU core detection for parallel builds
- Memory-efficient systemd configuration
- Optimized network sysctls for development workloads
- Lazy loading of development tools

## Security Considerations

Kalilix prioritizes security while maintaining development flexibility:

### Container Security

- Minimal required capabilities (no `--privileged` mode)
- Seccomp and AppArmor profiles where supported
- User namespace isolation
- Read-only root filesystem where possible

### Credential Management

- Environment-based secret injection
- Support for GitHub Codespaces secrets
- MCP server credentials isolated per service
- No credentials in version control

### Supply Chain Security

- Reproducible builds through Nix flakes
- Cryptographic verification of all packages
- Pinned dependencies with lock files
- Regular security updates through flake updates

## Troubleshooting

### Common Issues

**Nix daemon not responding**

```bash
# Restart the Nix daemon in containers
sudo systemctl restart nix-daemon

# Verify daemon status
systemctl status nix-daemon
```

**Locale warnings**

```bash
# The environment auto-configures locales, but if issues persist:
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
```

**Permission denied errors**

```bash
# Ensure your user is in the correct groups
groups  # Should show: nixbld, docker (if applicable)

# Fix ownership of Nix profiles
sudo chown -R $USER:$USER ~/.nix-profile
```

### Debug Mode

Enable verbose output for troubleshooting:

```bash
# Mise debug mode
MISE_VERBOSE=1 mise run <task>

# Nix build debugging
nix develop --verbose --print-build-logs

# Container diagnostics
docker compose logs devcontainer
journalctl -xef  # Within container
```

## Contributing

Kalilix welcomes contributions that align with its philosophy of zero technical debt and state-of-the-art implementation. Before contributing:

1. Ensure changes maintain cross-platform compatibility
2. Follow the existing architectural patterns
3. Include appropriate Nix expressions for new packages
4. Test across multiple development shells
5. Document any new environment variables or configuration options

### Development Workflow

```bash
# Create feature branch
git checkout -b feature/your-feature

# Enter full development environment
nix develop .#full

# Make changes and test
mise run test

# Verify Nix expressions
nix flake check

# Commit with conventional commit format
git commit -m "feat: add new security tool integration"
```

## Platform-Specific Notes

### macOS

Kalilix fully supports macOS on both Intel and Apple Silicon:

- Automatic architecture detection for native packages
- Rosetta 2 fallback for x86-only tools
- Integration with Homebrew when needed
- Docker Desktop compatibility for container workflows

### WSL

Windows Subsystem for Linux provides near-native Linux experience:

- WSL2 recommended for systemd support
- Automatic Windows path integration
- Docker Desktop WSL2 backend support
- VS Code Remote-WSL extension compatible

### NixOS

Native NixOS systems can use Kalilix modules directly:

```nix
# In your configuration.nix or home-manager
{
  imports = [ /path/to/kalilix/modules ];

  programs.kalilix.enable = true;
}
```

## Roadmap

Kalilix continues to evolve toward comprehensive security and development environment unification:

### Near Term

- Expanded security tool catalog
- Enhanced MCP server integrations
- Improved caching strategies
- Additional language ecosystems

### Long Term

- Native GUI application support
- Distributed team environments
- Custom security tool development framework
- Automated vulnerability assessment workflows

## Philosophy

Kalilix represents a fundamental shift in how security and development environments are conceived. Rather than accepting the traditional boundaries between host systems and specialized distributions, it embraces the principle that tools should adapt to workflows, not the reverse.

This project exists at the intersection of security operations, software development, and infrastructure automation. It acknowledges that modern technical work requires fluid movement between these domains, and that artificial barriers between them only serve to impede progress.

By building on Nix's foundation of reproducible, declarative system configuration, Kalilix provides not just a collection of tools, but a framework for thinking about development environments as code. This approach enables teams to share not just code, but entire working environments, complete with tools, configurations, and dependencies.

## License

Kalilix is open source software. Specific licensing information will be added as the project stabilizes. Individual tools and packages maintain their original licenses.

## Acknowledgments

Kalilix builds upon the exceptional work of numerous open source communities:

- The Nix and NixOS communities for revolutionary package management
- Kali Linux maintainers for curating security tools
- Determinate Systems for reliable Nix installers
- The broader open source security community

---

_Kalilix: Security tools without boundaries. Development environments without compromise._
