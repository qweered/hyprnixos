{ inputs, ... }:
{
  imports = [ inputs.ucodenix.nixosModules.default ];

  services.ucodenix = {
    enable = true;
    # To retrieve processor's model ID, run `cpuid -1 -l 1 -r | sed -n 's/.*eax=0x\([0-9a-f]*\).*/\U\1/p'`
    cpuModelId = "00860F81";
  };

  hardware.cpu.amd.updateMicrocode = true;

  boot.kernelParams = [
    "microcode.amd_sha_check=off" # for ucodenix to work properly ];
  ];
}
