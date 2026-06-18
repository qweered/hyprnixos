{
  # CONFIG: need to run
  # sudo virsh net-autostart default (2026: may be not needed now)
  # on each new nixos machine, setup it in nixos way
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
}
