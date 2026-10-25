{ pkgs, ... }:
{
  # over, wpsoffice (broken), onlyoffice-desktopeditors (less features), libreoffice-qt

  home.packages = with pkgs; [
    wordcraft
    gridcraft
    deckcraft
  ];
}
