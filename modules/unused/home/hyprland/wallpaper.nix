{ pkgs, ... }:

{
  # CONFIG: try hyprpaper, wpaperd
  services.swww.enable = true; # over mpvpaper (nice animations and video playback is too hungry anyway), swaybg (static-only)

  home.packages = [ pkgs.waytrogen ]; # over waypaper (250mb of bloat)

  wayland.windowManager.hyprland.settings.exec-once = [ "uwsm -s b -- waytrogen --restore" ];
}
