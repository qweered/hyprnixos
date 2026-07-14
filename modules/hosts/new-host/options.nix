{
  hyprnixos = {
    cpu = "intel"; # CHANGE ME
    gpu = "intel"; # CHANGE ME
    hostPlatform = "x86_64-linux";
    desktop = "hyprland"; # or kde
    stateVersion = "26.05";
    secureBootConfigured = false;
    # CHANGE ME: ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub, then `nix run .#sops-sync`
    hostAgeKey = null;
    users.kavazar.enable = true;
  };
}
