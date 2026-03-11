{ pkgs, ... }:
{
  # Brute force login pages
  home.packages = [ pkgs.thc-hydra ];
}
