{ pkgs, ... }:
{
  hardware = {
    enableRedistributableFirmware = false;
    firmware = with pkgs; [
      linux-firmware
    ];
  };

  # FIXME: make it work with other processors and move to system/hardware/cpu/amd.nix
  services.ucodenix = {
    enable = true;
    # To retrieve processor's model ID, run `cpuid -1 -l 1 -r | sed -n 's/.*eax=0x\([0-9a-f]*\).*/\U\1/p'`
    cpuModelId = "00860F81";
  };

  boot = {
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3; # or rt-bore
    kernelParams = [
      # BIOS declares unsupported, but works
      "pcie_aspm=force"
    ];
    initrd = {
      includeDefaultModules = false;
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "kvm-amd"
      ];
    };
  };
}
