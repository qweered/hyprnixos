{ pkgs, ... }:
{
  # update nix packages
  home.packages = [ pkgs.nix-update ];
}
