{
  system.disableInstallerTools = true; # remove generate, install, enter, option, version, build-vms, firewall
  system.tools.nixos-rebuild.enable = true; # but keep rebuild
}
