{
  description = "Kalilix: Enterprise-grade polyglot development environment";

  inputs = {
    # Core
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Development
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Language-specific
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Tools
    nixpkgs-fmt = {
      url = "github:nix-community/nixpkgs-fmt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];

    # Optimization settings
    max-jobs = "auto";
    cores = 0;
    sandbox = false;  # false in containers
    experimental-features = "nix-command flakes";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, ... }@inputs:
    let
      # Overlays
      overlays = [
        # Unstable packages overlay
        (final: prev: {
          unstable = import nixpkgs-unstable {
            system = final.system;
            config.allowUnfree = true;
          };
        })

        # Language-specific overlays
        inputs.rust-overlay.overlays.default
      ];

    in flake-utils.lib.eachDefaultSystem (system:
      let
        # Import nixpkgs with overlays
        pkgs = import nixpkgs {
          inherit system overlays;
          config = {
            allowUnfree = true;
            allowUnfreePredicate = (_: true);
          };
        };

        # Import all devshell modules
        shells = import ./modules/devshells {
          inherit pkgs system inputs;
          lib = nixpkgs.lib;
        };

      in {
        # Development shells
        devShells = shells;

        # Packages (custom tools)
        packages = {
          # Add custom packages here
        };

        # Apps (executable scripts)
        apps = {
          # kx CLI will be added here
        };

        # Checks (CI/CD)
        checks = {
          # Add checks here
        };
      }
    ) // {
      # Non-system-specific outputs
      overlays = {
        default = overlays;
      };
    };
}
