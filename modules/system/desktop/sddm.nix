{ pkgs, ... }:

let
  # Custom YouTube video as SDDM login background
  # "Cat eating a chips through the windows 7 wallpaper"
  sddm-bg-video = ./../../../assets/sddm-bg.mp4;
  sddm-bg-placeholder = ./../../../assets/sddm-bg-placeholder.jpg;

  sddm-astronaut = pkgs.sddm-astronaut.override {
    # See: https://github.com/Keyitdev/sddm-astronaut-theme
    embeddedTheme = "hyprland_kath";
    themeConfig = {
      Background = "${sddm-bg-video}";
      BackgroundPlaceholder = "${sddm-bg-placeholder}";
      CropBackground = "true";
    };
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
