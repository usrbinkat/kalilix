# Kalilix Tmux Configuration Module
# Provides wrapped tmux binary with declarative configuration from Nix store
# Follows pure mkShell approach - no home directory modification

{ pkgs, lib }:

let
  # Readline configuration for proper terminal behavior in tmux
  inputrc = pkgs.writeText "kalilix-inputrc" ''
    # Kalilix readline configuration for tmux
    # Enables arrow keys and proper key bindings

    set enable-keypad on
    set input-meta on
    set output-meta on
    set convert-meta off

    # Arrow key bindings for command history
    "\e[A": previous-history
    "\e[B": next-history
    "\e[C": forward-char
    "\e[D": backward-char

    # Home/End keys
    "\e[H": beginning-of-line
    "\e[F": end-of-line

    # Delete key
    "\e[3~": delete-char
  '';

  # Bashrc for interactive tmux panes
  # This runs with --rcfile so it replaces the default bashrc
  tmuxBashrc = pkgs.writeText "kalilix-tmux-bashrc" ''
    # Enable programmable completion features (interactive shells only)
    if [ -f ${pkgs.bash-completion}/share/bash-completion/bash_completion ]; then
      . ${pkgs.bash-completion}/share/bash-completion/bash_completion
    fi

    # Source user's bashrc if it exists (for customizations)
    if [ -f ~/.bashrc ]; then
      . ~/.bashrc
    fi
  '';

  # Core tmux configuration (immutable, in Nix store)
  tmuxConfig = pkgs.writeText "kalilix-tmux.conf" ''
    # Kalilix Tmux Configuration
    # Declarative, reproducible terminal multiplexer setup

    # ============================================
    # Core Settings
    # ============================================
    set -g default-terminal "tmux-256color"
    set -g default-shell "${pkgs.bash}/bin/bash"
    # Launch interactive bash with custom rcfile for proper completion support
    set -g default-command "${pkgs.bash}/bin/bash --rcfile ${tmuxBashrc} -i"
    set -g history-limit 50000
    set -g base-index 1
    setw -g pane-base-index 1
    setw -g mode-keys vi
    set -g mouse on
    set -g escape-time 0
    set -g prefix C-a
    # Don't unbind C-b - allow it to pass through to nested sessions
    # unbind C-b  # COMMENTED: Allow C-b passthrough for nested tmux
    bind C-a send-prefix

    # Allow C-b to be sent to nested tmux sessions
    bind-key b send-keys C-b

    # ============================================
    # Environment Configuration
    # ============================================
    # Set readline inputrc for proper arrow key handling
    set-environment -g INPUTRC "${inputrc}"
    # Preserve these environment variables when creating new panes
    set -g update-environment "INPUTRC"

    # ============================================
    # True Color Support
    # ============================================
    set -ga terminal-overrides ",xterm-256color:RGB"
    set -as terminal-features ",xterm*:RGB"
    set -ag terminal-overrides ",alacritty:RGB"
    set -ag terminal-overrides ",kitty:RGB"
    set -ag terminal-overrides ",ghostty:RGB"

    # ============================================
    # Performance Settings
    # ============================================
    set -g focus-events on
    setw -g aggressive-resize on
    set -g status-interval 5

    # Disable visual noise
    setw -g monitor-activity off
    set -g visual-activity off
    set -g visual-bell off

    # ============================================
    # Human-Friendly Defaults
    # ============================================
    set -g renumber-windows on
    set -g status-position top

    # ============================================
    # Keybindings
    # ============================================
    # Reload config with visual feedback (uses KALILIX_TMUX_CONF env var)
    bind r run-shell 'tmux source-file "$KALILIX_TMUX_CONF" && tmux display-message "⚡ Kalilix config reloaded!"'

    # Intuitive split keybindings with current path preservation
    unbind '"'
    unbind %
    bind '|' split-window -h -c "#{pane_current_path}"
    bind '\' split-window -h -c "#{pane_current_path}"
    bind - split-window -v -c "#{pane_current_path}"

    # Vim-style pane resizing (repeatable with -r)
    bind -r H resize-pane -L 5
    bind -r J resize-pane -D 5
    bind -r K resize-pane -U 5
    bind -r L resize-pane -R 5

    # Window cycling
    bind Tab last-window
    bind -n M-H previous-window
    bind -n M-L next-window

    # Pane synchronization toggle
    bind S set-window-option synchronize-panes\; display-message "Sync #{?pane_synchronized,ON,OFF}"

    # Break pane to new window
    bind b break-pane

    # Join pane from another window
    bind j command-prompt -p "Join pane from:" "join-pane -s '%%'"

    # ============================================
    # Clipboard Integration
    # ============================================
    # OSC 52 clipboard support (works over SSH)
    set -s set-clipboard on
    set -g allow-passthrough on
    set -as terminal-features ',xterm*:clipboard'

    # Vi-mode copy bindings
    bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
    bind-key -T copy-mode-vi 'C-v' send-keys -X rectangle-toggle \; send -X begin-selection
    bind-key -T copy-mode-vi 'y' send-keys -X copy-pipe-and-cancel
    bind-key -T copy-mode-vi Escape send-keys -X cancel

    # Platform-specific clipboard integration
    ${lib.optionalString pkgs.stdenv.isDarwin ''
    # macOS: pbcopy with reattach-to-user-namespace
    bind-key -T copy-mode-vi 'y' send-keys -X copy-pipe-and-cancel 'pbcopy'
    ''}

    ${lib.optionalString pkgs.stdenv.isLinux ''
    # Linux X11: xsel (fallback to wl-copy for Wayland)
    bind-key -T copy-mode-vi 'y' send-keys -X copy-pipe-and-cancel 'xsel -i --clipboard > /dev/null 2>&1 || wl-copy'
    ''}

    # ============================================
    # Nested Session Support (F12 Toggle + C-b passthrough)
    # ============================================
    # For nested sessions: outer uses C-a, inner uses C-b
    # Press C-a b to send C-b to inner session
    # Or use F12 to toggle outer session OFF completely
    # Color scheme variables for OFF state
    color_status_text="colour245"
    color_window_off_status_bg="colour238"
    color_window_off_status_current_bg="colour254"
    color_light="white"
    color_dark="colour232"

    # F12 to toggle outer session OFF
    bind -T root F12 \
        set prefix None \;\
        set key-table off \;\
        set status-style "fg=$color_status_text,bg=$color_window_off_status_bg" \;\
        set window-status-current-format "#[fg=$color_window_off_status_bg,bg=$color_window_off_status_current_bg] #I:#W #" \;\
        set window-status-current-style "fg=$color_dark,bold,bg=$color_window_off_status_current_bg" \;\
        if -F '#{pane_in_mode}' 'send-keys -X cancel' \;\
        refresh-client -S \;\
        display-message "Outer tmux OFF - F12 to restore"

    # F12 in OFF mode restores outer session
    bind -T off F12 \
        set -u prefix \;\
        set -u key-table \;\
        set -u status-style \;\
        set -u window-status-current-style \;\
        set -u window-status-current-format \;\
        refresh-client -S \;\
        display-message "Outer tmux ON"

    # Visual indicator in status bar
    wg_is_keys_off="#[fg=$color_light,bg=colour196]#{?#{==:#{key-table},off}, [OFF] ,}#[default]"
    set -ag status-right "$wg_is_keys_off"

    # ============================================
    # SSH Awareness
    # ============================================
    # Load remote config if SSH session detected
    if-shell 'test -n "$SSH_CLIENT"' \
      'set -g status-position bottom; set -g status-right "#{hostname} | %H:%M"'

    # ============================================
    # Catppuccin Theme Configuration
    # ============================================
    set -g @catppuccin_flavour 'macchiato'
    set -g @catppuccin_window_status_style "rounded"

    # Rounded separators using Nerd Font icons
    set -g @catppuccin_window_left_separator ""
    set -g @catppuccin_window_right_separator " "
    set -g @catppuccin_window_middle_separator " █"
    set -g @catppuccin_window_number_position "right"

    # Window text configuration
    set -g @catppuccin_window_default_fill "number"
    set -g @catppuccin_window_default_text "#W"
    set -g @catppuccin_window_current_fill "number"
    set -g @catppuccin_window_current_text "#W"

    # Status modules (minimal configuration)
    set -g @catppuccin_status_modules_right "directory session"
    set -g @catppuccin_status_left_separator " "
    set -g @catppuccin_status_right_separator ""
    set -g @catppuccin_status_fill "icon"
    set -g @catppuccin_status_connect_separator "no"

    # ============================================
    # Plugin Loading
    # ============================================
    # Load sensible plugin
    run-shell ${pkgs.tmuxPlugins.sensible}/share/tmux-plugins/sensible/sensible.tmux

    # Load Catppuccin theme
    run-shell ${pkgs.tmuxPlugins.catppuccin}/share/tmux-plugins/catppuccin/catppuccin.tmux

    # ============================================
    # User Overrides
    # ============================================
    # Load local user overrides if present (optional)
    if-shell '[ -f ~/.config/tmux/kalilix-local.conf ]' \
      'source-file ~/.config/tmux/kalilix-local.conf'
  '';

  # Wrapped tmux binary with baked-in Kalilix configuration
  tmuxWrapped = pkgs.writeShellScriptBin "tmux" ''
    # If user explicitly specifies -f, respect their choice
    if [ "$1" = "-f" ]; then
      exec ${pkgs.tmux}/bin/tmux "$@"
    else
      # Otherwise use Kalilix configuration from Nix store
      exec ${pkgs.tmux}/bin/tmux -f ${tmuxConfig} "$@"
    fi
  '';

in {
  # Packages to include in shell
  packages = [
    tmuxWrapped
    pkgs.tmuxp
    pkgs.tmuxPlugins.catppuccin
    pkgs.tmuxPlugins.sensible
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    pkgs.xsel
    pkgs.wl-clipboard
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    pkgs.reattach-to-user-namespace
  ];

  # Shell hook - exports config paths and readline settings
  shellHook = ''
    export KALILIX_TMUX_CONF="${tmuxConfig}"
    export INPUTRC="${inputrc}"
  '';

  # Expose config for reference/documentation
  config = tmuxConfig;
}
