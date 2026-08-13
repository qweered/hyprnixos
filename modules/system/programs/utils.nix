{ pkgs, lib, ... }:
let
  busyboxConfig = {
    ASCII = "y";
    BC = "y";
    DEVMEM = "y";
    DOS2UNIX = "y";
    HEXEDIT = "y";
    KILLALL = "y";
    LZOP = "y";
    MICROCOM = "y";
    NMETER = "y";
    TTYSIZE = "y";
    UNIX2DOS = "y";

    # To not reprompt `make oldconfig`
    SH_IS_ASH = "n";
    SH_IS_HUSH = "n";
    SH_IS_NONE = "y";
  };
in
{
  environment.systemPackages = with pkgs; [
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
    usbutils # lsusb
    pciutils # lspci, setpci
    iw
    lsof
    (lib.lowPrio inetutils) # for ftp and telnet
    (lib.lowPrio (
      busybox.override {
        enableMinimal = true;
        extraConfig = lib.concatStrings (lib.mapAttrsToList (opt: val: "CONFIG_${opt} ${val}\n") busyboxConfig);
      }
    ))
  ];
}
