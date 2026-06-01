{
  # auto-adjusts backlight from webcam ambient light + day/night screen gamma.
  # clightd drives amdgpu_bl1; ambient brightness is computed from /dev/video0.
  services.clight = {
    enable = true;
    settings = {
      backlight = {
        # longer recapture intervals [day night event] (sec) so manual brillo
        # nudges (XF86MonBrightness binds) persist instead of being reverted.
        ac_timeouts = [
          1800
          3600
          300
        ];
        batt_timeouts = [
          2700
          5400
          600
        ];
        # ignore captures below this to avoid blanking when the webcam is covered.
        shutter_threshold = 0.1;
      };
      # smooth sunrise/sunset temperature ramp rather than a step at the event.
      gamma.long_transition = true;
    };
  };

  # clight needs a location for sun times; query the already-enabled geoclue
  # service live instead of the default manual 0,0 the clight module would inject.
  location.provider = "geoclue2";
}
