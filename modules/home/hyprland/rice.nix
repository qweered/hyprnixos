{
  wayland.windowManager.hyprland.settings = {
    general = {
      border_size = 5;
      gaps_in = 10;
      gaps_out = 10;
      gaps_workspaces = 5;

      # CONFIG: color based on wallpaper
      # TODO: col = {}
      "col.inactive_border" =
        "rgba(90,90,110,0.3) rgba(100,100,120,0.3) rgba(110,110,130,0.3) rgba(120,120,140,0.3) rgba(130,130,150,0.3) rgba(140,140,160,0.3) rgba(150,150,170,0.3) 45deg";
      # LGBT lightning
      "col.active_border" =
        "rgba(179,0,0,0.8) rgba(179,89,0,0.8) rgba(179,179,0,0.8) rgba(0,179,0,0.8) rgba(0,0,179,0.8) rgba(53,0,92,0.8) rgba(101,0,179,0.8) 45deg";
      # "col.nogroup_border" = 1;
      # "col.nogroup_border_active" = 1;
      # snap =  {
      #    enabled = true;
      # };
    };

    decoration = {
      rounding = 7;
      rounding_power = 4;
      active_opacity = 1;
      # CONFIG: choose between dim and opacity for inactive windows
      #        inactive_opacity = 0.7;
      #        dim_inactive = true;

      blur = {
        enabled = true;
        size = 8;
        passes = 3;
        noise = 0.01;
        contrast = 0.9;
        brightness = 0.8;
        popups = true;
      };
    };

    animations = {
      enabled = true;

      bezier = [
        "wind,0.05,0.9,0.1,1.05" # Wind-like curve
        "winIn,0.1,1.1,0.1,1.1" # Smooth in
        "winOut,0.3,-0.3,0,1" # Smooth out with a bounce
        "liner,1,1,1,1" # Linear curve
        "overshot,0.05,0.9,0.1,1.05" # Overshooting effect
        "smoothOut,0.5,0,0.99,0.99" # Smooth out curve
        "smoothIn,0.5,-0.5,0.68,1.5" # Smooth in curve
      ];
      animation = [
        "windows,1,6,wind,slide" # Window animations using wind curve
        "windowsIn,1,5,winIn,slide" # Windows slide in with winIn curve
        "windowsOut,1,3,smoothOut,slide" # Windows slide out with smoothOut curve
        "windowsMove,1,5,wind,slide" # Window movement with wind curve
        "border,1,1,liner" # Border animation using linear curve
        "borderangle,1,180,liner,loop" # Rotating border animations
        "fade,1,3,smoothOut" # Fade animation with smoothOut curve
        "workspaces,1,5,overshot" # Workspace animation with overshooting curve
        "workspacesIn,1,5,winIn,slide" # Slide in
        "workspacesOut,1,5,winOut,slide" # Slide out
      ];
    };
  };
}
