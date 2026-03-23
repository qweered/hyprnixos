{
  lib,
  inputs,
  config,
  ...
}:
let
  flakeInputs = lib.filterAttrs (_: v: lib.isType "flake" v) inputs;
in
{
  imports = [ inputs.determinate.nixosModules.default ];

  nixpkgs.config = {
    allowUnfree = true;
    allowAliases = false;
    warnUndeclaredOptions = true;
    checkMeta = true;
    # TODO: find a way to make this check less noisy, e.g. showing only one level deep packages
    # showDerivationWarnings = [ "maintainerless" ];
    # strictDepsByDefault = true;
    # structuredAttrsByDefault = true;
    # fetchedSourceNameDefault = "versioned";
    # enableParallelBuildingByDefault = true;
    # contentAddressedByDefault = true;
    # configurePlatformsByDefault = true;
    # doCheckByDefault = true;
  };

  nix = {
    channel.enable = false;

    # improve desktop responsiveness when updating the system
    # daemonCPUSchedPolicy = "batch"; TODO: configure only for low end devices

    # TODO: i don't need all the flakes in registry and path, nixpkgs is set by default nixpkgs.flake.setFlakeRegistry
    registry = lib.mapAttrs (_: v: { flake = v; }) flakeInputs; # pin the registry
    nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry; # set the path for channels compatibility

    extraOptions = ''
      !include ${config.age.secrets.git-token.path}
    '';

    settings = {
      auto-optimise-store = false; # optimized with nh instead, faster build
      allow-import-from-derivation = true; # for devenv
      builders-use-substitutes = true;
      flake-registry = "/etc/nix/registry.json";
      log-lines = 25;
      # TODO: enable on determinate nix update
      # lint-url-literals = "fatal";
      # lint-short-path-literals = "fatal";
      # lint-absolute-paths-literals = "fatal";

      # Switch substitutes on timeouts
      connect-timeout = 10;
      stalled-download-timeout = 10;
      fallback = true;

      # Avoid disk full issues (unneeded with determinate nix)
      # max-free = 3000 * 1024 * 1024; # 3GB
      # min-free = 1024 * 1024 * 1024; # 1GB

      experimental-features = [
        "nix-command" # for non-determinate nix
        "flakes" # for non-determinate nix
        "ca-derivations"
        "local-overlay-store"
      ];
      eval-cores = "0";
      lazy-trees = true;

      trusted-users = [ "@wheel" ];

      substituters = [
        "https://cache.nixos.org?priority=1" # lower number means higher priority
        "https://nix-community.cachix.org" # cache for unfree packages
        "https://cache.garnix.io" # some more community packages
        # "https://ekala-corepkgs.cachix.org" # corepkgs - unused for now
        "https://cache.numtide.com" # llm agents
        "https://attic.xuyh0120.win/lantian" # cachyos kernel
        "https://nix-gaming.cachix.org" # some gaming packages
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "ekala-corepkgs.cachix.org-1:DcZV+vegWoEzacbSdXFXU4S7728C0eS9RfGpKeyHd6w="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];
    };
  };
}
