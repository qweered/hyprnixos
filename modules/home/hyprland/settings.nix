{
  lib,
  osConfig,
  user,
  ...
}:
let
  toLua = lib.generators.toLua { };
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false; # handled by uwsm

    # Use the ones from the NixOS module
    package = null;
    portalPackage = null;

    extraLuaFiles = {
      # Underscore to load before other files
      _vars = {
        content = ''
          vars = {
            terminal = "ghostty",
            keyboard_layouts = ${toLua (lib.concatStringsSep "," user.keyboardLayouts)},
            kb_options = ${toLua osConfig.services.xserver.xkb.options},
            monitor_mode = ${toLua osConfig.hardware.facter.detected.monitor.mode},
          }

          return vars
        '';
      };

      rice = ./lua/rice.lua;
      binds = ./lua/binds.lua;
      settings = ./lua/settings.lua;
      hardware = ./lua/hardware.lua;
      windowrules = ./lua/windowrules.lua;
      gestures = ./lua/gestures.lua;
    };

    extraConfig = ''
      require("dms.colors") -- needed for wallpaper colors
      -- theese are nice to config imperatively and then transfer to nix
      require("dms.binds-user")
      require("dms.windowrules")
      require("dms.outputs")
    '';
  };

  xdg.configFile."hypr/shaders/shadow-lift.frag".source = ./shadow-lift.frag;
}
