{
  lib,
  osConfig,
  user,
  ...
}:
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false; # handled by uwsm

    # Use the ones from the NixOS module
    package = null;
    portalPackage = null;

    settings = {
      mod._var = "SUPER";

      config = {
        general = {
          layout = "dwindle";
          allow_tearing = true;
          resize_on_border = true;
        };

        ecosystem = {
          no_donation_nag = true;
          no_update_news = true;
        };

        # group = {
        #  groupbar = { };
        # };

        misc = {
          vrr = 1;
          focus_on_activate = false; # too noisy and causes issues with windows apps
          key_press_enables_dpms = true;
          animate_manual_resizes = true;
          animate_mouse_windowdragging = true;
          render_unfocused_fps = 5;
          disable_hyprland_logo = true; # no default wallpaper
          disable_splash_rendering = true; # no funny text from vaxry
        };

        render = {
          # 0 off, 1 always, 2 only when a fullscreen video surface is on top.
          # 2 keeps the screen_shader applied to most fullscreen apps but
          # bypasses for actual video, matching mpv/browser hardware planes.
          direct_scanout = 2;
          new_render_scheduling = true; # triple buffering
        };

        input = {
          kb_layout = lib.concatStringsSep "," user.keyboardLayouts;
          kb_options = osConfig.services.xserver.xkb.options;
          repeat_rate = 30;
          repeat_delay = 300;
          follow_mouse = 1;
          float_switch_override_focus = 2;
          focus_on_close = 1;
          touchpad = {
            natural_scroll = true;
            disable_while_typing = false;
          };
        };

        dwindle = {
          preserve_split = true;
          smart_split = false; # split based on mouse position
          precise_mouse_move = true;
        };
      };
    };
  };
}
