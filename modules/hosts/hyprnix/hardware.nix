{
  inputs,
  pkgs,
  hostPlatform,
  ...
}:

{
  imports = [ inputs.ucodenix.nixosModules.default ];

  services.ucodenix = {
    enable = true;
    # To retrieve processor's model ID, run `cpuid -1 -l 1 -r | sed -n 's/.*eax=0x\([0-9a-f]*\).*/\U\1/p'`
    cpuModelId = "00860F81";
  };

  hardware = {
    # NOTE: a lot of mess comes from here https://github.com/NixOS/nixpkgs/blob/103ac534018bbc99254a1e0b043f423b855b55b6/nixos/modules/hardware/all-firmware.nix
    enableRedistributableFirmware = false;
    cpu.amd.updateMicrocode = true;
    amdgpu.initrd.enable = true; # load driver before plymouth
    firmware = with pkgs; [
      linux-firmware
      # intel2200BGFirmware
      # rtl8192su-firmware
      # rt5677-firmware
      # rtl8761b-firmware
      # zd1211fw
      # alsa-firmware
      # sof-firmware
      # libreelec-dvb-firmware
    ];
  };

  boot.initrd = {
    # NOTE: USB keyboards may become broken https://github.com/NixOS/nixpkgs/blob/22c3f2cf41a0e70184334a958e6b124fb0ce3e01/nixos/modules/system/boot/kernel.nix#L292
    includeDefaultModules = false;
    availableKernelModules = [
      "nvme"
      "xhci_pci"
      "kvm-amd"
    ];
  };

  nixpkgs.hostPlatform = hostPlatform;
  networking.hostName = "hyprnix";
  system.stateVersion = "25.05";
}
