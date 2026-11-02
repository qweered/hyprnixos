{ inputs, config, ... }:
{
  programs.tack = {
    enable = true;
    nixConfTokens = true;
    package = inputs.tack.packages.${config.hardware.facter.report.system}.tack;
  };
}
