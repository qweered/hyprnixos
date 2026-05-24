{ pkgs, lib, ... }:

let
  busyboxDisabledApplets = [
    # inetutils owns these commands in the system profile.
    "DNSDOMAINNAME"
    "IFCONFIG"
    "LOGGER"
    "PING"
    "PING6"
    "TELNET"
    "TFTP"
    "TRACEROUTE"
    "WHOIS"

    # Core system packages own these commands.
    "DMESG" # util-linux
    "FSCK" # util-linux
    "GETTY" # util-linux
    "HALT" # systemd
    "INIT" # systemd
    "KILL" # util-linux
    "KILLALL" # procps
    "LOGIN" # shadow
    "MKSWAP" # util-linux
    "MOUNT" # util-linux
    "PASSWD" # shadow
    "PIVOT_ROOT" # util-linux
    "POWEROFF" # systemd
    "REBOOT" # systemd
    "SU" # shadow
    "SULOGIN" # util-linux
    "SWAPOFF" # util-linux
    "SWAPON" # util-linux
    "SWITCH_ROOT" # util-linux
    "UMOUNT" # util-linux
    "VLOCK" # shadow

    # Not provided by busybox in this system profile.
    "KLOGD"
    "SYSLOGD"
  ];
in
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
        # Prevent busybox from exporting applets already owned by full packages.
        extraConfig = lib.concatMapStrings (opt: "CONFIG_${opt} n\n") busyboxDisabledApplets;
      }
    ))
  ];
}
