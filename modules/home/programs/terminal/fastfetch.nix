{ pkgs, ... }:
let
  fastfetch = pkgs.fastfetch.override {
    enlightenmentSupport = false;
    flashfetchSupport = false;
    gnomeSupport = false;
    openclSupport = false;
    rpmSupport = false;
    sqliteSupport = false;
    x11Support = false;
    xfceSupport = false;
  };
in
{
  # CONFIG
  programs.fastfetch = {
    enable = true;
    package = fastfetch;
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
