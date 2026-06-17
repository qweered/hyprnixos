{ pkgs, ... }:
{
  hyprnix = {
    cpu = "amd";
    gpu = "amd";
    hostName = "hyprnix";
    hostPlatform = "x86_64-linux";
    desktop = "hyprland";
    stateVersion = "26.05";
    isSecureBootConfigured = true;
    kernel = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v3; # or rt-bore
    users = {
      qweered = { };
    };
  };
}
