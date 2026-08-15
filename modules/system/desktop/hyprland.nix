{ cfg, lib, ... }:

{
  config = lib.mkIf (lib.elem "hyprland" cfg.sessions) {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };
    security.pam.services.hyprlock = { }; # Needed for hyprlock
  };
}
