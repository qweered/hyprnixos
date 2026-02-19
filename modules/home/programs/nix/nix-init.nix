{ pkgs, ... }:
{
  # create new nix packages
  home.packages = [ pkgs.nix-init ];
}
