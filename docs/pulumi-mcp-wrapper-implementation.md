# Pulumi MCP Server Nix Wrapper Implementation

## Problem
The `@pulumi/mcp-server` npm package tries to create a `.cache` directory in its installation path, which fails in the read-only Nix store.

## Solution
Created a wrapper that patches Node.js filesystem operations to redirect cache directory creation to a writable location.

## Implementation Details

### 1. Wrapper Script (`modules/packages/npm/pulumi-mcp-wrapper.nix`)
- Creates a Node.js patch script that intercepts `fs.mkdirSync` and `path.join` calls
- Redirects any `.cache` directory operations from `/nix/store/` to `~/.cache/pulumi-mcp-server`
- Sets up proper environment variables for Pulumi and Node.js
- Respects standard cache directory conventions (`XDG_CACHE_HOME`, `PULUMI_HOME`)

### 2. Integration in DevShells (`modules/devshells/base.nix`)
- Imports the wrapped version instead of the raw npm package
- Ensures the wrapper is available in all development shells

### 3. MCP Configuration (`.mcp.json`)
```json
"pulumi": {
  "type": "stdio",
  "command": "pulumi-mcp-server",
  "args": ["stdio"],
  "env": {
    "PULUMI_ACCESS_TOKEN": "your-token",
    "PULUMI_HOME": "/home/debian/.pulumi",
    "HOME": "/home/debian"
  }
}
```

## Key Features

1. **Cache Directory Hierarchy**:
   - First checks `MCP_CACHE_DIR` environment variable
   - Falls back to `XDG_CACHE_HOME/pulumi-mcp-server`
   - Then tries `PULUMI_HOME/.cache/mcp-server`
   - Finally uses `~/.cache/pulumi-mcp-server`

2. **Transparent Operation**:
   - MCP protocol communication is not disrupted
   - Help output shows correct program name
   - All arguments are properly passed through

3. **Environment Setup**:
   - Sets `PULUMI_SKIP_UPDATE_CHECK=true` to avoid network calls
   - Configures Node.js cache directories
   - Creates all necessary directories before execution

## Testing

```bash
# Test basic functionality
echo '{"jsonrpc": "2.0", "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "test", "version":"1.0.0"}}, "id": 1}' | pulumi-mcp-server stdio

# Check MCP server connectivity
claude mcp list
```

## Result
The Pulumi MCP server now works correctly in the Nix environment, with all cache operations redirected to writable locations while maintaining full MCP protocol compatibility.