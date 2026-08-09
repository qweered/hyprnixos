{ config, pkgs, ... }:
let
  tlp = pkgs.tlp.override {
    enableRDW = config.networking.networkmanager.enable;
    # TODO: upstream
    systemd = config.systemd.package;
  };
in
{
  # power management daemon with battery optimization (over power-profiles-daemon, auto-cpufreq)
  services = {
    tlp = {
      package = tlp;
      enable = true;
      pd = {
        enable = true;
        package = pkgs.tlp-pd.override { inherit tlp; };
      };
      settings = {
        WIFI_PWR_ON_BAT = "on";
        PCIE_ASPM_ON_BAT = "powersupersave";
        RUNTIME_PM_ON_BAT = "auto";
        RUNTIME_PM_DRIVER_DENYLIST = "mei_me nouveau radeon"; # excludes xhci_hcd from default list
      };
    };
    power-profiles-daemon.enable = false;
  };
}
