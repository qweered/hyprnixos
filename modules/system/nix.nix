{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  flakeInputs = lib.filterAttrs (_: v: lib.isType "flake" v) inputs;
in
{
  nixpkgs.config = {
    allowUnfree = true;
    allowAliases = false;
  };

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [ oxlint ];
  };

  environment.systemPackages = with pkgs; [
    nixd # lsp
    nix-tree # inspect nix store
    nix-inspect # inspect flake
    nix-output-monitor # pretty rebuild output
    nixpkgs-review # review nix packages
    nix-update # update nix packages
  ];

  # TODO: why overlays don't work in flake-parts?
  nixpkgs.overlays = [
    (_final: prev: {
      nix = prev.lixPackageSets.git.lix;
      nix-output-monitor = prev.nix-output-monitor.overrideAttrs (_old: {
        src = prev.fetchFromGitHub {
          owner = "maralorn";
          repo = "nix-output-monitor";
          rev = "20ad9727e49bf686bea1c5e6769241234a56804b";
          hash = "sha256-Llmi7oE0ayOupM7Cc1lnYv7O0mPKvRtFPI4M+eYaMew=";
        };
      });
    })
  ];

  nix = {
    channel.enable = false;

    # TODO: i don't need all the flakes in registry and path, nixpkgs is set by default nixpkgs.flake.setFlakeRegistry
    registry = lib.mapAttrs (_: v: { flake = v; }) flakeInputs; # pin the registry
    nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry; # set the path for channels compatibility

    settings = {
      auto-optimise-store = false; # optimized with nh instead, faster build
      allow-import-from-derivation = true; # for devenv
      builders-use-substitutes = true;
      flake-registry = "/etc/nix/registry.json";

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-users = [ "@wheel" ];

      substituters = [
        "https://cache.nixos.org?priority=1" # lower number means higher priority
        "https://aseipp-nix-cache.freetls.fastly.net" # nix cache v2 https://wiki.nixos.org/wiki/Maintainers:Fastly#Beta_+_IPv6_+_HTTP/2
        "https://nix-community.cachix.org" # cache for unfree packages
        "https://cache.garnix.io" # some more community packages
        "https://ekala-corepkgs.cachix.org" # corepkgs
        "https://nix-gaming.cachix.org" # some gaming packages
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "ekala-corepkgs.cachix.org-1:DcZV+vegWoEzacbSdXFXU4S7728C0eS9RfGpKeyHd6w="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];
    };
  };
}
