{
  description = "HyprNixOS";

  inputs = {
    # nixpkgs-unstable-with-unfree.url = "github:numtide/nixpkgs-unfree/nixpkgs-unstable";
    # nixpkgs-try-pr.url = "github:nixos/nixpkgs?ref=pull/379731/merge";
    # nixpkgs-local-testing.url = "git+file:///home/qweered/Projects/nixpkgs";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/master";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    nfh.url = "github:name-snrl/nfh";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    git-hooks.url = "github:cachix/git-hooks.nix";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    declarative-flatpak.url = "github:in-a-dil-emma/declarative-flatpak/latest";

    # stylix = {
    #   url = "github:nix-community/stylix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # lazyvim = {
    #   url = "github:matadaniel/LazyVim-module";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ucodenix.url = "github:e-tho/ucodenix";
    nixcord.url = "github:kaylorben/nixcord";
    spicetify = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: move into my repo
    easyeffects-presets = {
      url = "github:jackhack96/easyeffects-presets";
      flake = false;
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
