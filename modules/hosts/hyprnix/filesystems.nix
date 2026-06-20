{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-KBG50ZNV256G_KIOXIA_62CPGFT7QXQ5";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          label = "ESP";
          size = "2G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [
              "fmask=0077"
              "dmask=0077"
            ];
          };
        };
        root = {
          label = "root";
          size = "100%";
          content = {
            type = "filesystem";
            format = "xfs";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
