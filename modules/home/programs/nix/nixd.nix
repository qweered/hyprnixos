{ pkgs, ... }:
{
  # nix lsp
  home.packages = [ pkgs.nixd ];
}
