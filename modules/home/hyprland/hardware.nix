{
  wayland.windowManager.hyprland.settings = {
    monitorv2 = {
      output = "eDP-1";
      mode = "1920x1080@60";
      position = "auto";
      bitdepth = "10";
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
