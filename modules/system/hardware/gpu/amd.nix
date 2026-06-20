{ cfg, lib, ... }:
{
  config = lib.mkIf (cfg.gpu == "amd") {
    hardware.amdgpu.initrd.enable = true; # load driver before plymouth
  };
}
