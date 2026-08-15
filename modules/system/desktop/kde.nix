{
  lib,
  cfg,
  pkgs,
  ...
}:

{
  config = lib.mkIf (lib.elem "kde" cfg.sessions) {
    services.desktopManager.plasma6.enable = true;
    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      konsole
    ];
    services.orca.enable = false; # screen reader
  };
}
