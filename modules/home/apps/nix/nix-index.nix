{ inputs, ... }:

{
  imports = [ inputs.nix-index-database.homeModules.nix-index ];
  programs.nix-index.enable = true;

  home.sessionVariables = {
    NIX_AUTO_RUN = "1";
  };
}
