{ lib, cfg, ... }:

{
  config = lib.mkIf (lib.elem "hyprland" cfg.sessions) {
    programs.dux-shell.enable = true;

    # TODO: requires config for keyboard etc.
    # services.displayManager.dms-greeter = {
    #   enable = true;
    #   configHome = "/home/qweered";
    #   compositor.name = false;
  };
}
