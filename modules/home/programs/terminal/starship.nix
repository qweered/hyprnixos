{
  # NOTE: very slow performance in nixpkgs: https://github.com/dmmulroy/jj-starship/issues/17
  # home.packages = [ pkgs.jj-starship ];
  # programs.starship.settings = {
  #   custom.jj = {
  #     when = "jj-starship detect";
  #     shell = [ "jj-starship" ];
  #     format = "$output ";
  #     ignore_timeout = true;
  #   };
  #   git_branch = {
  #     disabled = true;
  #   };
  #   git_status = {
  #     disabled = true;
  #   };
  # };

  # CONFIG
  programs.starship.enable = true;
}
