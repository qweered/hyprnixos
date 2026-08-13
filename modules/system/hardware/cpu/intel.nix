{ config, lib, ... }:
let
  cpus = config.hardware.facter.report.hardware.cpu;
  isIntel = lib.any (c: c.vendor_name == "GenuineIntel") cpus;
in
{
  config = lib.mkIf isIntel {
    # Explicit: facter derives this from enableRedistributableFirmware, so a host
    # that trims firmware would silently lose microcode updates.
    # kvm-intel is facter's, from the CPU's vmx flag.
    hardware.cpu.intel.updateMicrocode = true;
  };
}
