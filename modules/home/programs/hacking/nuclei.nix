{ pkgs, ... }:
{
  # Scan for vulnerabilities
  home.packages = [ pkgs.nuclei ];
}
