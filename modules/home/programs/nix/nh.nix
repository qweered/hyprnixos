{ user, ... }:

{
  programs.nh = {
    enable = true;
    flake = user.flakeDirectory;
  };

  # TODO(dendritic): auto-optimise-store = false; in this file
}
