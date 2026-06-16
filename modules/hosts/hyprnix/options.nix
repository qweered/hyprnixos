{ pkgs, ... }:
{
  hyprnix = {
    desktop = "hyprland";
    stateVersion = "26.05";
    hostPlatform = "x86_64-linux";
    hostName = "hyprnix";
    isSecureBootConfigured = true;
    kernel = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3; # or rt-bore
    users = {
      qweered = { };
    };
  };
}
