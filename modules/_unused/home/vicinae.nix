{ pkgs, ... }:
{
  programs.vicinae = {
    enable = true;
    package = pkgs.vicinae;
    systemd.enable = true;
    settings = {
      close_on_focus_loss = true;
      providers = {
        "@Gelei/bluetooth-0" = {
          preferences = {
            connectionToggleable = true;
          };
        };
        "applications" = {
          preferences = {
            launchPrefix = "uwsm app -- ";
          };
        };
      };
    };

    extensions = with pkgs.vicinae-extensions; [
      # over manix, nix-search-tv
      nix
      wifi-commander
      bluetooth
      # Needs power-profiles-daemon, which tlp.nix disables in favor of tlp
      # power-profile
    ];
  };
}
