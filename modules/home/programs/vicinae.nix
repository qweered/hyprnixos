{ inputs, pkgs, ... }:
{
  imports = [ inputs.vicinae.homeManagerModules.default ];
  disabledModules = [ "programs/vicinae.nix" ]; # to be sure that we don't use it

  services.vicinae = {
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

    extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
      bluetooth
      # over manix, nix-search-tv
      nix
      wifi-commander
      # Does not work with tlp
      # power-profile
    ];
  };
}
