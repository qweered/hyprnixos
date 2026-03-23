{ pkgs, ... }:

let
  sddm-astronaut = pkgs.sddm-astronaut.override {
    # CONFIG:
    #    themeConfig = {
    #    };
    # See: https://github.com/Keyitdev/sddm-astronaut-theme
    embeddedTheme = "hyprland_kath";
  };
in

{
  services.displayManager = {
    defaultSession = "hyprland-uwsm";
    sddm = {
      enable = true;
      wayland.enable = true;
      wayland.compositor = "weston"; # takes less space than kwin, kwin may take less space with kde environment
      theme = "sddm-astronaut-theme"; # name of theme package
      extraPackages = [ sddm-astronaut ];
    };
  };

  # NOTE: workaround for https://github.com/NixOS/nixpkgs/issues/86884
  security.pam.services.sddm.enableGnomeKeyring = true;

  environment.systemPackages = [ sddm-astronaut ];
}
