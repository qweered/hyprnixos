{ cfg, lib, ... }:

{
  config = lib.mkIf (cfg.desktop == "hyprland") {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };
    security.pam.services.hyprlock = { }; # Needed for hyprlock
  };
}
