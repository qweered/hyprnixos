{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
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
