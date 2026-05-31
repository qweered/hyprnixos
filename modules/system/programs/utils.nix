{ pkgs, lib, ... }:

let
  # Applets are plain on/off toggles, all enabled (y). SH_IS_* is different: it
  # is a kconfig `choice`, not an applet. bash owns sh in this profile, so we
  # pick `none` and must also clear the other arms, else `make oldconfig`
  # re-prompts for the choice and the build hangs.
  busyboxConfig = {
    IPCALC = "y";
    MICROCOM = "y";

    I2CDETECT = "y";
    I2CDUMP = "y";
    I2CGET = "y";
    I2CSET = "y";
    I2CTRANSFER = "y";

    LSPCI = "y";
    LSSCSI = "y";
    LSUSB = "y";

    ASCII = "y";
    DOS2UNIX = "y";
    HEXEDIT = "y";
    LZOP = "y";
    NMETER = "y";
    TTYSIZE = "y";
    UNIX2DOS = "y";

    SH_IS_ASH = "n";
    SH_IS_HUSH = "n";
    SH_IS_NONE = "y";
  };
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
    tree
    # various utils
    (lib.lowPrio (
      busybox.override {
        enableMinimal = true;
        extraConfig = lib.concatStrings (lib.mapAttrsToList (opt: val: "CONFIG_${opt} ${val}\n") busyboxConfig);
      }
    ))
  ];
}
