{
  # clean is deliberately in system to run nh clean all instead of nh clean user
  # TODO: merge into one file in den
  programs.nh.clean = {
    enable = true;
    dates = "weekly";
    extraArgs = "--optimise --keep 3 --keep-one --no-direnv --cross-filesystems";
  };
}
