{
  hyprnixos = {
    hostPlatform = "x86_64-linux";
    kernelFlavour = "latest-lto"; # or bore-lto, lts-lto, hardened-lto, server-lto
    desktop = "hyprland"; # or kde
    stateVersion = "26.05";
    secureBootConfigured = false;
    # CHANGE ME: ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub, then `nix run .#sops-sync`
    hostAgeKey = null;
    users = {
      # qweered.enable = true;
      kavazar.enable = true;
    };
  };
}
