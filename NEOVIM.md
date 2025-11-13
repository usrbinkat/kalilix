# Neovim Development Environment

**A highly-optimized, reproducible Neovim configuration built with nixvim for Kalilix**

---

## Overview

The Kalilix Neovim shell provides a **fully-configured, immutable Neovim environment** with 10 LSP servers, intelligent completion, auto-formatting, Git integration, and performance optimizations. Built using [nixvim](https://nix-community.github.io/nixvim), it delivers a consistent editor experience across all platforms without manual configuration.

### Key Features

- **10 Language Servers**: Nix, Lua, Bash, YAML, Markdown, JSON, Python, Go, Rust, TypeScript/JavaScript
- **Intelligent Completion**: nvim-cmp with LSP, snippets, path, and buffer sources
- **Auto-Formatting**: 11 formatters with format-on-save
- **Git Integration**: gitsigns, fugitive, diffview, lazygit
- **Lazy Loading**: 5 plugins load on-demand for **73ms startup time** (55% faster than baseline)
- **Performance Optimized**: Byte-compiled Lua + plugin combining
- **Developer Tools**: HTTP client (rest.nvim), markdown preview, integrated terminal
- **Command Discovery**: which-key for keybinding help

---

## Quick Start

### Access the Neovim Shell

```bash
# From Kalilix root
nix develop .#neovim

# Or remotely
nix develop github:usrbinkat/kalilix#neovim

# Launch Neovim
nvim
```

### First-Time Experience

```
╔══════════════════════════════════════════════╗
║     🚀 Kalilix Development Environment        ║
║              Neovim Shell                     ║
╚══════════════════════════════════════════════╝

📝 Neovim Development Environment
   Launch: nvim
   Config: nixvim-managed (immutable)
   LSP: Python, Go, Rust, Node, Nix, Bash, YAML, JSON, Markdown, Lua
   Features: Completion, Snippets, Auto-format on save
   Git: gitsigns, fugitive, diffview, lazygit
   Tools: toggleterm, rest.nvim, markdown-preview, which-key

Loaded 10 runtime files
```

### Performance

- **Startup Time**: 73.979ms (target: <100ms)
- **Improvement**: 55.2% faster than pre-optimization (164ms baseline)
- **Lazy Loading**: 5 plugins load only when needed
- **Byte Compilation**: Lua code precompiled for faster execution

---

## Terminology & Key Concepts

### Leader Key

The **leader key** is `<Space>` (spacebar) - a special prefix key that opens up hundreds of commands.

**How it works:**
1. Press `<Space>` (leader key)
2. Press a second key (e.g., `t` for terminal, `f` for find, `g` for git)
3. Optionally press a third key for specific actions (e.g., `<Space>tt` = toggle terminal)

**Example:** To open a terminal:
- Press `<Space>` (you'll see which-key popup after 500ms)
- Press `t` (shows terminal options)
- Press `t` again (toggles terminal)

### Keybinding Notation

| Notation | Meaning | Example |
|----------|---------|---------|
| `<Space>` | Spacebar (leader key) | `<Space>tt` = Space, then t, then t |
| `<leader>` | Alias for `<Space>` | `<leader>tt` = same as `<Space>tt` |
| `<C-x>` | Ctrl + x | `<C-\>` = Ctrl + backslash |
| `<S-x>` | Shift + x | `<S-Tab>` = Shift + Tab |
| `<CR>` | Enter/Return key | Confirm action |
| `<Esc>` | Escape key | Exit mode |

### Vim Modes

Neovim has different modes for different tasks:

| Mode | Purpose | Enter Via | Exit Via |
|------|---------|-----------|----------|
| **Normal** | Navigate and run commands | `<Esc>` or `jk` | (default mode) |
| **Insert** | Type/edit text | `i`, `a`, `o` | `<Esc>` or `jk` |
| **Visual** | Select text | `v`, `V` | `<Esc>` |
| **Terminal** | Interact with shell | `<Space>tt` | `<Esc>` or `jk` |
| **Command** | Run ex commands | `:` | `<CR>` or `<Esc>` |

**Quick tip:** The `jk` keybinding (type j then k quickly) is a fast alternative to `<Esc>` for exiting insert/terminal mode.

---

## Architecture

### nixvim Integration

Kalilix uses **nixvim** to declaratively configure Neovim entirely through Nix:

```nix
nixvimPkgs.makeNixvim {
  colorschemes.catppuccin = { /* ... */ };
  opts = { /* vim options */ };
  keymaps = [ /* keybindings */ ];
  plugins = { /* plugin configuration */ };
  performance = { /* optimizations */ };
}
```

**Benefits:**
- **Immutable**: Configuration cannot be changed at runtime
- **Reproducible**: Same environment on every machine
- **Validated**: Build fails if configuration is invalid
- **Version-Controlled**: All changes tracked in Git

### Lazy Loading Strategy

Uses **lz.n** (lazy loading provider) to defer plugin initialization:

| Plugin | Trigger | Purpose |
|--------|---------|---------|
| **gitsigns** | BufReadPre, BufNewFile | Git status in sign column |
| **fugitive** | :Git, :G commands | Git operations UI |
| **diffview** | :DiffviewOpen, :DiffviewFileHistory | Git diff visualization |
| **rest.nvim** | .http files | HTTP request execution |
| **markdown-preview** | .md files, :MarkdownPreview | Live markdown preview |

**Core plugins** load immediately: telescope, lualine, treesitter, neo-tree, nvim-cmp, LSP

### Performance Optimizations

**Byte Compilation:**
```nix
performance.byteCompileLua = {
  enable = true;
  initLua = true;      # Compile initialization
  configs = true;      # Compile config files
  plugins = true;      # Compile plugin Lua
  nvimRuntime = false; # Skip neovim runtime (avoid issues)
};
```

**Plugin Combining:**
```nix
performance.combinePlugins = {
  enable = true;
  standalonePlugins = [
    "nvim-treesitter"  # Excluded (too many parsers)
  ];
};
```

---

## Language Server Protocol (LSP)

### Configured Servers

| Language | Server | Features |
|----------|--------|----------|
| **Nix** | nil_ls | Formatting (nixpkgs-fmt), diagnostics |
| **Lua** | lua_ls | Neovim-aware completion, telemetry disabled |
| **Bash** | bashls | Shell script analysis |
| **YAML** | yamlls | Schema validation |
| **Markdown** | marksman | Link checking, TOC |
| **JSON** | jsonls | Schema validation |
| **Python** | pyright | Type checking (basic mode) |
| **Go** | gopls | Go toolchain integration |
| **Rust** | rust_analyzer | Uses system cargo/rustc |
| **TypeScript/JS** | ts_ls | JavaScript + TypeScript |

### LSP Keybindings

| Key | Action | Description |
|-----|--------|-------------|
| `gd` | Go to definition | Jump to symbol definition |
| `gr` | Find references | List all references |
| `gI` | Go to implementation | Jump to implementation |
| `gy` | Go to type definition | Jump to type |
| `K` | Hover documentation | Show docs under cursor |
| `<leader>ca` | Code actions | Apply available fixes |
| `<leader>rn` | Rename symbol | Rename across project |
| `<leader>lf` | Format buffer | Format with LSP/formatters |
| `<leader>li` | LSP info | Show active servers |
| `<leader>lr` | LSP restart | Restart language server |

### Diagnostics Navigation

| Key | Action |
|-----|--------|
| `<leader>j` | Next diagnostic |
| `<leader>k` | Previous diagnostic |

---

## Code Completion

### nvim-cmp Configuration

**Sources (in priority order):**
1. `nvim_lsp` - Language server completions
2. `luasnip` - Snippet expansions
3. `path` - File path completions
4. `buffer` - Words from current buffer

### Completion Keybindings

| Key | Action |
|-----|--------|
| `<C-Space>` | Trigger completion |
| `<CR>` | Confirm selection |
| `<Tab>` | Next item |
| `<S-Tab>` | Previous item |
| `<C-d>` | Scroll docs down |
| `<C-f>` | Scroll docs up |
| `<C-e>` | Close completion menu |

### Snippets

Uses **LuaSnip** with **friendly-snippets** collection for common patterns across languages.

---

## Auto-Formatting

### conform-nvim Configuration

Format-on-save enabled with 500ms timeout, LSP fallback if no formatter configured.

| Language | Formatters |
|----------|-----------|
| **Nix** | nixpkgs-fmt |
| **Python** | black, isort |
| **Rust** | rustfmt |
| **Go** | gofmt, goimports |
| **JavaScript/TypeScript** | prettier |
| **Markdown** | prettier |
| **YAML** | prettier |
| **JSON** | prettier |
| **Bash/Shell** | shfmt |

**Manual formatting:**
```
<leader>lf
```

---

## Fuzzy Finding (Telescope)

### Keybindings

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>ff` | Find files | Search files by name |
| `<leader>fg` | Live grep | Search content with ripgrep |
| `<leader>fb` | Buffers | List open buffers |
| `<leader>fh` | Help tags | Search Neovim help |

### Dependencies

- **ripgrep**: Powers live_grep
- **fd**: Powers find_files

---

## Git Integration

### gitsigns (Lazy Loaded)

**Features:**
- Inline git status indicators (signs in gutter)
- Current line blame (virtual text at EOL)
- Stage/unstage hunks inline

**Visual indicators:**
- `│` Added line
- `│` Changed line
- `_` Deleted line
- `‾` Top delete
- `~` Change+delete
- `┆` Untracked

### vim-fugitive (Lazy Loaded)

**Commands:**
```vim
:Git         " Git status interface
:Git commit  " Commit changes
:Git push    " Push to remote
:Git pull    " Pull from remote
:Git blame   " View blame
```

**Keybindings:**
| Key | Action |
|-----|--------|
| `<leader>gs` | Git status |
| `<leader>gc` | Git commit |
| `<leader>gp` | Git push |

### diffview.nvim (Lazy Loaded)

**Commands:**
```vim
:DiffviewOpen              " Open diff view
:DiffviewFileHistory       " File history
:DiffviewFileHistory %     " Current file history
```

**Keybindings:**
| Key | Action |
|-----|--------|
| `<leader>gd` | Git diff view |
| `<leader>gh` | Git file history |

### lazygit Integration

**Keybinding:**
```
<leader>tg
```

Opens **lazygit** in a floating terminal window for comprehensive Git TUI.

---

## Terminal Integration (toggleterm)

Kalilix provides a **fully-integrated terminal** inside Neovim with arrow key support, command history, and ergonomic keybindings. The terminal uses `rlwrap` to provide readline functionality in neovim's libvterm PTY environment.

### Opening the Terminal

**Via Leader Key (Recommended):**
1. Press `<Space>` (leader key)
2. Press `t` (terminal menu appears)
3. Press `t` for toggle, `f` for float, `h` for horizontal, or `v` for vertical

**Example:** `<Space>tt` = Toggle terminal

### Keybindings

#### Opening Terminal

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>tt` | Toggle terminal | Open/close terminal |
| `<leader>tf` | Float terminal | Open floating terminal window |
| `<leader>th` | Horizontal split | Open terminal in horizontal split |
| `<leader>tv` | Vertical split | Open terminal in vertical split |
| `<C-\>` | Toggle terminal | Alternative toggle (Ctrl + backslash) |

#### Terminal Mode Navigation

Once inside the terminal, these keybindings help you navigate:

| Key | Action | Description |
|-----|--------|-------------|
| `<Esc>` | Exit terminal mode | Return to normal mode (single key) |
| `jk` | Exit terminal mode | Fast alternative to Esc (type j then k) |
| `<C-h>` | Navigate left | Move to left window from terminal |
| `<C-j>` | Navigate down | Move to window below from terminal |
| `<C-k>` | Navigate up | Move to window above from terminal |
| `<C-l>` | Navigate right | Move to right window from terminal |

**Why `jk`?** Typing `jk` quickly is a common Vim pattern that's faster than reaching for Esc. It works in both insert mode (when editing files) and terminal mode (when in the shell).

### Arrow Key Support

The terminal has **full arrow key support** for command-line editing:

| Key | Action |
|-----|--------|
| `↑` (Up arrow) | Previous command in history |
| `↓` (Down arrow) | Next command in history |
| `←` (Left arrow) | Move cursor left |
| `→` (Right arrow) | Move cursor right |
| `Home` | Jump to beginning of line |
| `End` | Jump to end of line |
| `Delete` | Delete character under cursor |

### Shell Configuration

The terminal runs **Nix bash 5.2+** (not macOS system bash 3.2) with a custom immutable bashrc:

**Features:**
- **Colored prompt** with username, hostname, and current directory
- **Mise prevention** (avoids infinite loop in nested shells)
- **Raw ANSI codes** (compatible with neovim's libvterm)
- **Deterministic** (configuration in Nix store, version controlled)

### Technical Implementation

**The readline problem:** Neovim's terminal uses libvterm, which only understands ANSI escape sequences. Bash's built-in readline doesn't work properly in this environment, breaking arrow keys.

**The solution:** `rlwrap` (readline wrapper) sits between libvterm and bash, providing readline functionality externally:

```
neovim → libvterm → rlwrap → bash (Nix 5.2) → custom bashrc
```

This architecture ensures:
- ✅ Arrow keys work for command history and navigation
- ✅ No job control conflicts (no `-i` flag needed)
- ✅ Full compatibility with libvterm
- ✅ Immutable, reproducible configuration via Nix

### Features

- **Floating windows** with curved borders
- **Multiple terminals** (numbered instances 1-9)
- **Persistent sessions** across toggles
- **Working directory** respects current buffer location
- **lazygit integration** via custom terminal (`<Space>tg`)
- **Full command-line editing** with arrow keys, history, and readline

### Common Workflows

**Quick command execution:**
```
<Space>tt           # Open terminal
ls -la              # Run command (arrow keys work!)
<Esc> or jk         # Exit terminal mode
<Space>tt           # Close terminal
```

**Persistent terminal session:**
```
<Space>tf           # Open floating terminal
cd ~/project        # Change directory
<Esc>               # Exit terminal mode
<C-o>               # Do something else in Neovim
<Space>tt           # Return to same terminal (session persists)
```

**Multi-terminal workflow:**
```
<Space>th           # Horizontal terminal (terminal 1)
npm run dev         # Start dev server
<C-k>               # Navigate up to editor
<Space>tv           # Vertical terminal (terminal 2)
git status          # Check git status
<Esc>               # Exit terminal mode
```

### Troubleshooting

**Arrow keys showing `^[[A^[[B`:**
- Rebuild the flake to ensure rlwrap is included: `nix develop .#neovim --impure`
- Check rlwrap is available: `which rlwrap` (should show Nix store path)

**Terminal exits immediately:**
- This can happen if bash flags conflict - the rlwrap solution prevents this

**Colors look wrong:**
- The bashrc uses raw ANSI codes compatible with libvterm
- Starship prompt (from host shell) is disabled in terminal

---

## HTTP Client (rest.nvim)

### Usage

1. Create `.http` file (auto-loads rest.nvim via lazy loading):

```http
### Basic GET request
GET https://api.github.com/users/octocat

### POST with JSON body
POST https://httpbin.org/post
Content-Type: application/json

{
  "name": "test",
  "value": 123
}

### Request with headers
GET https://api.example.com/data
Authorization: Bearer YOUR_TOKEN
Accept: application/json
```

2. Execute request:

| Key | Action |
|-----|--------|
| `<leader>rr` | Run request under cursor |
| `<leader>rp` | Preview request |
| `<leader>rl` | Rerun last request |

### Features

- **Syntax highlighting** for .http files
- **Response in split window**
- **URL encoding** enabled
- **SSL verification** enabled by default

---

## Markdown Preview (markdown-preview.nvim)

### Usage

Open `.md` file (auto-loads markdown-preview):

| Key | Action |
|-----|--------|
| `<leader>mp` | Start preview |
| `<leader>ms` | Stop preview |

### Features

- **Dark theme** (matches catppuccin)
- **Auto-close** on buffer exit
- **System default browser**
- **Live refresh** on save

---

## File Explorer (neo-tree)

### Features

- **Git status** integration
- **LSP diagnostics** in tree
- **File icons** via nvim-web-devicons

### Navigation

Open with `:Neotree` or configure custom keybinding.

---

## Command Discovery (which-key)

### Features

- **Auto-popup** after 500ms of waiting
- **Hierarchical display** of available commands
- **Leader key groups** clearly organized

Press `<leader>` and wait to see available commands:

```
+lsp     LSP operations
+t       Terminal operations
+g       Git operations
+r       REST/HTTP client
+m       Markdown tools
+f       Fuzzy finding
```

---

## Appearance

### Colorscheme: Catppuccin Mocha

**Dark theme optimized for security/development work.**

**UI Elements:**
- **Status line**: lualine with catppuccin theme
- **Cursor line**: Highlighted current line
- **Sign column**: Always visible for git/diagnostics
- **True color**: 24-bit color support

### Font Requirements

No specific font required, but **Nerd Fonts** recommended for icons:
- FiraCode Nerd Font
- JetBrains Mono Nerd Font
- Hack Nerd Font

---

## Essential Keybindings

### Leader Key: `<Space>`

### Core Operations

| Key | Action |
|-----|--------|
| `<leader>w` | Save file |
| `<leader>q` | Quit window |
| `<Esc>` | Clear search highlight |

### Navigation

| Key | Action |
|-----|--------|
| `<leader>j` | Next diagnostic |
| `<leader>k` | Previous diagnostic |

### Prefixes

- `<leader>f*` - **Find** (telescope)
- `<leader>l*` - **LSP** operations
- `<leader>g*` - **Git** operations
- `<leader>t*` - **Terminal** operations
- `<leader>r*` - **REST** client
- `<leader>m*` - **Markdown** tools

---

## Customization

### Immutable by Design

The Neovim configuration is **immutable** - you cannot modify it at runtime. This ensures:

- **Reproducibility**: Same config everywhere
- **Stability**: No accidental changes
- **Version control**: All changes tracked

### Adding Packages

Edit `modules/devshells/neovim.nix`:

```nix
plugins = {
  # Add new plugin
  your-plugin = {
    enable = true;
    settings = {
      /* plugin options */
    };
  };
};
```

Rebuild:
```bash
nix develop .#neovim
```

### Adding Keybindings

```nix
keymaps = [
  {
    mode = "n";  # normal mode
    key = "<leader>x";
    action = "<cmd>YourCommand<cr>";
    options.desc = "Description";
  }
];
```

### Adding LSP Servers

```nix
lsp.servers = {
  your_lsp = {
    enable = true;
    settings = {
      /* server config */
    };
  };
};
```

---

## Dependencies

The Neovim shell automatically includes:

### Editor Dependencies

- **neovim** - Text editor (nixvim-built)
- **ripgrep** - Fast search (telescope)
- **fd** - Fast find (telescope)

### Language Server Binaries

Included automatically by nixvim LSP module:
- nil (Nix)
- lua-language-server
- bash-language-server
- yaml-language-server
- marksman (Markdown)
- vscode-langservers-extracted (JSON)
- pyright
- gopls
- rust-analyzer
- typescript-language-server

### Formatters

- **nixpkgs-fmt** - Nix
- **black** - Python
- **isort** - Python imports
- **rustfmt** - Rust
- **go** - Go (includes gofmt/goimports)
- **nodePackages.prettier** - Multi-language
- **shfmt** - Shell

### Additional Tools

- **lazygit** - Git TUI

---

## Troubleshooting

### LSP Not Working

**Check server status:**
```vim
:LspInfo
```

**Restart LSP:**
```
<leader>lr
```

**Check logs:**
```vim
:messages
```

### Slow Startup

**Benchmark startup:**
```bash
nvim --startuptime /tmp/startup.txt
tail /tmp/startup.txt
```

**Expected:** ~74ms

**If slower:**
- Check for additional vimrc files
- Verify lazy loading is enabled (`:lua print(vim.inspect(require('lazy').plugins()))`)

### Lazy-Loaded Plugin Not Loading

**Check lz.n configuration:**
```vim
:lua print(vim.inspect(require('lz.n').plugins))
```

**Manual trigger:**
- gitsigns: Open a file in a git repo
- fugitive: Run `:Git`
- diffview: Run `:DiffviewOpen`
- rest.nvim: Open a `.http` file
- markdown-preview: Open a `.md` file

### Formatter Not Working

**Check conform status:**
```vim
:ConformInfo
```

**Available formatters:**
```vim
:lua print(vim.inspect(require('conform').list_formatters()))
```

### Completion Not Appearing

**Check cmp sources:**
```vim
:lua print(vim.inspect(require('cmp').get_config().sources))
```

**Retrigger manually:**
```
<C-Space>
```

---

## Performance Benchmarks

### Startup Time Progression

| Phase | Time (ms) | Improvement |
|-------|-----------|-------------|
| Pre-optimization | 164.898 | Baseline |
| Phase 4 (lazy loading + byte compile) | 73.979 | 55.2% faster |

### Runtime File Loading

**Before optimization:** Unknown (baseline)
**After optimization:** 10 files

### Plugin Loading

**Immediate load (startup):**
- catppuccin (colorscheme)
- lualine (status line)
- telescope (fuzzy finder)
- treesitter (syntax)
- neo-tree (file explorer)
- nvim-cmp (completion)
- lsp (language servers)
- which-key (command discovery)

**Lazy load (on-demand):**
- gitsigns (on file open)
- fugitive (on :Git command)
- diffview (on :Diffview command)
- rest.nvim (on .http file)
- markdown-preview (on .md file)

---

## Advanced Configuration

### Using in Other Shells

The Neovim configuration is available in **all Kalilix shells**:

```bash
# From Python shell
nix develop .#python
nvim  # Uses same neovim config

# From DevOps shell
nix develop .#devops
nvim  # Same config

# Set as default editor
export EDITOR=nvim
export VISUAL=nvim
```

Already configured in neovim shell via `env`:

```nix
env = {
  EDITOR = "nvim";
  VISUAL = "nvim";
};
```

### Integrating with Full Shell

The full polyglot shell includes Neovim:

```bash
nix develop .#full
```

All language servers work with their respective toolchains.

### Standalone Neovim Package

The Neovim configuration is exported as a standalone package:

```nix
# In modules/devshells/neovim.nix
{
  neovim-pkg = nixvimConfig;  # Standalone Neovim package
  neovim-packages = [ nixvimConfig ];  # For shell integration
}
```

Import in other Nix configurations:

```nix
let
  kalilix = import ./path/to/kalilix;
in {
  home.packages = [ kalilix.neovim-pkg ];
}
```

---

## Technical Implementation

### Module Structure

```
modules/devshells/
├── default.nix    # Shell definitions, includes neovim shell
└── neovim.nix     # nixvim configuration (431 lines)
```

### nixvim Configuration Sections

**neovim.nix breakdown:**

1. **Core Options** (lines 13-42): Vim settings, UI, performance
2. **Keymaps** (lines 48-83): All keybindings
3. **Core Plugins** (lines 85-123): Essential plugins (always loaded)
4. **LSP Configuration** (lines 125-192): Language servers
5. **Completion** (lines 194-217): nvim-cmp + sources
6. **Snippets** (lines 219-225): LuaSnip
7. **Formatting** (lines 227-249): conform-nvim
8. **Terminal** (lines 251-263): toggleterm
9. **Git Integration** (lines 265-297): gitsigns, fugitive, diffview
10. **HTTP Client** (lines 299-312): rest.nvim
11. **Markdown** (lines 314-325): markdown-preview
12. **Discovery** (lines 327-342): which-key
13. **Lazy Loading** (lines 344-370): lz-n provider
14. **Performance** (lines 373-392): Byte compilation + combining
15. **Lua Config** (lines 394-420): Custom integrations (lazygit, startup measurement)

### Lazy Loading Implementation

**Dual approach:**

1. **Native nixvim lazyLoad** (gitsigns):
```nix
gitsigns = {
  enable = true;
  lazyLoad = {
    enable = true;
    settings = {
      event = [ "BufReadPre" "BufNewFile" ];
    };
  };
};
```

2. **Manual lz-n configuration** (fugitive, diffview, rest, markdown-preview):
```nix
lz-n = {
  enable = true;
  plugins = [
    {
      __unkeyed-1 = "vim-fugitive";
      cmd = [ "Git" "G" ];
    }
    /* ... */
  ];
};
```

**Reason:** Not all nixvim plugins support native lazyLoad yet. Manual lz-n provides fallback.

---

## Best Practices

### When to Use Neovim Shell

**Ideal for:**
- Editing Nix configurations
- Writing documentation (Markdown)
- API testing (.http files)
- Git operations
- Quick edits across multiple languages

**Consider language-specific shells for:**
- Python projects (use `#python` for virtual environment)
- Go projects (use `#go` for GOPATH setup)
- Rust projects (use `#rust` for cargo integration)

**Neovim works in all shells**, but language shells provide additional tooling.

### Workflow Recommendations

**Configuration editing:**
```bash
nix develop .#neovim
nvim flake.nix  # LSP works (nil_ls)
```

**Documentation writing:**
```bash
nix develop .#neovim
nvim README.md  # Markdown LSP + preview
<leader>mp      # Live preview in browser
```

**API testing:**
```bash
nix develop .#neovim
nvim requests.http  # rest.nvim loads
<leader>rr          # Execute request
```

**Git operations:**
```bash
nix develop .#neovim
nvim .            # Open file explorer
<leader>tg        # Launch lazygit
```

---

## Comparison with Traditional Setups

### vs Manual Neovim Configuration

| Aspect | Traditional | Kalilix nixvim |
|--------|-------------|----------------|
| **Setup time** | Hours of configuration | Instant (`nix develop`) |
| **Reproducibility** | Manual sync across machines | Automatic (Nix) |
| **Plugin management** | Lazy.nvim / Packer | Nix (declarative) |
| **LSP installation** | Mason / manual | Automatic (nixvim) |
| **Updates** | Manual plugin updates | `nix flake update` |
| **Rollback** | Manual backup | `nix-env --rollback` |
| **Sharing** | Dotfiles repo | Nix flake |

### vs LazyVim / NvChad / AstroNvim

| Aspect | Distros | Kalilix nixvim |
|--------|---------|----------------|
| **Philosophy** | Opinionated starter | Kalilix-integrated |
| **Customization** | Lua overrides | Nix configuration |
| **Plugin source** | GitHub/Git | Nix packages |
| **Platform support** | Universal Neovim | Nix platforms |
| **Startup time** | ~100-200ms (lazy) | ~74ms (optimized) |
| **Isolation** | Global Neovim | Shell-specific |

---

## Future Enhancements

### Roadmap

**Phase 5 (Current):**
- [ ] Documentation (this file)
- [ ] Mise task integration (`mise run neovim`)
- [ ] Example configurations
- [ ] Troubleshooting guide

**Future Phases:**
- [ ] Additional language servers (Java, Ruby, etc.)
- [ ] DAP (Debug Adapter Protocol) integration
- [ ] AI completion (Copilot, Codeium)
- [ ] Custom snippets collection
- [ ] Project-local configuration overrides

### Contributing Enhancements

See Neovim configuration in `modules/devshells/neovim.nix`.

**Adding plugins:**
1. Add to `plugins = { }`
2. Configure keybindings in `keymaps = [ ]`
3. Consider lazy loading via `lz-n.plugins`
4. Test with `nix develop .#neovim`

**Testing changes:**
```bash
# Quick validation
nix flake check --impure

# Full build
nix develop .#neovim

# Startup benchmark
nvim --startuptime /tmp/startup.txt +qall
tail /tmp/startup.txt
```

---

## Resources

### nixvim Documentation

- [nixvim Home](https://nix-community.github.io/nixvim)
- [Plugin Reference](https://nix-community.github.io/nixvim/plugins)
- [Options Search](https://nix-community.github.io/nixvim/search)

### Plugin Documentation

- [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [LuaSnip](https://github.com/L3MON4D3/LuaSnip)
- [conform.nvim](https://github.com/stevearc/conform.nvim)
- [gitsigns](https://github.com/lewis6991/gitsigns.nvim)
- [fugitive](https://github.com/tpope/vim-fugitive)
- [diffview](https://github.com/sindrets/diffview.nvim)
- [rest.nvim](https://github.com/rest-nvim/rest.nvim)
- [markdown-preview](https://github.com/iamcco/markdown-preview.nvim)
- [which-key](https://github.com/folke/which-key.nvim)
- [lz.n](https://github.com/nvim-neorocks/lz.n)

---

## Summary

The Kalilix Neovim shell provides a **complete, optimized development editor** with:

- ✅ **10 LSP servers** across all major languages
- ✅ **Intelligent completion** with snippets and LSP
- ✅ **Auto-formatting** on save for 9 languages
- ✅ **Git integration** (inline status, TUI, diffs)
- ✅ **Developer tools** (HTTP client, markdown preview, terminal)
- ✅ **Performance optimized** (73ms startup, lazy loading)
- ✅ **Fully reproducible** via Nix
- ✅ **Immutable configuration** for consistency

**Access with:**
```bash
nix develop .#neovim
nvim
```

**Part of the Kalilix ecosystem** - works standalone or integrated with language shells.
