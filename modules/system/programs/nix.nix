{
  config,
  inputs,
  ...
}:
{
  nixpkgs.config = {
    allowAliases = false;
    warnUndeclaredOptions = true;
    # checkMeta = false; # NOTE: should only be enabled in ci
    # allowUnfree = true; # NOTE: defaults to true in my config
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

  nix = {
    package = inputs.determinate.packages.${config.hardware.facter.report.system}.default;
    channel.enable = false;

    # NOTE: improve desktop responsiveness when updating the system, configure for low end devices
    # daemonCPUSchedPolicy = "batch";

    extraOptions = ''
      !include ${config.sops.secrets.nix-access-tokens.path}
    '';

    settings = {
      keep-going = true;
      keep-failed = true;
      show-trace = true;
      warn-dirty = false;
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
      min-free = "5G"; # Start gc at
      max-free = "20G"; # Stop gc at

      # Faster download and fallback
      http-connections = 64;
      max-substitution-jobs = 32;
      # connect-timeout = 10; # dead under ncro
      stalled-download-timeout = 30;
      download-attempts = 3;
      fallback = true;

      lazy-trees = true;
      lazy-locks = true;
      eval-cores = 0;

      use-cgroups = true;
      auto-allocate-uids = true;

      experimental-features = [
        "nix-command" # for non-determinate nix
        "flakes" # for non-determinate nix
        "ca-derivations"
        "dynamic-derivations"
        "local-overlay-store"
        "cgroups"
        "auto-allocate-uids"
        "pipe-operators"
        "recursive-nix"
        #"parallel-eval"
      ];

      extra-system-features = [
        "uid-range"
        "builder-rpc-v0"
        "recursive-nix"
      ];

      trusted-users = [ "@wheel" ];
    };
  };
}
