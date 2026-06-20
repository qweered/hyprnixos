{
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocales = [ "ru_RU.UTF-8/UTF-8" ];
  };

  # Less bloated fix for "open with" in dolphin, see https://github.com/NixOS/nixpkgs/issues/409986
  environment.etc."xdg/menus/applications.menu".source = ../../assets/dolphin.menu;
}
