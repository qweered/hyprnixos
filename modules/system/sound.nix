{
  security.rtkit.enable = true;
  # Other options already enabled by https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/graphical-desktop.nix

  services.pipewire = {
    alsa.support32Bit = true;
    # CONFIG: pipewire for low latency / high quality https://wiki.nixos.org/wiki/PipeWire
    # All stuff at the bottom needs more research

    extraConfig = {
      pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.min-quantum" = 1024;
        };
      };
      #     pipewire-pulse."91-high-quality" = {
      #       "context.properties" = [
      #         {
      #           name = "libpipewire-module-protocol-pulse";
      #           args = { };
      #         }
      #       ];

      #       "stream.properties" = {
      #         "node.latency" = "1024/48000";
      #         "node.autoconnect" = "true";
      #         "resample.disable" = "true";
      #         "monitor.channel-volumes" = "false";
      #         "channelmix.disable" = "false";
      #         "channelmix.min-volume" = 0.0;
      #         "channelmix.max-volume" = 10.0;
      #         "channelmix.normalize" = "false";
      #         "channelmix.mix-lfe" = "true";
      #         "channelmix.upmix" = "true";
      #         "channelmix.upmix-method" = "psd"; # none, simple
      #         "channelmix.lfe-cutoff" = 150.0;
      #         "channelmix.fc-cutoff" = 12000.0;
      #         "channelmix.rear-delay" = 12.0;
      #         "channelmix.stereo-widen" = 0.0;
      #         "channelmix.hilbert-taps" = 0;
      #         "dither.noise" = 0;
      #         "dither.method" = "none"; # rectangular, triangular, triangular-hf, wannamaker3, shaped5
      #         "debug.wav-path" = "";
      #       };
      #     };
    };
  };
}
