{ pkgs, ... }:

{
  programs.gpg = {
    enable = true;
    mutableKeys = false;
    mutableTrust = false;
    settings = {
      default-key = "CACB28BA93CE71A2";
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-qt; # TODO: use gnome
  };
}
