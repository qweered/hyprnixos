{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix") # TODO: remove if everything works
  ];

  hardware = {
    # NOTE: list from https://github.com/NixOS/nixpkgs/blob/d2426f5728d33ce8e81f6c22857895de744ac1e0/nixos/modules/hardware/all-firmware.nix
    enableRedistributableFirmware = true; # TODO: flip it to false and configure only needed firmware to save space
    # firmware = with pkgs; [
    #   linux-firmware
    #   # intel2200BGFirmware
    #   # rtl8192su-firmware
    #   # rt5677-firmware
    #   # rtl8761b-firmware
    #   # zd1211fw
    #   # alsa-firmware
    #   # sof-firmware
    #   # libreelec-dvb-firmware - dvb tv tuner
    #   # broadcom-bt-firmware
    #   # b43Firmware_5_1_138
    #   # b43Firmware_6_30_163_46
    #   # xone-dongle-firmware - xbox dongle
    #   # facetimehd-calibration - mac webcam
    #   # facetimehd-firmware - mac webcam
    # ];
  };

  boot = {
    initrd = {
      # NOTE: USB keyboards may become broken if we disable it
      # https://github.com/NixOS/nixpkgs/blob/22c3f2cf41a0e70184334a958e6b124fb0ce3e01/nixos/modules/system/boot/kernel.nix#L292
      includeDefaultModules = true; # TODO: flip to false after you verify you dont need anything from it and added needed modules to available list
      availableKernelModules = [
        #   "nvme"
        #   "xhci_pci"
        # FIXME: kavazar specifics, remove
        "xhci_pci"
        "ehci_pci"
        "ahci"
        "uas"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
    };
  };
}
