{ config, ... }:
{
  # over brightnessctl (smooth transitions)
  hardware.brillo.enable = config.hardware.facter.detected.chassis.laptop;
}
