{ pkgs, ... }:

{
  # CONFIG
  programs.opencode = {
    enable = true;
    package = pkgs.opencode;
  };
}
