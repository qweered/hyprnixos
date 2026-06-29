{ lib, cfg, ... }:

{
  config = lib.mkIf cfg.isWindowManager {
    programs.dms-shell = {
      enable = true;
      enableVPN = false;
      enableClipboardPaste = false;
    };

    # TODO: requires config for keyboard etc.
    # services.displayManager.dms-greeter = {
    #   enable = true;
    #   configHome = "/home/kavazar";
    #   compositor.name = false;
  };
}
