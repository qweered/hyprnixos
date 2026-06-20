{
  inputs,
  cfg,
  lib,
  ...
}:
{
  imports = [ inputs.ucodenix.nixosModules.default ];

  config = lib.mkIf (cfg.cpu == "amd") {
    hardware.cpu.amd.updateMicrocode = true;

    boot.kernelParams = [
      "microcode.amd_sha_check=off" # for ucodenix to work properly
    ];
  };
}
