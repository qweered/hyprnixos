{ config, ... }:
{
  # Read by the daemon, which runs as root. Borrowing the user's gpg-agent
  # socket instead would not be a permissions problem -- CAP_DAC_OVERRIDE makes
  # its 0600 mode no barrier to root -- but the socket's lifetime is wrong:
  # /run/user/1000 is torn down at last logout (Linger=no), the daemon starts
  # at boot before any session exists, and a cold agent wants a pinentry that
  # nothing can answer. A file the daemon owns outlives all three.
  sops.secrets.nix-builder-key = { };

  nix = {
    distributedBuilds = true;

    buildMachines = [
      {
        # The port lives in hostName. /etc/nix/machines is assembled as
        # `<protocol>://<sshUser>@<hostName>` and ssh-ng's URL format is
        # ssh-ng://[user@]host[:port], so this needs no ssh_config Host block
        # -- which is what keeps the daemon independent of ~/.ssh/config.
        hostName = "jonringer.us:2222";
        protocol = "ssh-ng";
        systems = [ "x86_64-linux" ];

        sshUser = "qweered";
        sshKey = config.sops.secrets.nix-builder-key.path;

        # Claim only what the remote can actually do: a job matching a feature
        # listed here is routed there and fails outright if the host lacks it.
        supportedFeatures = [
          "big-parallel"
          "kvm"
          "nixos-test"
          "benchmark"
        ];

        # TODO: confirm the core count and re-weigh against this laptop.
        maxJobs = 8;
        speedFactor = 2;

        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUYxRHJVUmpRY1RaUk5xazg2ZDV6dW9kc3M5bDRSZzh6NlR0M09SVE84RlYK";
      }
    ];
  };
}
