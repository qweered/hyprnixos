{ config, ... }:
{
  sops.secrets.nix-builder-key = { };

  nix = {
    distributedBuilds = true;

    buildMachines = [
      {
        # Ignores home ssh config, compress for faster speed
        hostName = "jonringer.us:2222?compress=true";
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
          "builder-rpc-v0"
          "recursive-nix"
          "uid-range"
          "ca-derivations"
          "dynamic-derivations"
        ];

        # 128 cores / 188 GB RAM
        # Kept under Jon's own  max-jobs = 40 since the box is shared
        # speedFactor is only a relative, and 16:1 is enough that anything buildable goes there first.
        maxJobs = 32;
        speedFactor = 16;

        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUYxRHJVUmpRY1RaUk5xazg2ZDV6dW9kc3M5bDRSZzh6NlR0M09SVE84RlYK";
      }
    ];
  };
}
