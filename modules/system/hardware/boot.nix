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
        # Limine >=11.2.0 panics ("checksum mismatch for config file") under
        # active Secure Boot unless a BLAKE2B checksum of limine.conf is
        # enrolled into the signed EFI binary. enrollConfig defaults to
        # panicOnChecksumMismatch (false), so we must turn it on explicitly.
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
      timeout = 3;
    };
    tmp.cleanOnBoot = true;

    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-rt-bore-lto; # or latest-lto-x86_64-v3;

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
      "vt.global_cursor_default=0"
      "rd.systemd.show_status=auto"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "plymouth.use-simpledrm" # https://github.com/NixOS/nixpkgs/issues/32556#issuecomment-2315814669

      "boot.shell_on_fail"
      "microcode.amd_sha_check=off" # for ucodenix to work properly

      # may cause issues
      "clocksource=tsc" # always tsc even it may be not reliable
      "tsc=reliable"
    ];
  };
}
