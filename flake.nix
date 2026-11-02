{
  description = "HyprNixOS";

  inputs = {
    # nixpkgs-local-testing.url = "git+file:///home/qweered/Projects/nixpkgs";
    # nixpkgs-master.url = "github:nixos/nixpkgs/master";
    # nixpkgs-unpatched.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst"; # Smaller then github tarball, less api hits
    nixpkgs.url = "github:qweered/nixpkgs/nixos-unstable-patched";

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
    corepkgs-v2 = {
      url = "github:ekala-project/corepkgs-v2";
      inputs.nixpkgs.follows = "nixpkgs"; # so we dont bloat closure
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
        nixpkgs.follows = "nixpkgs"; # does not need cache hit
        nixpkgs-packages.follows = "nixpkgs";
        nixpkgs-ci.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        treefmt-nix.follows = "treefmt-nix";
        nix-darwin.follows = ""; # unused here
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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    direnv-instant = {
      url = "github:Mic92/direnv-instant";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    # determinate = {
    #   url = "https://flakehub.com/f/DeterminateSystems/nix-src/*";
    #   inputs = {
    #     flake-parts.follows = "flake-parts";
    #     git-hooks-nix.follows = "git-hooks";
    #     nixpkgs-23-11.follows = ""; # dev-only
    #     nixpkgs-regression.follows = ""; # dev-only
    #   };
    # };
    # only for determinate nix
    # nixpkgs-patch-builtins-filterattrs = {
    #  url = "https://github.com/NixOS/nixpkgs/pull/498999.diff";
    #  flake = false;
    # };
  };
  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ./entrypoint.nix ];
    };
}
