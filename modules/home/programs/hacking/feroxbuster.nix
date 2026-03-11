{ pkgs, ... }:
{
  # Enumerate directories, over gobuster
  home.packages = [ pkgs.feroxbuster ];
}
