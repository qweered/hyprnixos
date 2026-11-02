{ inputs, ... }:

{
  imports = [ inputs.nix-index-database.homeModules.nix-index ];
  programs = {
    nix-index.enable = true;
    nix-index-database.comma.enable = true; # costs nothing
  };

  home.sessionVariables.NIX_AUTO_RUN = 1; # TODO: nicer ui, like in nixpkgs command-not-found
}
