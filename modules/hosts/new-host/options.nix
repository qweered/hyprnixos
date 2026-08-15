{
  hyprnixos = {
    hostPlatform = "x86_64-linux";
    kernelFlavour = "latest-lto"; # or bore-lto, lts-lto, hardened-lto, server-lto
    desktop = "hyprland"; # or kde
    stateVersion = "26.05";
    secureBootConfigured = false;
    users = {
      # qweered.enable = true;
      kavazar.enable = true;
    };
  };
}
