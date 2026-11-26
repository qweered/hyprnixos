{ inputs, lib, ... }:

{
  imports = [ inputs.cade.nixosModules.default ];

  programs.cade = {
    enable = true;
    enableFishIntegration = false; # https://github.com/manic-systems/cade/issues/83
  };

  programs.fish.interactiveShellInit = lib.mkAfter ''
    cade hook fish | string replace -- ' --wait' "" | source
  '';
}
