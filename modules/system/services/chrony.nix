{ lib, config, ... }:
{
  # https://discourse.nixos.org/t/i-can-unbloat-systemd/74021/4
  services = {
    timesyncd.enable = false;
    chrony.enable = true;
  };

  # work around https://github.com/NixOS/nixpkgs/issues/445035
  systemd.tmpfiles.rules = lib.mkAfter [ "z ${config.services.chrony.directory}/chrony.keys 0640 root chrony - -" ];
}
