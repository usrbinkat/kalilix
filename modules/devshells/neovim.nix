{ pkgs
, lib
, inputs
, ...
}:
let
  # Import nixvim's package builder
  nixvimPkgs = inputs.nixvim.legacyPackages.${pkgs.system};

  # Shared bash configuration
  bashConfig = import ./bash-config.nix { inherit pkgs; };

  # Define nixvim configuration
  nixvimConfig = nixvimPkgs.makeNixvim {
    # Use catppuccin colorscheme matching tmux
    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "macchiato"; # Matches tmux theme
    };

    # Essential options
    opts = {
      # Line numbers
      number = true;
      relativenumber = true;
      signcolumn = "yes";

      # Indentation
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;

      # Search
      ignorecase = true;
      smartcase = true;

      # UI
      termguicolors = true;
      cursorline = true;

      # Performance
      updatetime = 250;
      timeoutlen = 300;

      # ============================================
      # Terminal Configuration
      # ============================================

      # Shell settings
      # CRITICAL: Use Nix bash (5.2+), not ancient macOS system bash (3.2)
      shell = "${pkgs.bash}/bin/bash"; # Shell to use for :! commands and terminal
      shellcmdflag = "-c"; # Flag to execute command
      shellquote = ""; # Quoting for shell commands
      shellxquote = ""; # Extended quoting for shell commands
      shellpipe = "2>&1| tee"; # Pipe command for :make
      shellredir = ">%s 2>&1"; # Redirection for :make

      # Terminal behavior
      splitbelow = true; # Open horizontal splits below
      splitright = true; # Open vertical splits right

      # Terminal scrollback
      scrollback = 10000; # Lines of scrollback in terminal

      # Terminal title
      title = true; # Set terminal title
      titlestring = "nvim - %f"; # Terminal title format

      # Mouse support in terminal
      mouse = "a"; # Enable mouse in all modes
    };

    # Leader key
    globals.mapleader = " ";
    globals.maplocalleader = " ";

    # ============================================
    # Terminal Environment
    # ============================================
    globals.nvim_terminal = 1; # Indicate we're in neovim (for shell config detection)

    # Essential keymaps
    keymaps = [
      # Save
      { mode = "n"; key = "<leader>w"; action = "<cmd>w<cr>"; options.desc = "Save"; }
      # Quit
      { mode = "n"; key = "<leader>q"; action = "<cmd>q<cr>"; options.desc = "Quit"; }
      # Clear search highlight
      { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<cr>"; }

      # Exit insert mode with jk (consistent with terminal mode)
      { mode = "i"; key = "jk"; action = "<Esc>"; options.desc = "Exit insert mode"; }

      # LSP keymaps
      { mode = "n"; key = "<leader>lf"; action = "<cmd>lua vim.lsp.buf.format()<cr>"; options.desc = "Format buffer"; }
      { mode = "n"; key = "<leader>li"; action = "<cmd>LspInfo<cr>"; options.desc = "LSP Info"; }
      { mode = "n"; key = "<leader>lr"; action = "<cmd>LspRestart<cr>"; options.desc = "LSP Restart"; }

      # ============================================
      # Terminal Keymaps
      # ============================================

      # Toggle terminals with different directions
      { mode = "n"; key = "<leader>tt"; action = "<cmd>ToggleTerm<cr>"; options.desc = "Toggle terminal"; }
      { mode = "n"; key = "<leader>tf"; action = "<cmd>ToggleTerm direction=float<cr>"; options.desc = "Float terminal"; }
      { mode = "n"; key = "<leader>th"; action = "<cmd>ToggleTerm direction=horizontal<cr>"; options.desc = "Horizontal terminal"; }
      { mode = "n"; key = "<leader>tv"; action = "<cmd>ToggleTerm direction=vertical<cr>"; options.desc = "Vertical terminal"; }

      # Terminal mode navigation (navigate windows from terminal mode)
      { mode = "t"; key = "<C-h>"; action = "<cmd>wincmd h<cr>"; options.desc = "Move to left window"; }
      { mode = "t"; key = "<C-j>"; action = "<cmd>wincmd j<cr>"; options.desc = "Move to below window"; }
      { mode = "t"; key = "<C-k>"; action = "<cmd>wincmd k<cr>"; options.desc = "Move to above window"; }
      { mode = "t"; key = "<C-l>"; action = "<cmd>wincmd l<cr>"; options.desc = "Move to right window"; }

      # Terminal mode escape (double Esc to exit terminal mode)
      { mode = "t"; key = "<Esc><Esc>"; action = "<C-\\><C-n>"; options.desc = "Exit terminal mode"; }

      # Git keymaps
      { mode = "n"; key = "<leader>gs"; action = "<cmd>Git<cr>"; options.desc = "Git status"; }
      { mode = "n"; key = "<leader>gc"; action = "<cmd>Git commit<cr>"; options.desc = "Git commit"; }
      { mode = "n"; key = "<leader>gp"; action = "<cmd>Git push<cr>"; options.desc = "Git push"; }
      { mode = "n"; key = "<leader>gd"; action = "<cmd>DiffviewOpen<cr>"; options.desc = "Git diff"; }
      { mode = "n"; key = "<leader>gh"; action = "<cmd>DiffviewFileHistory<cr>"; options.desc = "Git history"; }

      # HTTP client keymaps
      { mode = "n"; key = "<leader>rr"; action = "<Plug>RestNvim"; options.desc = "Run HTTP request"; }
      { mode = "n"; key = "<leader>rp"; action = "<Plug>RestNvimPreview"; options.desc = "Preview HTTP request"; }
      { mode = "n"; key = "<leader>rl"; action = "<Plug>RestNvimLast"; options.desc = "Rerun last HTTP request"; }

      # Markdown preview keymaps
      { mode = "n"; key = "<leader>mp"; action = "<cmd>MarkdownPreview<cr>"; options.desc = "Markdown preview"; }
      { mode = "n"; key = "<leader>ms"; action = "<cmd>MarkdownPreviewStop<cr>"; options.desc = "Stop preview"; }

      # ClaudeCode keymaps
      { mode = "n"; key = "<leader>cc"; action = "<cmd>ClaudeCodeStart<cr>"; options.desc = "Start Claude Code"; }
      { mode = "n"; key = "<leader>cs"; action = "<cmd>ClaudeCodeStatus<cr>"; options.desc = "Claude Code Status"; }
      { mode = "n"; key = "<leader>cq"; action = "<cmd>ClaudeCodeStop<cr>"; options.desc = "Stop Claude Code"; }
    ];

    # ============================================
    # Terminal Autocommands
    # ============================================
    autoCmd = [
      # Configure terminal buffers when opened
      {
        event = "TermOpen";
        pattern = "*";
        callback.__raw = ''
          function()
            -- Disable line numbers in terminal
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.signcolumn = "no"

            -- Set terminal-specific keymaps
            vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], { buffer = true, desc = "Exit terminal mode" })
          end
        '';
      }

      # Cleanup when terminal closes
      {
        event = "TermClose";
        pattern = "*";
        callback.__raw = ''
          function()
            -- Cleanup when terminal closes
            vim.cmd("bdelete!")
          end
        '';
      }
    ];

    # Core plugins
    plugins = {
      # File icons (required by telescope and neo-tree)
      web-devicons.enable = true;

      # Status line
      lualine = {
        enable = true;
        settings.options = {
          theme = "catppuccin";
          # Rounded separators to match tmux
          component_separators = {
            left = "";
            right = "";
          };
          section_separators = {
            left = "";
            right = "";
          };
        };
      };

      # Fuzzy finder
      telescope = {
        enable = true;
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";
        };
      };

      # Syntax highlighting
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };

      # File tree
      neo-tree = {
        enable = true;
        settings = {
          enable_diagnostics = true;
          enable_git_status = true;
        };
      };

      # LSP configuration
      lsp = {
        enable = true;

        keymaps = {
          silent = true;
          diagnostic = {
            # Navigate diagnostics
            "<leader>j" = "goto_next";
            "<leader>k" = "goto_prev";
          };
          lspBuf = {
            # LSP actions
            gd = "definition";
            gr = "references";
            gI = "implementation";
            gy = "type_definition";
            K = "hover";
            "<leader>ca" = "code_action";
            "<leader>rn" = "rename";
          };
        };

        servers = {
          # Nix
          nil_ls = {
            enable = true;
            settings.formatting.command = [ "nixpkgs-fmt" ];
          };

          # Lua (for neovim config editing)
          lua_ls = {
            enable = true;
            settings.telemetry.enable = false;
          };

          # Bash
          bashls.enable = true;

          # YAML
          yamlls.enable = true;

          # Markdown
          marksman.enable = true;

          # JSON
          jsonls.enable = true;

          # Python
          pyright = {
            enable = true;
            settings.python.analysis.typeCheckingMode = "basic";
          };

          # Go
          gopls.enable = true;

          # Rust
          rust_analyzer = {
            enable = true;
            installCargo = false; # Use system cargo from rust shell
            installRustc = false; # Use system rustc from rust shell
          };

          # TypeScript/JavaScript
          ts_ls.enable = true;
        };
      };

      # Completion
      cmp = {
        enable = true;
        autoEnableSources = true;

        settings = {
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-e>" = "cmp.mapping.close()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          };

          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
        };
      };

      # Snippets
      luasnip = {
        enable = true;
        fromVscode = [
          { } # Load friendly-snippets
        ];
      };

      # Code formatting
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            nix = [ "nixpkgs_fmt" ];
            python = [ "black" "isort" ];
            rust = [ "rustfmt" ];
            go = [ "gofmt" "goimports" ];
            javascript = [ "prettier" ];
            typescript = [ "prettier" ];
            markdown = [ "prettier" ];
            yaml = [ "prettier" ];
            json = [ "prettier" ];
            bash = [ "shfmt" ];
            sh = [ "shfmt" ];
          };
          format_on_save = {
            lsp_fallback = true;
            timeout_ms = 500;
          };
        };
      };

      # Terminal integration
      toggleterm = {
        enable = true;

        settings = {
          # ============================================
          # Core Terminal Settings
          # ============================================

          # Size configuration (dynamic based on direction)
          size.__raw = ''
            function(term)
              if term.direction == "horizontal" then
                return 15
              elseif term.direction == "vertical" then
                return vim.o.columns * 0.4
              else
                return 20
              end
            end
          '';

          # Terminal behavior
          open_mapping = "[[<C-\\>]]"; # Ctrl-\ to toggle
          hide_numbers = true; # Hide line numbers in terminal
          shade_terminals = true; # Shade terminal windows
          shading_factor = 2; # Shading amount (1-3)
          start_in_insert = true; # Start in insert mode
          insert_mappings = true; # Apply mappings in insert mode
          terminal_mappings = true; # Apply mappings in terminal mode
          persist_size = true; # Remember terminal size
          persist_mode = true; # Remember last used mode

          # Direction (default behavior)
          direction = "float"; # 'float' | 'horizontal' | 'vertical' | 'tab'

          # Floating window settings
          float_opts = {
            border = "curved"; # 'single' | 'double' | 'shadow' | 'curved'
            width.__raw = ''
              function()
                return math.floor(vim.o.columns * 0.85)
              end
            '';
            height.__raw = ''
              function()
                return math.floor(vim.o.lines * 0.85)
              end
            '';
            winblend = 0; # Transparency (0-100)
            highlights = {
              border = "Normal";
              background = "Normal";
            };
          };

          # ============================================
          # Shell and Environment Configuration
          # ============================================

          # Shell to use in terminal - use wrapper script that launches Nix bash
          # The wrapper ensures bash auto-detects as interactive in the PTY
          shell = "${bashConfig.nvimTerminalBashWrapper}";

          # Environment variables for terminal
          env = {
            # Terminal type
            TERM = "xterm-256color";

            # Indicate we're in a neovim terminal
            NVIM.__raw = "vim.v.servername";
            NVIM_TERMINAL = "1";
            TERM_PROGRAM = "nvim";

            # Preserve important environment
            PATH.__raw = "vim.env.PATH";
            HOME.__raw = "vim.env.HOME";
            USER.__raw = "vim.env.USER";
          };

          # ============================================
          # Auto Commands
          # ============================================

          on_open.__raw = ''
            function(term)
              -- Enter insert mode when opening terminal
              vim.cmd("startinsert!")

              -- Set local options for terminal buffer
              vim.opt_local.number = false
              vim.opt_local.relativenumber = false
              vim.opt_local.signcolumn = "no"
            end
          '';

          on_close.__raw = ''
            function(term)
              -- Cleanup when closing terminal
            end
          '';

          # ============================================
          # Highlights
          # ============================================

          highlights = {
            Normal = {
              link = "Normal";
            };
            NormalFloat = {
              link = "NormalFloat";
            };
            FloatBorder = {
              link = "FloatBorder";
            };
          };

          # ============================================
          # Auto Scroll
          # ============================================

          auto_scroll = true; # Auto scroll to bottom on output

          # ============================================
          # Close on Exit
          # ============================================

          close_on_exit = true; # Close terminal when process exits
        };
      };

      # Git integration
      gitsigns = {
        enable = true;
        lazyLoad = {
          enable = true;
          settings = {
            event = [ "BufReadPre" "BufNewFile" ];
          };
        };
        settings = {
          current_line_blame = true;
          current_line_blame_opts = {
            virt_text = true;
            virt_text_pos = "eol";
          };
          signs = {
            add = { text = "│"; };
            change = { text = "│"; };
            delete = { text = "_"; };
            topdelete = { text = "‾"; };
            changedelete = { text = "~"; };
            untracked = { text = "┆"; };
          };
        };
      };

      fugitive = {
        enable = true;
      };

      diffview = {
        enable = true;
      };

      # HTTP client for API testing
      rest = {
        enable = true;
        settings = {
          result_split_horizontal = false;
          result_split_in_place = false;
          skip_ssl_verification = false;
          encode_url = true;
          highlight = {
            enabled = true;
            timeout = 150;
          };
        };
      };

      # Markdown preview for documentation
      markdown-preview = {
        enable = true;
        settings = {
          theme = "dark";
          auto_start = 0;
          auto_close = 1;
          refresh_slow = 0;
          command_for_global = 0;
          browser = ""; # Uses system default
        };
      };

      # Command discovery
      which-key = {
        enable = true;
        settings = {
          delay = 500;
          icons = {
            breadcrumb = "»";
            separator = "➜";
            group = "+";
          };
          win = {
            border = "rounded";
            padding = [ 2 2 ];
          };
        };
      };

      # Lazy loading provider
      lz-n = {
        enable = true;
        plugins = [
          # Load vim-fugitive on Git commands
          {
            __unkeyed-1 = "vim-fugitive";
            cmd = [ "Git" "G" ];
          }
          # Load diffview on diff commands
          {
            __unkeyed-1 = "diffview.nvim";
            cmd = [ "DiffviewOpen" "DiffviewFileHistory" ];
          }
          # Load rest.nvim for .http files
          {
            __unkeyed-1 = "rest.nvim";
            ft = [ "http" ];
          }
          # Load markdown-preview for .md files
          {
            __unkeyed-1 = "markdown-preview.nvim";
            ft = [ "markdown" ];
            cmd = [ "MarkdownPreview" "MarkdownPreviewStop" ];
          }
        ];
      };
    };

    # Extra plugins not yet in nixpkgs
    extraPlugins = with pkgs.vimUtils; [
      (buildVimPlugin {
        name = "claudecode.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "coder";
          repo = "claudecode.nvim";
          rev = "1552086ebcce9f4a2ea3b9793018a884d6b60169"; # Latest commit as of 2025-01-14
          sha256 = "sha256-XYmf1RQ2bVK6spINZW4rg6OQQ5CWWcR0Tw4QX8ZDjgs=";
        };
      })
    ];

    # Performance optimizations
    performance = {
      byteCompileLua = {
        enable = true;
        initLua = true;
        configs = true;
        plugins = true;
        nvimRuntime = false; # Don't recompile neovim runtime
      };

      combinePlugins = {
        enable = true;
        standalonePlugins = [
          "nvim-treesitter" # Too many parsers, exclude from combining
        ];
        pathsToLink = [
          "/share/vim-plugins"
        ];
      };
    };

    # Additional Lua configuration
    extraConfigLua = ''
      -- ==============================================================================
      -- ClaudeCode.nvim Configuration
      -- ==============================================================================
      local claudecode_ok, claudecode = pcall(require, "claudecode")
      if claudecode_ok then
        claudecode.setup({
          -- Terminal provider - use native since we have toggleterm
          terminal = {
            provider = "native",  -- Works well with existing toggleterm setup
          },

          -- Logging configuration
          log_level = "info",  -- Set to "debug" for troubleshooting

          -- Diff options
          diff_opts = {
            keep_terminal_focus = true,  -- Keep focus in terminal after diff opens
            open_in_new_tab = false,
            hide_terminal_in_new_tab = false,
            auto_close_on_accept = true,
            show_diff_stats = true,
            vertical_split = true,
          },
        })

        -- ClaudeCode keybindings
        vim.keymap.set("n", "<leader>cc", "<cmd>ClaudeCodeStart<cr>", { desc = "Start Claude Code" })
        vim.keymap.set("n", "<leader>cs", "<cmd>ClaudeCodeStatus<cr>", { desc = "Claude Code Status" })
        vim.keymap.set("n", "<leader>cq", "<cmd>ClaudeCodeStop<cr>", { desc = "Stop Claude Code" })

        -- Optional: Auto-start ClaudeCode on VimEnter (uncomment if desired)
        -- vim.api.nvim_create_autocmd("VimEnter", {
        --   pattern = "*",
        --   callback = function()
        --     vim.defer_fn(function()
        --       vim.cmd("ClaudeCodeStart")
        --     end, 100)  -- Delay to ensure all plugins loaded
        --   end,
        -- })
      else
        vim.notify("ClaudeCode.nvim not found - MCP integration unavailable", vim.log.levels.WARN)
      end

      -- ==============================================================================
      -- LazyGit Integration
      -- ==============================================================================
      local Terminal = require('toggleterm.terminal').Terminal
      local lazygit = Terminal:new({
        cmd = "lazygit",
        hidden = true,
        direction = "float",
        float_opts = {
          border = "curved",
        },
      })

      function _lazygit_toggle()
        lazygit:toggle()
      end

      vim.api.nvim_set_keymap("n", "<leader>tg", "<cmd>lua _lazygit_toggle()<CR>", {noremap = true, silent = true, desc = "LazyGit"})

      -- ==============================================================================
      -- Terminal Mode Keybindings
      -- ==============================================================================
      -- Make it easy to exit terminal mode and navigate
      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*",  -- Only match terminal buffers
        callback = function()
          local opts = { buffer = 0, noremap = true, silent = true }
          -- Esc to exit terminal mode (single key!)
          vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts)
          -- Alternative: jk to exit (for those who prefer it)
          vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
          -- Window navigation from terminal mode
          vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], opts)
          vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], opts)
          vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], opts)
          vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], opts)
        end,
      })

      -- ==============================================================================
      -- Startup Time Measurement
      -- ==============================================================================
      if vim.fn.has('vim_starting') == 1 then
        vim.defer_fn(function()
          local stats = vim.api.nvim_get_runtime_file("", true)
          vim.api.nvim_echo({{string.format("Loaded %d runtime files", #stats), "Comment"}}, false, {})
        end, 0)
      end
    '';
  };
in
{
  # Export neovim package built from nixvim config
  neovim-pkg = nixvimConfig;

  # For use in extendShell pattern
  neovim-packages = [
    nixvimConfig
  ];
}
