{ pkgs, ... }:
{
  # review nixpkgs changes
  home.packages = [ pkgs.nixpkgs-review ];
}
