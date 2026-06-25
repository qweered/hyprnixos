{
  cfg,
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.vicinae.homeManagerModules.default ];
  disabledModules = [ "programs/vicinae.nix" ]; # use flake module instead

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

    extensions = with inputs.vicinae-extensions.packages.${cfg.hostPlatform}; [
      bluetooth
      # over manix, nix-search-tv
      nix
      wifi-commander
      # Does not work with tlp
      # power-profile
    ];
  };
}
