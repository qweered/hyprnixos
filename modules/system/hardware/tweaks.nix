{
  # Use kyber scheduler for nvme devices
  hardware.block.scheduler = {
    "nvme[0-9]*" = "kyber";
  };

  # Dynamic swap file and swap in zram
  services.swapspace.enable = true;
  zramSwap.enable = true;
}
