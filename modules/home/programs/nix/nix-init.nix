{
  # create new nix packages
  programs.nix-init = {
    enable = true;
    settings = {
      maintainers = [ "qweered" ];
    };
  };
}
