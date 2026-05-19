{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # TODO: replace ancient utils systemwide in nixpkgs
    uutils-coreutils-noprefix
    # TODO: enable once stable enough
    #uutils-diffutils
    #uutils-findutils
    #uutils-util-linux
    #uutils-login
    #uutils-sed
    #uutils-tar
    #uutils-hostname
    #uutils-procps
    # for ftp
    (lib.lowPrio inetutils)
    iw
    # various utils
    (lib.lowPrio (
      busybox.override {
        # Prevent busybox from overriding system binaries (systemd, util-linux, shadow, etc.)
        extraConfig = lib.concatMapStrings (opt: "CONFIG_${opt} n\n") [
          "HALT"
          "POWEROFF"
          "REBOOT"
          "INIT"
          "LOGIN"
          "SU"
          "SULOGIN"
          "GETTY"
          "PASSWD"
          "VLOCK"
          "MOUNT"
          "UMOUNT"
          "DMESG"
          "KILL"
          "KILLALL"
          "SYSLOGD"
          "KLOGD"
          "FSCK"
          "MKSWAP"
          "SWAPON"
          "SWAPOFF"
          "PIVOT_ROOT"
          "SWITCH_ROOT"
        ];
      }
    ))
  ];
}
