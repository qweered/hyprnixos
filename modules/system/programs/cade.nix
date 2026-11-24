{ inputs, ... }:

{
  imports = [ inputs.cade.nixosModules.default ];

  programs.cade.enable = true;
}
