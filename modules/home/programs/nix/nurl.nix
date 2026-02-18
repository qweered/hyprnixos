{ pkgs, ... }:
{
  # url to nix expression
  home.packages = [ pkgs.nurl ];
}
