{ pkgs, ... }:

{
  # sched-ext schedulers
  services.scx = {
    enable = true;
    package = pkgs.scx.rustscheds;
    # Lest use default for now understand what is better for my system
    # scheduler = "scx_lavd";
  };
}
