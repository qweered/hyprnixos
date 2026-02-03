# HALF-BROKEN: cannot remove system kwallet and polkit packages, data loss in browsers
{ lib, pkgs, ... }:

{
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    kwallet # provides helper service
    kwallet-pam # provides helper service
    kwalletmanager
    polkit-kde-agent-1
    konsole
    xwaylandvideobridge
  ];

  services.orca.enable = false; # screen reader
  security.pam.services.login.kwallet.enable = lib.mkForce false;
  security.pam.services.kde.kwallet.enable = lib.mkForce false;
}
