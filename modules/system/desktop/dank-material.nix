{ lib, cfg, ... }:

{
  config = lib.mkIf (lib.elem "hyprland" cfg.sessions) {
    programs.dms-shell = {
      enable = true;
      enableVPN = false;
      enableClipboardPaste = false;
    };

    # TODO: requires config for keyboard etc.
    # services.displayManager.dms-greeter = {
    #   enable = true;
    #   configHome = "/home/qweered";
    #   compositor.name = false;
  };
}
