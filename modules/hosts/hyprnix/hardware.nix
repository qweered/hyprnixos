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

    # This board's ACPI Time and Alarm Device is broken (`ACPI Error: No handler
    # for Region [VRTC] (SystemCMOS)`, reads return EIO) yet still races rtc_cmos
    # for the rtc0 slot that CONFIG_RTC_{HCTOSYS,SYSTOHC}_DEVICE hardcode. On the
    # boots it won, `timedatectl` failed outright and the kernel wrote the synced
    # time into the broken device -- so the real CMOS clock went unmaintained for
    # weeks and still held a 2021 date whenever rtc_cmos did win the race. A clock
    # that stale invalidates every TLS cert, killing strict DoT -> DNS -> NTP: the
    # boot deadlock services/timesyncd.nix documents, whose rtc0 udev match is only
    # correct because of this line. Nothing else uses acpi_tad (refcount 0).
    blacklistedKernelModules = [ "acpi_tad" ];
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
