{ vars, ... }:

{
  programs.hyprpanel = {
    enable = true;
    settings = {
      layout = {
        "bar.layouts" = {
          "*" = {
            left = [
              "dashboard"
              "workspaces"
            ];
            middle = [
              "media"
              "clock"
            ];
            right = [
              "volume"
              "bluetooth"
              "network"
              "systray"
              "battery"
              "notifications"
            ];
          };
        };
      };

      bar.launcher.autoDetectIcon = true;
      bar.workspaces.show_icons = true;

      menus = {
        dashboard.directories.enabled = true;
        dashboard.stats.enable_gpu = false;
        clock = {
          time = {
            military = true;
            hideSeconds = true;
          };
        };
        weather.unit = "metric";
        weather.location = toString vars.city;
      };

      theme.bar.transparent = true;

      theme.font = {
        name = "JetBrains Mono Nerd Font Regular";
        size = "15px";
      };
    };
  };
}
