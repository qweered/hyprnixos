{
  description = "HyprNixOS";

  inputs = {
    # nixpkgs-local-testing.url = "git+file:///home/qweered/Projects/nixpkgs";
    # nixpkgs-structurred.url = "github:SFrijters/nixpkgs/structuredattrs-prs-stacked-staging-2026-01-30";
    # nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz"; # Smaller then github tarball, less api hits
    nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";
    nixpkgs-patch-sddm-astronaut-update = {
      url = "https://github.com/NixOS/nixpkgs/pull/492325.diff";
      flake = false;
    };
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
      inputs.nix.inputs.flake-parts.follows = "flake-parts";
      inputs.nix.inputs.git-hooks-nix.follows = "git-hooks";
    };

    # global inputs, other will follow them
    lib.url = "github:nix-community/nixpkgs.lib";
    systems.url = "github:nix-systems/default";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "lib";
    };
    flake-compat = {
      url = "github:NixOS/flake-compat";
    };
    # flake-utils = {
    #   url = "github:numtide/flake-utils";
    #   inputs.systems.follows = "systems";
    # };
    blueprint = {
      url = "github:numtide/blueprint";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    gitignore = {
      # needed for pre-commit
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # other inputs
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-parts.follows = "flake-parts";
      # inputs.nixpkgs.follows = "nixpkgs"; # do not override nixpkgs, cache misses
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.blueprint.follows = "blueprint";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
    };
    nfh = {
      url = "github:name-snrl/nfh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.flake-compat.follows = "flake-compat";
      inputs.gitignore.follows = "gitignore";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-nixcord.follows = "nixpkgs";
    };
    spicetify = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
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
    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.vicinae.follows = "vicinae";
      inputs.systems.follows = "systems";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.home-manager.follows = "home-manager";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.pre-commit-hooks.follows = "git-hooks";
    };
  };

  outputs =
    inputs@{
      nfh,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } rec {
      flake.moduleTree = nfh ./modules;
      imports = flake.moduleTree.flake-parts { };
      systems = nixpkgs.lib.systems.flakeExposed;
    };
}
