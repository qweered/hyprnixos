{ pkgs, ... }:

{
  programs.gpg = {
    enable = true;
    mutableKeys = true;
    mutableTrust = true;
    settings = {
      default-key = "6807099C36539409";
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-qt; # TODO: use gnome
  };
}
