{
  programs.dconf.enable = true; # for gnome related stuff
  programs.xfconf.enable = true; # store gnome preferences
  services.fstrim.enable = true; # periodically trim ssd

  services.upower.enable = true; # power daemon, used by eg. chromium
  services.power-profiles-daemon.enable = true; # power daemon, for laptops mainly
  services.udisks2.enable = true; # disk storage daemon
  services.gvfs.enable = true; # mount, trash, etc in file managers
  services.tumbler.enable = true; # thumbnails in file managers
  programs.fish.enable = true; # best shell
}
