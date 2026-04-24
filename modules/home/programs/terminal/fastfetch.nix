{
  # CONFIG
  programs.fastfetch = {
    enable = true;
    settings = {
      modules = [
        "title"
        "separator"
        "os"
        "host"
        "kernel"
        "uptime"
        "packages" # add 100ms to fetch time
        "shell"
        "wm" # add 100ms to fetch time
        "theme"
        "icons"
        "font"
        "monitor"
        "cpu"
        "gpu"
        "memory"
        "swap"
        "disk"
        "break"
        "colors"
      ];
    };
  };
}
