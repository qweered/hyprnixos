{ pkgs, ... }:
{
  # Enumerate open ports
  home.packages = [ pkgs.nmap ];
}
