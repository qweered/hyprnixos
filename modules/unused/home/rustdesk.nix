{ pkgs, ... }:
{
  # over anydesk, teamviewer, rustdesk (bad gui)
  home.packages = [ pkgs.rustdesk-flutter ];
}
