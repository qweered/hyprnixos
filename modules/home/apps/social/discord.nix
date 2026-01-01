{ inputs, ... }:
{
  imports = [ inputs.nixcord.homeModules.nixcord ];

  # CONFIG
  programs.nixcord = {
    enable = true;
    discord.enable = false;
    vesktop.enable = true;
  };
}
