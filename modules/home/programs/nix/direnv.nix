{ inputs, ... }:

{
  imports = [ inputs.direnv-instant.homeModules.direnv-instant ];

  # also enables direnv and nix-direnv
  programs.direnv-instant.enable = true;

  programs.direnv = {
    silent = true;
    config = {
      global = {
        warn_timeout = "60s";
        strict_env = true; # will become default
        hide_env_diff = true;
      };
    };
  };
}
