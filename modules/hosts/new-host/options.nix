{ pkgs, ... }:
{
  hyprnix = {
    cpu = "amd"; # CHANGE ME
    gpu = "amd"; # CHANGE ME
    hostPlatform = "x86_64-linux";
    desktop = "hyprland";
    stateVersion = "26.05";
    isSecureBootConfigured = false;
    kernel = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3; # or rt-bore
    users.kavazar.enable = true;
  };
}
