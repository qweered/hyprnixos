{ inputs, ... }:

{
  imports = [ inputs.illogical-flake.homeManagerModules.default ];

  programs.illogical-impulse.enable = true;

}
