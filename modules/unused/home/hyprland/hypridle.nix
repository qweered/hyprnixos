let
  timeout = 30 * 60; # timeout in seconds after which DPMS kicks in
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        lock_cmd = "hyprlock";
      };

      listener = [
        {
          timeout = timeout - 10;
          # save the current brightness and dim the screen over a period of 500ms
          on-timeout = "brillo -O; brillo -u 500000 -S 10";
          # brighten the screen over a period of 250ms to the saved value
          on-resume = "brillo -I -u 250000";
        }
        {
          inherit timeout;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = timeout + 10;
          on-timeout = "loginctl lock-session";
        }
      ];
    };
  };
}
