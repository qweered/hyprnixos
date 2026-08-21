{
  pkgs,
  lib,
  user,
  ...
}:
{
  home.packages = lib.optionals (user.browser == "brave-origin") [
    (pkgs.brave-origin.override {
      commandLineArgs = "--password-store=gnome-libsecret"; # Relevant for kde
    })
  ];
}
