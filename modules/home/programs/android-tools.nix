{ pkgs, ... }:
{
  # debug android devices
  home.packages = [ pkgs.android-tools ];
}
