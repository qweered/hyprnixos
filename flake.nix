{
  description = "HyprNixOS";

  inputs = {
    # nixpkgs-local-testing.url = "git+file:///home/qweered/Projects/nixpkgs";
    # numtide/nixpkgs-unfree is deliberately not an input: it re-exposes
    # `legacyPackages` only, carries no nixpkgs source tree for
    # nixpkgs-patcher or `nixpkgs.flake.source` to use, and re-pins nixpkgs
    # to a GitHub tarball. See patches/allow-unfree-by-default.patch instead.
    # nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst"; # Smaller then github tarball, less api hits
    nixpkgs-patcher.url = "github:qweered/nixpkgs-patcher/perf-materialise-once"; # 4x faster
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
    nixpkgs-patch-make-initrd-ng-dlopen-alternatives = {
      url = "https://github.com/qweered/nixpkgs/commit/7441b95afb6da774204d96a68969c4014af0fbc4.diff";
      flake = false;
    };

    # global inputs, other will follow them
    systems.url = "github:nix-systems/triplet";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:NixOS/flake-compat";
    };
    treefmt-nix = {
      # only for llm-agents
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs"; # does not need cache hit
    };

    # other inputs
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/nix-src/*";
      inputs = {
        flake-parts.follows = "flake-parts";
        git-hooks-nix.follows = "git-hooks";
        nixpkgs-23-11.follows = ""; # dev-only
        nixpkgs-regression.follows = ""; # dev-only
      };
    };
    ncro = {
      url = "github:manic-systems/ncro";
      inputs.nixpkgs.follows = "nixpkgs"; # does not need cache hit
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # important
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs"; # does not need cache hit
    };
    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs = {
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
        # nixpkgs.follows = "nixpkgs"; # do not override, painful cache misses
      };
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
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs"; # does not need cache hit
        nixpkgs-nixcord.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
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
    vicinae-extensions = {
      # source only: vicinae itself comes from nixpkgs, extensions are built
      # in pkgs/vicinae-extensions (upstream's flake would pull the whole
      # vicinae closure just for its mkVicinaeExtension helper)
      url = "github:vicinaehq/extensions";
      flake = false;
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ./entrypoint.nix ];
    };
}
