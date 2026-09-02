{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "no"; # uses gpg-agent instead
        compression = true;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };

      jon-server = {
        HostName = "jonringer.us";
        Port = 2222;
        User = "qweered";
      };
    };
  };
}
