# Kalilix Hyfetch Configuration Module
# Provides wrapped hyfetch binary with declarative configuration from Nix store
# Follows pure mkShell approach - no home directory modification

{ pkgs, lib }:

let
  # Hyfetch configuration (immutable, in Nix store)
  hyfetchConfig = pkgs.writeText "kalilix-hyfetch.json" ''
    {
      "preset": "random",
      "mode": "rgb",
      "light_dark": "dark",
      "lightness": 0.65,
      "color_align": {
        "mode": "horizontal",
        "custom_colors": [],
        "fore_back": null
      },
      "backend": "neofetch",
      "distro": null,
      "pride_month_shown": [],
      "pride_month_disable": false
    }
  '';

  # Wrapped hyfetch binary with baked-in Kalilix configuration
  hyfetchWrapped = pkgs.writeShellScriptBin "hyfetch" ''
    # If user explicitly specifies -C or --config-file, respect their choice
    if [[ "$*" == *"-C"* ]] || [[ "$*" == *"--config-file"* ]]; then
      exec ${pkgs.hyfetch}/bin/hyfetch "$@"
    else
      # Otherwise use Kalilix configuration from Nix store
      exec ${pkgs.hyfetch}/bin/hyfetch --config-file=${hyfetchConfig} "$@"
    fi
  '';

in {
  # Packages to include in shell
  packages = [
    hyfetchWrapped
    pkgs.neofetch  # Required backend for hyfetch
  ];

  # Shell hook - exports config path for reference
  shellHook = ''
    export KALILIX_HYFETCH_CONF="${hyfetchConfig}"
  '';

  # Expose config for reference/documentation
  config = hyfetchConfig;
}
