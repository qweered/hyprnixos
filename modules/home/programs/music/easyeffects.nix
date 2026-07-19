{ pkgs, ... }:

let
  presets = pkgs.fetchFromGitHub {
    name = "easyeffects-presets-jackhack96";
    owner = "jackhack96";
    repo = "easyeffects-presets";
    rev = "d77a61eb01c36e2c794bddc25423445331e99915";
    hash = "sha256-or5kH/vTwz7IO0Vz7W4zxK2ZcbL/P3sO9p5+EdcC2DA=";
  };
  presets2 = pkgs.fetchFromGitHub {
    name = "easyeffects-presets-digitalone1";
    owner = "Digitalone1";
    repo = "EasyEffects-Presets";
    rev = "347dc4dd0ada677a15db2676cd9a5082e2f0033a";
    hash = "sha256-DHuYj9IynIhjdEdISiBObauvVPbahcmzSmwhdr6puUU=";
  };
in
{
  services.easyeffects = {
    enable = true;
    preset = "LoudnessEqualizer";
  };

  home.file = {
    ".local/share/easyeffects/irs" = {
      recursive = true;
      source = "${presets}/irs";
    };

    ".local/share/easyeffects/output" = {
      recursive = true;
      source = pkgs.symlinkJoin {
        name = "easyeffects-output";
        paths = [
          "${presets}"
          "${presets2}"
        ];
      };

      # Remove extra files present in the presets repos
      onChange = ''
        find $HOME/.local/share/easyeffects/output/irs -delete
        find $HOME/.local/share/easyeffects/output -type l -not -name "*.json" -delete
      '';
    };
  };
}
