{
  pkgs,
  config,
  lib,
  ...
}:

{
  # Enabled only on non-rt kernels: the rt-bore (PREEMPT_RT) kernel cannot load
  # scx schedulers (BPF struct_ops attach fails with EOPNOTSUPP).
  # See https://github.com/xddxdd/nix-cachyos-kernel/issues/83
  services.scx = {
    enable = !lib.hasInfix "-rt" config.boot.kernelPackages.kernel.name;
    package = pkgs.scx.rustscheds;
    # Lest use default for now understand what is better for my system
    # scheduler = "scx_lavd";
  };
}
