{
  lib,
  cfg,
  pkgs,
  ...
}:

{
  config = lib.mkIf (cfg.desktop == "kde") {
    services.desktopManager.plasma6.enable = true;
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      konsole
    ];
    services.orca.enable = false; # screen reader
  };
}
