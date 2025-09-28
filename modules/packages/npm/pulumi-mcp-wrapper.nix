# Wrapper for Pulumi MCP Server to handle cache directory issues
{ pkgs }:

let
  # Import the npm packages
  npmPkgs = import ./default.nix {
    inherit pkgs;
    inherit (pkgs.stdenv.hostPlatform) system;
    nodejs = pkgs.nodejs_22;
  };

  # Create a wrapper script that sets up proper cache directories
  pulumiMcpServerWrapped = pkgs.writeShellScriptBin "pulumi-mcp-server" ''
    # Set up cache directory in a writable location
    if [ -n "$HOME" ] && [ -w "$HOME" ]; then
      CACHE_DIR="$HOME/.cache/pulumi-mcp-server"
    else
      CACHE_DIR="/tmp/pulumi-mcp-server-cache-$(id -u)"
    fi

    # Create cache directory
    mkdir -p "$CACHE_DIR"

    # Set environment variables for cache locations
    export XDG_CACHE_HOME="$CACHE_DIR"
    export PULUMI_HOME="$HOME/.pulumi"

    # Create a temporary directory for the MCP server runtime
    export TMPDIR="$CACHE_DIR/tmp"
    mkdir -p "$TMPDIR"

    # Run the original pulumi-mcp-server
    exec ${npmPkgs."@pulumi/mcp-server"}/bin/pulumi-mcp-server "$@"
  '';

in pulumiMcpServerWrapped