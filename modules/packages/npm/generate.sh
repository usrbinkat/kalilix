#!/usr/bin/env bash
# Generate Nix expressions for npm packages
# This creates deterministic, reproducible Nix derivations for all npm dependencies

set -euo pipefail

echo "Generating node2nix expressions for npm packages..."

# Use node2nix to generate the Nix expressions
# Using Node.js 18 (latest supported by node2nix 1.11.0)
# We'll override to nodejs_22 in our Nix expression
node2nix \
  -i node-packages.json \
  -18 \
  --output node-packages.nix \
  --composition default.nix \
  --node-env node-env.nix \
  --include-peer-dependencies

echo "✅ Generated node2nix expressions"
echo ""
echo "Files created:"
echo "  - node-packages.nix: Package definitions"
echo "  - node-env.nix: Node environment builder"
echo "  - default.nix: Composition expression"