{
  lib,
  inputs,
  config,
  ...
}:
{
  nixpkgs.config = {
    allowAliases = false;
    warnUndeclaredOptions = true;
    checkMeta = true;
    # NOTE: it defaults to true because of patch
    # allowUnfree = true;
    # TODO: find a way to make this check less noisy, e.g. showing only one level deep packages
    # showDerivationWarnings = [ "maintainerless" ];
    # Mass rebuilds:
    # strictDepsByDefault = true;
    # structuredAttrsByDefault = true;
    # fetchedSourceNameDefault = "versioned";
    # enableParallelBuildingByDefault = true;
    # contentAddressedByDefault = true;
    # configurePlatformsByDefault = true;
    # doCheckByDefault = true;
  };

  nixpkgs.flake.source = lib.mkForce config.nixpkgs-patcher.patchedNixpkgs;

  nix = {
    package = inputs.determinate.packages.${config.hardware.facter.report.system}.default;
    channel.enable = false;

    # distributedBuilds = true; TODO when multiple machines

    # improve desktop responsiveness when updating the system
    # daemonCPUSchedPolicy = "batch"; TODO: configure only for low end devices

    extraOptions = ''
      !include ${config.sops.secrets.nix-access-tokens.path}
    '';

    settings = {
      keep-going = true;
      keep-failed = true;
      flake-registry = "/etc/nix/registry.json";
      use-xdg-base-directories = true;
      accept-flake-config = false; # true allows root access, see https://github.com/NixOS/nix/issues/9649
      allow-import-from-derivation = true; # for devenv and command-not-found, see if we can flip that to false
      trace-import-from-derivation = true;
      always-allow-substitutes = true;
      builders-use-substitutes = true;

      lint-url-literals = "warn";
      lint-short-path-literals = "warn";
      lint-absolute-path-literals = "ignore"; # still too noisy

      # Avoid system full issues
      min-free = 1024 * 1024 * 1024; # Start at 1GB left
      max-free = 10 * 1024 * 1024 * 1024; # Stop at 10GB left

      # Faster download and fallback
      http-connections = 64;
      max-substitution-jobs = 32;
      # connect-timeout = 10; # NOTE: dead under ncro
      stalled-download-timeout = 30;
      download-attempts = 3;
      fallback = true;

      lazy-trees = true;
      lazy-locks = true; # TODO: check that install command works correctly
      eval-cores = 0;

      use-cgroups = true;
      auto-allocate-uids = true;

      experimental-features = [
        "nix-command" # for non-determinate nix
        "flakes" # for non-determinate nix
        "ca-derivations"
        "local-overlay-store"
        "cgroups"
        "auto-allocate-uids"
        "pipe-operators"
        "parallel-eval"
        # "recursive-nix"
      ];

      extra-system-features = [
        "uid-range"
        # "recursive-nix"
      ];

      trusted-users = [ "@wheel" ];
    };
  };
}
