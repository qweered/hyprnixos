{ vars, ... }:

{
  programs.nh = {
    enable = true;
    flake = "/home/${vars.username}/hyprnixos";
    clean = {
      enable = true;
      dates = "monthly";
      # keep direnv gc roots younger than 7 days
      extraArgs = "--optimise --keep 3 --keep-since 7d";
    };
  };
}
