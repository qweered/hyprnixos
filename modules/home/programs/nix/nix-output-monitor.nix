{ pkgs, ... }:
{
  # pretty rebuild output
  home.packages = [ pkgs.nix-output-monitor ];
}
