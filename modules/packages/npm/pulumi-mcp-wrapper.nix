# Wrapper for Pulumi MCP Server to handle cache directory issues
{ pkgs }:

let
  # Import the npm packages
  npmPkgs = import ./default.nix {
    inherit pkgs;
    inherit (pkgs.stdenv.hostPlatform) system;
    nodejs = pkgs.nodejs_22;
  };

  # Embed the patch script directly in Nix
  patchScript = pkgs.writeText "pulumi-mcp-patch.js" ''
    #!/usr/bin/env node

    // Patch for pulumi-mcp-server to redirect cache directory from read-only Nix store
    // to a writable location in the user's home directory

    const Module = require('module');
    const path = require('path');
    const fs = require('fs');
    const os = require('os');

    // Determine writable cache directory
    function getWritableCacheDir() {
      // Try environment variables first
      if (process.env.MCP_CACHE_DIR) {
        return process.env.MCP_CACHE_DIR;
      }
      if (process.env.XDG_CACHE_HOME) {
        return path.join(process.env.XDG_CACHE_HOME, 'pulumi-mcp-server');
      }
      if (process.env.PULUMI_HOME) {
        return path.join(process.env.PULUMI_HOME, '.cache', 'mcp-server');
      }

      // Fall back to home directory
      const homeDir = process.env.HOME || os.homedir();
      return path.join(homeDir, '.cache', 'pulumi-mcp-server');
    }

    // Get the cache directory and ensure it exists
    const CACHE_DIR = getWritableCacheDir();
    fs.mkdirSync(CACHE_DIR, { recursive: true });

    // Patch the fs.mkdirSync function to redirect cache directory creation
    const originalMkdirSync = fs.mkdirSync;
    fs.mkdirSync = function(targetPath, options) {
      // Check if this is trying to create a cache directory in the Nix store
      if (typeof targetPath === 'string' && targetPath.includes('/nix/store/') && targetPath.includes('.cache')) {
        // Redirect to our writable cache directory
        const relativePath = path.basename(targetPath);
        const redirectedPath = path.join(CACHE_DIR, relativePath);
        return originalMkdirSync(redirectedPath, options);
      }
      // Call original function for all other paths
      return originalMkdirSync(targetPath, options);
    };

    // Also patch path.join to redirect cache directory references
    const originalPathJoin = path.join;
    path.join = function(...args) {
      const result = originalPathJoin(...args);
      // If the result is a cache directory in the Nix store, redirect it
      if (result.includes('/nix/store/') && result.includes('.cache')) {
        const redirected = result.replace(/.*\/\.cache/, CACHE_DIR);
        // Removed verbose logging to avoid interfering with MCP protocol
        return redirected;
      }
      return result;
    };

    // The wrapper passes the MCP server path as argv[2], and arguments after that
    const mcpServerPath = process.argv[2] || '${npmPkgs."@pulumi/mcp-server"}/lib/node_modules/@pulumi/mcp-server/dist/index.js';

    // Fix argv to show correct program name and pass through actual arguments
    // Skip argv[2] which is the script path, keep arguments from argv[3] onward
    const originalArgs = process.argv.slice(3);
    process.argv = ['node', 'pulumi-mcp-server', ...originalArgs];

    // Import the MCP server - this will use our patched fs and path modules
    import(mcpServerPath).catch(err => {
      console.error('Failed to load pulumi-mcp-server:', err);
      process.exit(1);
    });
  '';

  # Create a wrapper script that sets up proper cache directories
  pulumiMcpServerWrapped = pkgs.writeShellScriptBin "pulumi-mcp-server" ''
    # Determine the proper HOME directory
    # In containers, HOME might be set incorrectly or point to read-only locations
    if [ -z "$HOME" ] || [ ! -w "$HOME" ]; then
      # Try common writable locations
      if [ -w "/workspace/kalilix" ]; then
        export HOME="/workspace/kalilix"
      elif [ -w "/tmp" ]; then
        export HOME="/tmp/pulumi-home-$(id -u)"
        mkdir -p "$HOME"
      fi
    fi

    # Set up Pulumi home directory following core Pulumi conventions
    # This should be respected by all Pulumi tools including MCP server
    if [ -z "$PULUMI_HOME" ]; then
      export PULUMI_HOME="$HOME/.pulumi"
    fi
    mkdir -p "$PULUMI_HOME"

    # Set up cache directories for various systems
    # XDG cache for general caching
    export XDG_CACHE_HOME="$HOME/.cache"
    mkdir -p "$XDG_CACHE_HOME"

    # Node.js specific cache directories
    export npm_config_cache="$XDG_CACHE_HOME/npm"
    export NODE_CACHE_DIR="$XDG_CACHE_HOME/node"
    mkdir -p "$npm_config_cache" "$NODE_CACHE_DIR"

    # Create MCP-specific cache directory
    export MCP_CACHE_DIR="$XDG_CACHE_HOME/pulumi-mcp-server"
    mkdir -p "$MCP_CACHE_DIR"

    # Set up temporary directory
    export TMPDIR="$XDG_CACHE_HOME/tmp"
    mkdir -p "$TMPDIR"

    # Additional Pulumi environment variables that might help
    # These follow patterns from core Pulumi codebase
    export PULUMI_SKIP_UPDATE_CHECK="true"  # Avoid network calls for updates
    export PULUMI_AUTOMATION_API_SKIP_VERSION_CHECK="true"  # Skip version validation

    # Ensure the Pulumi access token is available if set
    # (will be passed through from .mcp.json env section)

    # Debug output (comment out in production)
    # >&2 echo "pulumi-mcp-server wrapper: HOME=$HOME"
    # >&2 echo "pulumi-mcp-server wrapper: PULUMI_HOME=$PULUMI_HOME"
    # >&2 echo "pulumi-mcp-server wrapper: XDG_CACHE_HOME=$XDG_CACHE_HOME"

    # Run the patched pulumi-mcp-server
    # Use our patch script that intercepts fs operations to redirect cache
    exec ${pkgs.nodejs_22}/bin/node ${patchScript} ${npmPkgs."@pulumi/mcp-server"}/lib/node_modules/@pulumi/mcp-server/dist/index.js "$@"
  '';

in pulumiMcpServerWrapped