{ pkgs, ... }:

{
  # CONFIG: switch to declarative theming
  home.packages = with pkgs; [
    nwg-look # over lxappearance
    adw-gtk3
    papirus-icon-theme
  ];
}
