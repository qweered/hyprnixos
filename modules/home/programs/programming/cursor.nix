{ pkgs, ... }:
{
  # CONFIG
  programs.vscode = {
    enable = true;
    package = pkgs.code-cursor;
  };
}
