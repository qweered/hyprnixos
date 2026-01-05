{ vars, ... }:

{
  programs.nh = {
    enable = true;
    flake = "/home/${vars.username}/hyprnixos";
    clean = {
      enable = true;
      dates = "monthly";
      extraArgs = "--optimise --keep 3";
    };
  };
}
