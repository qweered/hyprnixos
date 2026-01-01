{ pkgs, ... }:

{
  # CONFIG: I can generate custom menu items in thunar
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
}
