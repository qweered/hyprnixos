{ user, ... }:

{
  programs.nh = {
    enable = true;
    flake = user.flakeDirectory;
    clean = {
      enable = true;
      dates = "monthly";
      extraArgs = "--optimise --keep 3 --keep-one --no-direnv --cross-filesystems";
    };
  };

  # TODO(dendritic): auto-optimise-store = false; in this file
}
