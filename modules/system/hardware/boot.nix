{
  cfg,
  pkgs,
  lib,
  ...
}:
{
  boot = {
    loader = {
      limine = {
        enable = true;
        maxGenerations = 15;
        # NB: efiInstallAsRemovable defaults to !canTouchEfiVariables
        # DO NOT FORCE IT TO TRUE, or limine will panic with "checksum mismatch for config file"
        secureBoot = {
          enable = cfg.secureBootConfigured;
          autoGenerateKeys = true;
          autoEnrollKeys.enable = true;
        };

        style = {
          wallpapers = [ ../../../assets/limine-wallpaper.jpg ];
          interface = {
            branding = "NixOS";
            brandingColor = "83c0ed"; # wallpaper's bright logo blue
            helpColor = "668fac"; # wallpaper's subtitle blue
            helpColorBright = "7bb2dc"; # wallpaper's light logo blue
          };
        };
      };

      efi.canTouchEfiVariables = true;

      # Press any key during the timeout to open the full entry list.
      timeout = 2;
    };
    tmp.cleanOnBoot = true;

    # Sane default, override per host
    kernelPackages = lib.mkDefault pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto;

    plymouth = {
      enable = true;
      theme = "nixos-bgrt";
      themePackages = [ pkgs.nixos-bgrt-plymouth ];
    };

    # Silent boot
    initrd.verbose = false;
    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "rd.systemd.debug_shell"
      "rd.systemd.show_status=auto"
      "rd.udev.log_level=3"
      "plymouth.use-simpledrm" # https://github.com/NixOS/nixpkgs/issues/32556#issuecomment-2315814669

      # always tsc even if it is not reliable
      "clocksource=tsc"
      "tsc=reliable"
    ];
  };
}
