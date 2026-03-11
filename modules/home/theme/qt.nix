{ pkgs, ... }:

{
  # CONFIG: switch to declarative theming
  home.packages = with pkgs; [
    kdePackages.qt6ct
    libsForQt5.qt5ct
  ];
}
