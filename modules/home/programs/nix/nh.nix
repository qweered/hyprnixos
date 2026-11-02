{ user, ... }:

{
  programs.nh = {
    enable = true;
    flake = user.flakeDirectory;
  };

  home.sessionVariables.NH_ASK = 1;

  # TODO(dendritic): auto-optimise-store = false; in this file
}
