{ pkgs, ... }:

{
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    tmp.cleanOnBoot = true;

    # NOTE: Not feature-complete yet https://blog.decent.id/post/nixos-systemd-initrd/
    initrd.systemd.enable = true;

    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;

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

    # Hide the OS choice in the bootloader menu
    # It's still possible to open the bootloader list by pressing any key
    loader.timeout = 0;
  };
}
