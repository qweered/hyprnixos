{
  hyprnixos = {
    kernelFlavour = "latest-lto"; # or bore-lto, lts-lto, hardened, server
    sessions = [ "hyprland" ]; # or "kde", or both
    stateVersion = "26.05";
    secureBootConfigured = false;
    userProfiles = [ "kavazar" ]; # or "qweered", see modules/users/
  };
}
