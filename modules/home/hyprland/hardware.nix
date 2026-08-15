{ osConfig, ... }:

{
  wayland.windowManager.hyprland.settings = {
    monitor = {
      output = "eDP-1";
      inherit (osConfig.hardware.facter.detected.monitor) mode;
      position = "auto";
      scale = 1;
      bitdepth = 10;
      cm = "auto"; # can be hdr for supported monitors, see https://wiki.hypr.land/Configuring/Monitors/#color-management-presets
      mirror = "HDMI-A-1";
    };

    device = {
      name = "elan071a:00-04f3:30fd-touchpad";
      sensitivity = -0.1;
      scroll_factor = 0.4;
    };
  };
}
