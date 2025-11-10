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

- **Lix**: Community-maintained Nix fork with improved error messages and modern features (version 2.93.0)
- **Nix Flakes**: Provides deterministic package management and system configuration
- **Systemd**: Enables proper service management within containerized environments
- **Mise**: Orchestrates development tasks and workflow automation
- **Debian Trixie**: Serves as the container base for maximum compatibility
- **MCP Servers**: Integrates AI-assisted development capabilities

## Getting Started

### Prerequisites

Kalilix requires minimal initial setup. The system will bootstrap itself with all necessary dependencies.

#### Quick Bootstrap (Recommended)

For first-time setup on any platform:

```bash
# Clone the repository
git clone https://github.com/usrbinkat/kalilix.git
cd kalilix

# Run the automated bootstrap
mise run bootstrap
```

The bootstrap process will:
1. Install Lix/Nix package manager for your platform
2. Configure binary caches for faster package downloads
3. Add your user to trusted-users for seamless operation
4. Validate the flake configuration
5. Set up experimental features (flakes, nix-command)

**Supported Platforms:**
- **macOS** (Intel and Apple Silicon) - uses launchd for daemon management
- **Linux** (Ubuntu, Debian, Fedora, Arch, openSUSE) - uses systemd multi-user daemon
- **WSL** (Windows Subsystem for Linux) - auto-detects systemd availability
- **Containers** (Docker, Podman) - optimized for containerized environments

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

# Bootstrap complete environment (first-time setup)
mise run bootstrap

# System information and status
mise run info

# Enter a specific development shell
mise run shell python

# View current environment status
mise run status
```

### Task Categories

- **Setup Tasks**: Initialize and configure environments
- **Bootstrap Tasks**: Automated Lix/Nix installation and configuration
- **Development Tasks**: Build, test, and debug workflows
- **Nix Tasks**: Manage flakes and packages
- **Docker Tasks**: Container and compose operations
- **Maintenance Tasks**: System cleanup and updates

### Nix-Specific Tasks

```bash
# Install Nix/Lix (auto-detects platform)
mise run nix:install

# Configure binary caches and trusted users
mise run nix:cache:configure

# Run health checks on Nix installation
mise run nix:doctor

# Update flake inputs to latest versions
mise run nix:update

# Garbage collect unused packages
mise run nix:gc

# Search for packages in nixpkgs
mise run nix:search <package>

# Enter a specific development shell
mise run nix:shell python
```

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
│   │   ├── toml/          # Task configuration files
│   │   └── tasks/         # Executable task scripts
│   └── nix/                # Nix-specific configuration
├── kubevirt/               # KubeVirt VM testing manifests
│   ├── kalilix-userdata.yaml          # Cloud-init configuration
│   └── ubuntu-kalilix-flake-minimal.yaml  # VM specification
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

# Platform override (auto-detected by default)
KALILIX_PLATFORM=auto  # Options: auto, linux, macos, wsl, container

# Nix/Lix configuration
NIX_VERSION=2.93.0
NIX_INSTALLER_URL=https://install.lix.systems/lix

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

### Binary Cache Configuration

Kalilix uses a minimal user configuration approach where `flake.nix` serves as the single source of truth for binary caches and public keys:

```bash
# User configuration (automatically created by bootstrap)
~/.config/nix/nix.conf:
  experimental-features = nix-command flakes
  accept-flake-config = true
  auto-optimise-store = true

# Flake configuration (single source of truth)
flake.nix nixConfig:
  extra-substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
    "https://devenv.cachix.org"
  ]
  extra-trusted-public-keys = [ ... ]
```

This approach eliminates configuration duplication and ensures cache settings are version-controlled with the flake.

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
# Configure via mise (automatically sets accept-flake-config)
mise run nix:cache:configure

# Or manually configure Cachix for project-specific cache
cachix use kalilix

# Cache settings come from flake.nix nixConfig
# No need to specify URLs manually
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
# Linux: Restart systemd daemon
sudo systemctl restart nix-daemon
systemctl status nix-daemon

# macOS: Restart launchd daemon
sudo launchctl kickstart -k system/org.nixos.nix-daemon
```

**Experimental features not enabled**

```bash
# Run cache configuration to enable features
mise run nix:cache:configure

# Verify configuration
grep experimental-features ~/.config/nix/nix.conf
```

**Flake evaluation fails**

```bash
# Run comprehensive health check
mise run nix:doctor

# Check flake syntax
nix flake check --impure

# View detailed evaluation errors
nix flake check --impure --show-trace
```

**Untrusted user warnings**

```bash
# Re-run cache configuration to add user to trusted-users
mise run nix:cache:configure

# Manually verify
sudo grep trusted-users /etc/nix/nix.conf
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

### Platform-Specific Troubleshooting

**macOS: sed compatibility issues**

The bootstrap uses portable `sed` syntax that works with both GNU sed (Linux) and BSD sed (macOS). If you encounter sed-related errors, ensure you're running the latest version from the repository.

**WSL: systemd not available**

The bootstrap auto-detects systemd availability in WSL. For WSL2 with systemd support, ensure your `/etc/wsl.conf` contains:

```ini
[boot]
systemd=true
```

## Testing and Validation

### Automated VM Testing

Kalilix includes KubeVirt manifests for automated testing on Kubernetes:

```bash
# Create SSH key secret
kubectl create secret generic kargo-sshpubkey-kali \
  --from-file=key1=$HOME/.ssh/id_ed25519.pub

# Create cloud-init userdata secret
kubectl create secret generic kalilix-userdata \
  --from-file=userdata=kubevirt/kalilix-userdata.yaml

# Deploy test VM
kubectl apply -f kubevirt/ubuntu-kalilix-flake-minimal.yaml

# Monitor bootstrap progress
kubectl get vmi kalilix -o jsonpath='{.status.interfaces[0].ipAddress}'
ssh kali@<VM_IP>
tail -f /var/log/cloud-init-output.log
```

The cloud-init configuration automatically:
1. Installs mise
2. Clones the repository
3. Runs `mise run bootstrap`
4. Prebuilds the full development shell
5. Configures shell profiles for immediate use

## Contributing

Kalilix welcomes contributions that align with its philosophy of zero technical debt and state-of-the-art implementation. Before contributing:

1. Ensure changes maintain cross-platform compatibility (macOS, Linux, WSL)
2. Follow the existing architectural patterns
3. Include appropriate Nix expressions for new packages
4. Test across multiple development shells
5. Document any new environment variables or configuration options
6. Use conventional commit format (lowercase, no attribution)

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

# Run health checks
mise run nix:doctor

# Commit with conventional commit format
git commit -m "feat: add new security tool integration"
```

## Platform-Specific Notes

### macOS

Kalilix fully supports macOS on both Intel and Apple Silicon:

- Automatic architecture detection for native packages
- Rosetta 2 fallback for x86-only tools
- Integration with Homebrew when needed (< 5% usage)
- Docker Desktop compatibility for container workflows
- Launchd daemon management (auto-configured by bootstrap)
- BSD sed compatibility in all automation

### WSL

Windows Subsystem for Linux provides near-native Linux experience:

- WSL2 recommended for systemd support
- Automatic Windows path integration
- Docker Desktop WSL2 backend support
- VS Code Remote-WSL extension compatible
- Auto-detects systemd availability for daemon configuration

### Linux

Native Linux distributions are fully supported:

- **Ubuntu 24.04** - Validated with automated cloud-init testing
- **Debian 13** - Full compatibility expected
- **Fedora 43** - DNF-based, systemd multi-user daemon
- **Arch Linux** - Rolling release support
- **openSUSE** - Zypper-based distributions
- All use systemd for nix-daemon management

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
- Cross-platform validation on all supported platforms

### Long Term

- Native GUI application support
- Distributed team environments
- Custom security tool development framework
- Automated vulnerability assessment workflows

## Philosophy

Kalilix represents a fundamental shift in how security and development environments are conceived. Rather than accepting the traditional boundaries between host systems and specialized distributions, it embraces the principle that tools should adapt to workflows, not the reverse.

This project exists at the intersection of security operations, software development, and infrastructure automation. It acknowledges that modern technical work requires fluid movement between these domains, and that artificial barriers between them only serve to impede progress.

By building on Nix's foundation of reproducible, declarative system configuration, Kalilix provides not just a collection of tools, but a framework for thinking about development environments as code. This approach enables teams to share not just code, but entire working environments, complete with tools, configurations, and dependencies.

The project's adoption of Lix (a community-maintained Nix fork) reflects its commitment to community-driven development and modern error messaging that makes the Nix ecosystem more accessible to newcomers while maintaining the same rigorous reproducibility guarantees.

## License

Kalilix is open source software. Specific licensing information will be added as the project stabilizes. Individual tools and packages maintain their original licenses.

## Acknowledgments

Kalilix builds upon the exceptional work of numerous open source communities:

- The Lix and NixOS communities for revolutionary package management
- Kali Linux maintainers for curating security tools
- The Mise project for elegant task orchestration
- The broader open source security community

---

_Kalilix: Security tools without boundaries. Development environments without compromise._
