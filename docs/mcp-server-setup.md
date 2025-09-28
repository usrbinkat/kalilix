# MCP Server Setup for Kalilix

## Overview

MCP (Model Context Protocol) servers in Kalilix can be set up using the existing development shells that already provide the necessary tools.

## Available MCP Servers

Based on `.mcp.json` configuration:

### 1. GitHub MCP Server (Docker-based)
- **Command**: Runs via Docker container
- **Shell**: Use `nix develop .#devops` or `nix develop .#full` 
- **Setup**: Already configured to use `ghcr.io/github/github-mcp-server`

### 2. Git MCP Server (Python package)
- **Package**: `mcp-server-git` (Python PyPI package)
- **Shell**: Use `nix develop .#python` or `nix develop .#full`
- **Installation**: 
  ```bash
  # Enter Python shell
  nix develop .#python
  
  # Install via uvx (temporary)
  uvx mcp-server-git
  
  # Or install via pip in venv
  uv venv
  source .venv/bin/activate
  uv pip install mcp-server-git
  ```

### 3. Perplexity Server
- **Package**: `server-perplexity-ask` (npm package via npx)
- **Shell**: Use `nix develop .#node` or `nix develop .#full`
- **Note**: Configured to run via `npx -y`

### 4. Fetch Server
- **Status**: Need to determine correct package (not found in npm/pypi searches)

### 5. Pulumi MCP Server
- **Package**: `@pulumi/mcp-server` (npm package via npx)
- **Shell**: Use `nix develop .#node` or `nix develop .#full`
- **Note**: Configured to run via `npx -y`

### 6. DeepWiki
- **Type**: HTTP endpoint
- **URL**: `https://mcp.deepwiki.com/mcp`
- **Note**: No local installation needed

## Docker Socket Issue

The Docker socket is available at `/var/run/docker-host.sock` instead of the standard `/var/run/docker.sock`. To use Docker commands:

```bash
# Set Docker host
export DOCKER_HOST=unix:///var/run/docker-host.sock

# Or use with command
DOCKER_HOST=unix:///var/run/docker-host.sock docker ps
```

## Using the Correct Shell

Choose the appropriate shell based on your MCP server needs:

- **For Python-based servers** (mcp-server-git): `nix develop .#python`
- **For Docker-based servers** (GitHub): `nix develop .#devops`
- **For Node.js-based servers** (Perplexity, Pulumi): `nix develop .#node`
- **For everything**: `nix develop .#full`

## No Code Duplication Needed

The Kalilix flake is already well-structured with:
- Python + uv in the `python` shell
- Docker-client in the `devops` shell
- Node.js + npm/npx in the `node` shell
- All tools combined in the `full` shell

No additional packages need to be added to the base configuration for MCP server support.