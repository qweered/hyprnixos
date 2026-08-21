{
  pkgs,
  lib,
  user,
  ...
}:
{
  home.packages = lib.optionals (user.browser == "vivaldi") (
    with pkgs;
    [
      (vivaldi.override {
        commandLineArgs = "--password-store=gnome-libsecret"; # Relevant for kde
        enableWidevine = true;
        proprietaryCodecs = true;
        inherit widevine-cdm vivaldi-ffmpeg-codecs;
      })
    ]
  );
}
