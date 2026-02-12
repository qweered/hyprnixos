{
  programs.dconf.enable = true; # for gnome related stuff
  programs.xfconf.enable = true; # store gnome preferences

  services.upower.enable = true; # power daemon, used by eg. chromium
  services.power-profiles-daemon.enable = true; # power daemon, for laptops mainly

  # Only allow members of the wheel group to execute sudo by setting the executable’s permissions accordingly
  # This prevents users that are not members of wheel from exploiting vulnerabilities in sudo such as CVE-2021-3156
  security.sudo.execWheelOnly = true;
  # Don't lecture the user. Less mutable state.
  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';
}
