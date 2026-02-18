{ pkgs, ... }:
{
  # inspect nix tree
  home.packages = [ pkgs.nix-tree ];
}
