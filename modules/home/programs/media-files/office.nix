{ pkgs, ... }:
{
  # over libreoffice-qt-fresh (adds kde bloat), wpsoffice (broken), onlyoffice-desktopeditors (less features)
  home.packages = [ pkgs.libreoffice-qt-fresh ];
}
