{ pkgs, ... }:
{
  # file manager from kde
  home.packages = with pkgs.kdePackages; [ dolphin ];
}
