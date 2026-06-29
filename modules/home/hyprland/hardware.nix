{ cfg, ... }:

{
  wayland.windowManager.hyprland.settings = {
    monitorv2 = {
      output = "eDP-1";
      mode = "${cfg.defaultScreenResolution}@60";
      position = "auto";
      bitdepth = "10";
      cm = "auto"; # can be hdr for supported monitors, see https://wiki.hypr.land/Configuring/Monitors/#color-management-presets
      mirror = "HDMI-A-1";
    };

    device = {
      name = "synaptics-tm2962-001";
      sensitivity = 0.0; # was -0.1 — negative deceleration compounded the scroll rounding issue
      scroll_factor = 0.4; # was 0.4 — too low; discrete events round to 0 at slow scroll speeds
    };
  };
}
