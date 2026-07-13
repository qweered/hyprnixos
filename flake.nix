{
  description = "HyprNixOS";

  inputs = {
    # nixpkgs-local-testing.url = "git+file:///home/qweered/Projects/nixpkgs";
    # nixpkgs-unstable-with-unfree.url = "github:numtide/nixpkgs-unfree/nixpkgs-unstable" - can't get this to work
    # nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz"; # Smaller then github tarball, less api hits
    nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";
    nixpkgs-patch-codexbar-cli = {
      url = "https://github.com/NixOS/nixpkgs/pull/525686.diff";
      flake = false;
    };
    nixpkgs-patch-builtins-filterattrs = {
      url = "https://github.com/NixOS/nixpkgs/pull/498999.diff";
      flake = false;
    };
    nixpkgs-patch-singularityapp = {
      url = "https://github.com/NixOS/nixpkgs/pull/535346.diff";
      flake = false;
    };
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/nix-src/*";
      inputs = {
        flake-parts.follows = "flake-parts";
        git-hooks-nix.follows = "git-hooks";
      };
    };

    # global inputs, other will follow them
    lib.url = "github:nix-community/nixpkgs.lib";
    systems.url = "github:nix-systems/triplet";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "lib";
    };
    flake-compat = {
      url = "github:NixOS/flake-compat";
    };
    flake-utils = {
      # only for nix-output-monitor
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    treefmt-nix = {
      # only for llm-agents and agenix-rekey
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs"; # does not need cache hit
    };

    # other inputs
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs = {
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
        # nixpkgs.follows = "nixpkgs"; # do not override, painful cache misses
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # important
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs"; # does not need cache hit
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs"; # rarely misses cache
        treefmt-nix.follows = "treefmt-nix";
        systems.follows = "systems";
        flake-parts.follows = "flake-parts";
      };
    };
    import-tree.url = "github:vic/import-tree";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs"; # does not need cache hit
      };
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs"; # does not need cache hit
    };
    nix-output-monitor = {
      # use upstream flake: overlaying only `src` onto nixpkgs breaks the Haskell build
      url = "github:maralorn/nix-output-monitor";
      inputs = {
        nixpkgs.follows = "nixpkgs"; # does not need cache hit
        flake-utils.follows = "flake-utils";
        git-hooks.follows = "git-hooks";
      };
    };
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs = {
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs"; # does not need cache hit
        nixpkgs-nixcord.follows = "nixpkgs";
      };
    };
    spicetify = {
      url = "github:Gerg-L/spicetify-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs"; # does not need cache hit
        systems.follows = "systems";
      };
    };
    cpu-microcodes = {
      url = "github:platomav/CPUMicrocodes";
      flake = false;
    };
    ucodenix = {
      url = "github:e-tho/ucodenix";
      inputs.cpu-microcodes.follows = "cpu-microcodes";
    };
    declarative-flatpak.url = "github:in-a-dil-emma/declarative-flatpak/latest";
    # TODO: pull from nixpkgs instead, pulls big closure
    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs = {
        nixpkgs.follows = "nixpkgs"; # does not need cache hit cause only needed for vicinae-extensions
        systems.follows = "systems";
      };
    };
    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs = {
        nixpkgs.follows = "nixpkgs"; # does not need cache hit
        vicinae.follows = "vicinae";
        flake-compat.follows = "flake-compat";
        systems.follows = "systems";
      };
    };
    agenix = {
      # Includes fix for userborn: https://github.com/ryantm/agenix/pull/353
      url = "github:marienz/agenix/941af799a916cf8d1141941e6d91a4ec7bcf51ab";
      inputs = {
        nixpkgs.follows = "nixpkgs"; # does not need cache hit
        systems.follows = "systems";
        home-manager.follows = "home-manager";
      };
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs = {
        nixpkgs.follows = "nixpkgs"; # does not need cache hit
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
        pre-commit-hooks.follows = "git-hooks";
      };
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ./entrypoint.nix ];
    };
}
