{
  # power management daemon with battery optimization (over power-profiles-daemon, auto-cpufreq)
  services = {
    tlp = {
      enable = true;
      pd.enable = true;
      settings = {
        WIFI_PWR_ON_BAT = "on";
        PCIE_ASPM_ON_BAT = "powersupersave";
        RUNTIME_PM_ON_BAT = "auto";
        RUNTIME_PM_DRIVER_DENYLIST = "mei_me nouveau radeon"; # exlcudes xhci_hcd from default list
      };
    };
    power-profiles-daemon.enable = false;
  };
}
