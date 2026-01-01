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

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocales = [ "ru_RU.UTF-8/UTF-8" ];
  };
}
