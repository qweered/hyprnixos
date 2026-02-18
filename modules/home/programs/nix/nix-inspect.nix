{ pkgs, ... }:
{
  # inspect nix flakes
  home.packages = [ pkgs.nix-inspect ];
}
