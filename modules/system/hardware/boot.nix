{ cfg, pkgs, ... }:

{
  boot = {
    loader = {
      limine = {
        enable = true;
        maxGenerations = 15;
        # NB: efiInstallAsRemovable defaults to !canTouchEfiVariables (here:
        # false), so the module installs to EFI/limine and owns the NVRAM
        # entry. Do NOT force it to `true` alongside Secure Boot: that installs
        # to the removable EFI/BOOT fallback while a stale NVRAM "Limine" entry
        # keeps booting an un-enrolled EFI/limine binary -> "checksum mismatch
        # for config file" panic.
        secureBoot = {
          enable = cfg.isSecureBootConfigured;
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

      # Show the themed menu briefly, then auto-boot the default.
      # Press any key during the timeout to open the full entry list.
      timeout = 2;
    };
    tmp.cleanOnBoot = true;

    kernelPackages = cfg.kernel;

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

      "clocksource=tsc" # always tsc even it may be not reliable
      "tsc=reliable"
    ];
  };
}
