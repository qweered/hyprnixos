{ inputs, pkgs, ... }:

{
  imports = [ inputs.stylix.homeModules.stylix ];
  stylix.enable = true;
  stylix.image = ../../../wallpapers/Anime-Girl4.png;
  stylix.overlays.enable = false;

  stylix.cursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
  };

  /*
    stylix.fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      monospace = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans Mono";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    }
  */

}
