{ pkgs, ... }:
{
  # over libreoffice-qt-fresh (adds kde bloat), wpsoffice (broken)
  home.packages = [ pkgs.onlyoffice-desktopeditors ];
}
