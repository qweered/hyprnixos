{ vars, ... }:

{
  programs.home-manager.enable = true;

  home = {
    enableNixpkgsReleaseCheck = false; # flake keep it in sync, produces annoying warning right after release
    inherit (vars) username stateVersion homeDirectory;
    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1"; # for nix shell, nix run https://github.com/NixOS/nix/issues/9875
      EDITOR = "${vars.editor}";
      BROWSER = "${vars.browser}";
      QT_QPA_PLATFORMTHEME = "qt6ct";
      NIXOS_OZONE_WL = "1"; # use wayland in electron packages
      MOZ_ENABLE_WAYLAND = "1"; # use wayland in firefox
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1"; # disable window decorations in qt apps
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      GDK_SCALE = "1";
      GDK_BACKEND = "wayland,x11,*";
      CLUTTER_BACKEND = "wayland";
      SDL_VIDEODRIVER = "wayland"; # QUIRK: Some games require it to be x11
    };
  };

  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
