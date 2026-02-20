{ pkgs, ... }:
{
  # check nix derivations for unused dependencies
  home.packages = [ pkgs.nix-check-deps ];
}
