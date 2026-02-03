{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false; # handled by uwsm

    # Use the ones from the NixOS module
    package = null;
    portalPackage = null;

    settings = {
      general = {
        layout = "dwindle";
        allow_tearing = true;
        resize_on_border = true;
      };

      # group = {
      #  groupbar = { };
      # };

      misc = {
        vrr = 1;
        focus_on_activate = true;
        key_press_enables_dpms = true;
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
        render_unfocused_fps = 10;
        disable_hyprland_logo = true; # no default wallpaper
        disable_splash_rendering = true; # no funny text from vaxry
      };

      render = {
        direct_scanout = 1;
        # damages my screen on high load
        new_render_scheduling = true; # triple buffering
      };

      input = {
        kb_layout = "canary,rus_canary";
        kb_options = "grp:alt_shift_toggle";
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
}
