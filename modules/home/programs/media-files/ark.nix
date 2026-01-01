{ pkgs, ... }:
{
  # archive manager from kde
  home.packages = with pkgs.kdePackages; [ ark ];
}
