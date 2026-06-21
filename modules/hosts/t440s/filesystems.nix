{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/ata-CT120BX500SSD1_2043E4123822";
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
