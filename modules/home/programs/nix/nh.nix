{ vars, ... }:

{
  programs.nh = {
    enable = true;
    flake = vars.flakeDirectory;
    clean = {
      enable = true;
      dates = "monthly";
      extraArgs = "--optimise --keep 3";
    };
  };
}
