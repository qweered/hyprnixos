{ pkgs, ... }:
{
  # over, wpsoffice (broken), onlyoffice-desktopeditors (less features)
  home.packages = [ pkgs.libreoffice-qt ];
}
