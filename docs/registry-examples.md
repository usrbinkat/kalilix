# Nix/Lix Flake Registry Examples

## Understanding Registry Hierarchy

Registries are checked in this order (lowest to highest precedence):

1. **Global Registry** (downloaded, cached locally)
   - Location: Cached in `~/.cache/nix/`
   - Source: Defined by `flake-registry` in nix.conf
   - Updates: Automatically when older than `tarball-ttl`

2. **System Registry** (shared by all users)
   - Location: `/etc/nix/registry.json`
   - Requires: root/sudo to modify
   - Use for: System-wide shortcuts

3. **User Registry** (per-user)
   - Location: `~/.config/nix/registry.json`
   - Managed by: `nix registry` commands
   - Use for: Personal development shortcuts

4. **CLI Overrides** (command-line)
   - Flag: `--override-flake`
   - Use for: Temporary testing/debugging

## Common Registry Management Commands

```bash
# List all active registry entries
nix registry list

# Add a custom flake shortcut
nix registry add myproject github:myorg/myproject

# Pin a flake to its current version (useful for reproducibility)
nix registry pin nixpkgs

# Pin to a specific version
nix registry pin nixpkgs github:NixOS/nixpkgs/nixos-23.11

# Remove a registry entry
nix registry remove myproject

# Override a flake temporarily (doesn't modify registry)
nix build nixpkgs#hello --override-flake nixpkgs github:me/nixpkgs
```

## Example: User Registry (~/.config/nix/registry.json)

```json
{
  "version": 2,
  "flakes": [
    {
      "from": {
        "type": "indirect",
        "id": "kalilix"
      },
      "to": {
        "type": "path",
        "path": "/home/usrbinkat/.kalilix"
      }
    },
    {
      "from": {
        "type": "indirect",
        "id": "mynixpkgs"
      },
      "to": {
        "type": "github",
        "owner": "myusername",
        "repo": "nixpkgs",
        "ref": "my-custom-branch"
      }
    },
    {
      "from": {
        "type": "indirect",
        "id": "unstable"
      },
      "to": {
        "type": "github",
        "owner": "NixOS",
        "repo": "nixpkgs",
        "ref": "nixos-unstable"
      }
    }
  ]
}
```

## Example: System Registry (/etc/nix/registry.json)

```json
{
  "version": 2,
  "flakes": [
    {
      "from": {
        "type": "indirect",
        "id": "companylib"
      },
      "to": {
        "type": "gitlab",
        "owner": "mycompany",
        "repo": "internal-nix-lib"
      }
    },
    {
      "from": {
        "type": "indirect",
        "id": "stable"
      },
      "to": {
        "type": "github",
        "owner": "NixOS",
        "repo": "nixpkgs",
        "ref": "nixos-24.05"
      }
    }
  ]
}
```

## Practical Development Workflows

### 1. Local Development with Registry

```bash
# Add your local project to registry
nix registry add kalilix path:/home/usrbinkat/.kalilix

# Now you can use it from anywhere
cd /tmp
nix develop kalilix#full
nix run kalilix#sometool
```

### 2. Testing Local Nixpkgs Fork

```bash
# Temporarily override nixpkgs to test local changes
nix build nixpkgs#hello \
  --override-flake nixpkgs /home/usrbinkat/projects/nixpkgs

# Or add it to registry for repeated use
nix registry add mynixpkgs path:/home/usrbinkat/projects/nixpkgs
nix build mynixpkgs#hello
```

### 3. Pin for Reproducibility

```bash
# Pin nixpkgs to exact commit for reproducibility
nix registry pin nixpkgs github:NixOS/nixpkgs/a1b2c3d4...

# Now all uses of 'nixpkgs' reference this exact commit
nix shell nixpkgs#hello
```

### 4. Multiple Nixpkgs Versions

```bash
# Set up shortcuts for different nixpkgs versions
nix registry add stable github:NixOS/nixpkgs/nixos-24.05
nix registry add unstable github:NixOS/nixpkgs/nixos-unstable
nix registry add master github:NixOS/nixpkgs/master

# Use specific versions
nix shell stable#hello      # From 24.05
nix shell unstable#firefox  # From unstable
nix shell master#neovim     # From master
```

## Registry Matching & Unification Rules

### Matching Examples

| Registry Entry | Flake Reference | Matches? |
|----------------|-----------------|----------|
| `nixpkgs` | `nixpkgs` | ✅ Yes |
| `nixpkgs` | `nixpkgs/nixos-23.11` | ✅ Yes |
| `nixpkgs/nixos-23.11` | `nixpkgs` | ❌ No (from is more specific) |
| `nixpkgs` | `github:NixOS/nixpkgs` | ❌ No (different types) |

### Unification Examples

When a match is found, the `to` reference is unified with attributes from the input:

| Registry To | Input Reference | Result |
|-------------|-----------------|--------|
| `github:NixOS/nixpkgs` | `nixpkgs` | `github:NixOS/nixpkgs` |
| `github:NixOS/nixpkgs` | `nixpkgs/nixos-23.11` | `github:NixOS/nixpkgs/nixos-23.11` |
| `github:NixOS/nixpkgs/master` | `nixpkgs/nixos-23.11` | `github:NixOS/nixpkgs/nixos-23.11` |

The ref/rev from the input **overrides** the ref/rev from the registry.

## Common Patterns for Kalilix Development

### Pattern 1: Quick Project Access

```bash
# Add kalilix to registry once
nix registry add kalilix path:/home/usrbinkat/.kalilix

# Use from anywhere
cd /tmp
nix develop kalilix#full
nix develop kalilix#python
nix develop kalilix#go
```

### Pattern 2: Private GitHub Repos

```json
{
  "flakes": [
    {
      "from": { "type": "indirect", "id": "private-tools" },
      "to": {
        "type": "github",
        "owner": "myorg",
        "repo": "private-nix-tools"
      }
    }
  ]
}
```

Then set access token in nix.conf:
```bash
access-tokens = github.com=ghp_yourPersonalAccessToken
```

### Pattern 3: Redirect All Nixpkgs to Local Cache

```json
{
  "flakes": [
    {
      "from": {
        "type": "github",
        "owner": "NixOS",
        "repo": "nixpkgs"
      },
      "to": {
        "type": "github",
        "owner": "NixOS",
        "repo": "nixpkgs"
      }
    }
  ]
}
```

Combined with:
```bash
# In nix.conf
substituters = https://my-company-cache.example.com https://cache.nixos.org
```

## Debugging Registry Issues

```bash
# Show exactly what a flake reference resolves to
nix flake metadata nixpkgs
nix flake metadata kalilix

# Show full registry resolution chain
nix registry list | grep -A2 nixpkgs

# Test without registry (force full URLs)
nix build github:NixOS/nixpkgs#hello --no-registries

# Clear flake caches if something seems stuck
rm -rf ~/.cache/nix/flake-registry.json
nix registry list  # Will re-download
```

## Security Considerations

1. **User Registry** - Safe, only affects your user
2. **System Registry** - Requires sudo, affects all users
3. **Global Registry** - Downloaded from internet, verify source
4. **accept-flake-config** - ⚠️ Never enable unless you trust ALL flakes

### Verifying Registry Sources

```bash
# Check what a registry entry actually points to
nix flake metadata nixpkgs --json | jq .url

# Verify global registry source
grep flake-registry /etc/nix/nix.conf

# Check for suspicious redirects
nix registry list | grep -E '(github|gitlab|path)'
```

## Resources

- Official Lix docs: https://lix.systems/manual/lix/stable/
- Nix Registry Command: `nix registry --help`
- Flake Schema: `nix flake --help`
