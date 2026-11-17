{ config, lib, ... }:

{
  # Enabled only on non-rt kernels: the rt-bore (PREEMPT_RT) kernel cannot load
  # scx schedulers (BPF struct_ops attach fails with EOPNOTSUPP).
  # See https://github.com/xddxdd/nix-cachyos-kernel/issues/83
  services.scx-loader = {
    enable = !lib.hasInfix "-rt" config.boot.kernelPackages.kernel.name;
    config.default_sched = "scx_bpfland";
  };
}
