{ pkgs, ... }:
{
  # find nix packages that need updates
  home.packages = [ pkgs.nix-olde ];
}
