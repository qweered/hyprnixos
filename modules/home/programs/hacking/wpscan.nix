{ pkgs, ... }:
{
  # WordPress vulnerability scanner
  home.packages = [ pkgs.wpscan ];
}
