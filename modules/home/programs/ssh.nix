{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "no"; # uses gpg-agent instead
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };

      # Interactive only -- the remote builder reaches the same host through
      # nix.buildMachines, which does not read this file.
      external = {
        HostName = "jonringer.us";
        Port = 2222;
        User = "qweered";
      };
    };
  };
}
