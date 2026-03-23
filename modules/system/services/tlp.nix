{
  # power management daemon with battery optimization (over power-profiles-daemon, auto-cpufreq)
  services = {
    tlp = {
      enable = true;
      pd.enable = true;
    };
    power-profiles-daemon.enable = false;
  };
}
