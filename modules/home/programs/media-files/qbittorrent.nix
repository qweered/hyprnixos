{ pkgs, ... }:
{
  # over deluge, transmission
  home.packages = [ pkgs.qbittorrent ];
}
