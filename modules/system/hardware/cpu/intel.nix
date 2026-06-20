{ cfg, lib, ... }:
{
  config = lib.mkIf (cfg.cpu == "intel") {
    hardware.cpu.intel.updateMicrocode = true;
    boot.kernelModules = [ "kvm-intel" ];
  };
}
