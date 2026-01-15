{ pkgs, ... }:

{
  # CONFIG: https://wiki.nixos.org/wiki/Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        FastConnectable = true;
        Experimental = true;
      };
      Policy = {
        AutoEnable = false;
      };
    };
  };
  environment.systemPackages = [ pkgs.overskride ]; # over blueman, bluetuith
}
