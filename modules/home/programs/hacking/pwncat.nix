{ pkgs, ... }:
{
  # Reverse shell, over netcat
  home.packages = [ pkgs.pwncat ];
}
