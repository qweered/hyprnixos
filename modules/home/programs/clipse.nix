{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.wayland.windowManager.hyprland.enable;
in
lib.mkIf cfg {
  home.packages = [ pkgs.clipse ];
  wayland.windowManager.hyprland.settings.exec-once = [ "clipse -listen" ];
}
