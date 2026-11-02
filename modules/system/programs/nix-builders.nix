{ config, ... }:
{
  sops.secrets.nix-builder-key = { };

  nix = {
    distributedBuilds = false;

    buildMachines = [
      {
        # Ignores home ssh config
        hostName = "jonringer.us:2222";
        protocol = "ssh-ng";
        systems = [ "x86_64-linux" ];

        sshUser = "qweered";
        sshKey = config.sops.secrets.nix-builder-key.path;

        # Build everything
        supportedFeatures = [
          "big-parallel"
          "kvm"
          "nixos-test"
          "benchmark"
          "uid-range"
          # "builder-rpc-v0"
          # "recursive-nix"
          # "ca-derivations"
          # "dynamic-derivations"
        ];

        # 128 cores / 188 GB RAM
        # Kept under Jon's own  max-jobs = 32 since the box is shared
        # speedFactor is only a relative, and 16:1 is enough that anything buildable goes there first.
        maxJobs = 32;
        speedFactor = 0;

        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUYxRHJVUmpRY1RaUk5xazg2ZDV6dW9kc3M5bDRSZzh6NlR0M09SVE84RlYK";
      }
    ];
  };
}
