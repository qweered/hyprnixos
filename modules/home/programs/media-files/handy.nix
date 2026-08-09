{ pkgs, ... }:
{
  home.packages = [
    pkgs.handy # tts, over voxtype
    # TODO: upstream to handy package:
    pkgs.wtype # enter text programatically on wayland
  ];
}
