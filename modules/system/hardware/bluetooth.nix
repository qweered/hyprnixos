{
  # CONFIG: https://wiki.nixos.org/wiki/Bluetooth
  # `enable` comes from facter (controller detected in the report).
  hardware.bluetooth = {
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
}
