{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kubectl
    krew
  ];

  # krew install radar

  programs.fish.interactiveShellInit = "set -q KREW_ROOT; and set -gx PATH $PATH $KREW_ROOT/.krew/bin; or set -gx PATH $PATH $HOME/.krew/bin";
}
