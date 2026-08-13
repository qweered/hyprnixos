{
  inputs,
  config,
  lib,
  ...
}:
let
  cpus = config.hardware.facter.report.hardware.cpu;
  isAmd = lib.any (c: c.vendor_name == "AuthenticAMD") cpus;

  # ucodenix matches blobs on CPUID Fn0000_0001_EAX (what `cpuid -1 -l 1 -r`
  # prints); facter reports that same value already split into family/model/
  # stepping, so rebuild it rather than hardcoding one per host.
  cpuModelId =
    let
      inherit (lib.head cpus) family model stepping;
      baseFamily = if family >= 15 then 15 else family;
      extFamily = if family >= 15 then family - 15 else 0;
      eax = extFamily * 1048576 + (model / 16) * 65536 + baseFamily * 256 + (lib.mod model 16) * 16 + stepping;
    in
    lib.fixedWidthString 8 "0" (lib.toHexString eax);
in
{
  imports = [ inputs.ucodenix.nixosModules.default ];

  config = lib.mkIf isAmd {
    # Explicit: facter derives this from enableRedistributableFirmware, so a host
    # that trims firmware (hyprnix) would silently lose microcode updates.
    hardware.cpu.amd.updateMicrocode = true;

    services.ucodenix = {
      enable = true;
      inherit cpuModelId;
    };

    boot.kernelParams = [
      "microcode.amd_sha_check=off" # for ucodenix to work properly
    ];
  };
}
