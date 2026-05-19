{
  # power management daemon with battery optimization (over power-profiles-daemon, auto-cpufreq)
  services = {
    tlp = {
      enable = true;
      pd.enable = true;
      settings = {
        WIFI_PWR_ON_BAT = "off";
      };
    };
    power-profiles-daemon.enable = false;
  };
}
