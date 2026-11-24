{
  programs = {
    dux-shell.enable = true;
    dux-files = {
      enable = true;
      portal.enable = true;
    };
  };

  # services.greetd.enable = true; # TODO: this should be enabled by dux-greeter

  # services.displayManager = {
  #  defaultSession = "hyprland-uwsm";
  #  dux-greeter = {
  #    enable = false;
  #    # TODO: multiuser
  #    configHome = cfg.users.qweered.homeDirectory;
  #    compositor = {
  #      name = "hyprland";
  #    };
  #  };
  # };

  # The nixpkgs module only chowns non-hidden entries in /var/lib/dms-greeter:
  # `chown dms-greeter:dms-greeter *`. Leftovers from an earlier greeter account
  # (e.g. .cache, .local owned by `greeter`) stay inaccessible, and the greeter
  # dies with "mkdir /var/lib/dms-greeter/.cache/dms-greeter-shell: permission
  # denied". See https://github.com/duxlabs-dev/dux-greeter/issues/11
  # TODO: fix in nixpkgs
  # systemd.tmpfiles.settings."10-dms-greeter"."/var/lib/dms-greeter".Z = {
  #  user = "dms-greeter";
  #  group = "dms-greeter";
  # };

  # NOTE: workaround for https://github.com/NixOS/nixpkgs/issues/86884
  # Needed to auto keyring unlock on login
  # security.pam.services.dms-greeter.enableGnomeKeyring = true;
}
