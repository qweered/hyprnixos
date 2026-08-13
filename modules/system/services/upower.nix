{ config, ... }:
{
  # power management daemon, TODO: do i need it if i have tlp?
  services.upower.enable = config.hardware.facter.detected.chassis.laptop;
}
