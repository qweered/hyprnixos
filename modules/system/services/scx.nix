{ pkgs, ... }:

{
  # sched-ext schedulers
  # Disabled: the rt-bore (PREEMPT_RT) kernel cannot load scx schedulers
  # (BPF struct_ops attach fails with EOPNOTSUPP).
  # See https://github.com/xddxdd/nix-cachyos-kernel/issues/83
  services.scx = {
    enable = false;
    package = pkgs.scx.rustscheds;
    # Lest use default for now understand what is better for my system
    # scheduler = "scx_lavd";
  };
}
