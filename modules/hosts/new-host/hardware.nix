{
  hardware = {
    # facter has no firmware detection: it flips this on for bare metal as a
    # fallback for devices it could not identify. Trimming stays manual.
    # NOTE: flip to false and list only what this machine needs (saves ~1.5G).
    enableRedistributableFirmware = true;

    # What the switch above pulls in -- uncomment only what applies. Source:
    # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/hardware/all-firmware.nix
    # firmware = with pkgs; [
    #   linux-firmware         # kernel.org blobs: GPU, most modern wifi/BT, NIC microcode
    #   sof-firmware           # audio DSP on essentially every laptop since ~2019
    #   alsa-firmware          # older discrete sound cards (SoundBlaster Live!/Audigy)
    #   rtl8761b-firmware      # Realtek RTL8761B USB bluetooth dongles
    #   rtl8192su-firmware     # Realtek RTL8188SU/8191SU/8192SU USB wifi dongles
    #   zd1211fw               # ZyDAS ZD1211(b) USB wifi dongles (~2005)
    #   ipw2200-firmware       # Intel 2200BG mini-PCI wifi (~2004)
    #   rt5677-firmware        # Realtek RT5677 audio DSP (Chromebook Pixel era)
    #   libreelec-dvb-firmware # DVB TV tuner cards
    #
    #   Unfree, need enableAllFirmware = true instead:
    #
    #   broadcom-bt-firmware    # Broadcom bluetooth (many Macs, older ThinkPads)
    #   b43Firmware_5_1_138     # Broadcom b43 wifi, older revisions
    #   b43Firmware_6_30_163_46 # Broadcom b43 wifi, newer revisions
    #   xone-dongle-firmware    # Xbox One wireless controller dongle
    #   facetimehd-firmware     # Apple FaceTime HD webcam (MacBook 2013+)
    #   facetimehd-calibration  # calibration data for the above
    # ];
  };

  # NOTE: facter only appends to availableKernelModules, so it can never flip this for you
  # USB keyboards may become broken if we disable it
  # https://github.com/NixOS/nixpkgs/blob/22c3f2cf41a0e70184334a958e6b124fb0ce3e01/nixos/modules/system/boot/kernel.nix#L292
  boot.initrd.includeDefaultModules = true;
}
