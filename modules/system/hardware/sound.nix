{
  security.rtkit.enable = true;

  services.pipewire = {
    pulse.enable = true;
    alsa.enable = false;
    wireplumber.extraConfig = {
      "11-bluetooth-policy" = {
        "wireplumber.settings" = {
          "bluetooth.autoswitch-to-headset-profile" = false;
        };
      };
      "12-bluetooth-ldac-hq" = {
        "monitor.bluez.rules" = [
          {
            matches = [ { "device.name" = "~bluez_card.*"; } ];
            actions.update-props = {
              "bluez5.a2dp.ldac.quality" = "hq";
            };
          }
        ];
      };
    };

    extraConfig.pipewire = {
      "92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.allowed-rates" = [
            44100
            48000
            96000
          ];
          "default.clock.min-quantum" = 1024;
        };
      };
      "93-stream-quality" = {
        "stream.properties" = {
          "resample.quality" = 10;
          "channelmix.stereo-widen" = 0.6;
        };
      };
    };
  };
}
