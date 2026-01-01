{ inputs, pkgs, ... }:

{
  # TODO: move to assets github
  services.easyeffects = {
    enable = true;
    preset = "Perfect EQ";
  };

  home.file = {
    ".config/easyeffects/irs" = {
      recursive = true;
      source = "${inputs.easyeffects-presets}/irs";
    };

    ".config/easyeffects/output" = {
      recursive = true;
      source = pkgs.symlinkJoin {
        name = "easyeffects-output";
        paths = [ "${inputs.easyeffects-presets}" ];
      };

      # Remove extra files present in the presets repos
      onChange = ''
        find $HOME/.config/easyeffects/output/irs -delete
        find $HOME/.config/easyeffects/output -type l -not -name "*.json" -delete
      '';
    };
  };
}
