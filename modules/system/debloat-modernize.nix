{ lib, ... }:

{
  # Perlless https://github.com/NixOS/nixpkgs/blob/0260f927b7c1578b5c7cdefd7db7b660565cd362/nixos/modules/profiles/perlless.nix
  system.disableInstallerTools = true; # remove generate, install, enter, option, version, build-vms, firewall
  system.tools.nixos-rebuild.enable = true; # but keep rebuild
  programs.nano.enable = false;
  services.speechd.enable = false; # NOTE: untested, may break things

  # https://blog.nsrun.io/2026/01/15/systemd-vsock-openssh-server
  systemd.generators.systemd-ssh-generator = "/dev/null";
  systemd.sockets.sshd-unix-local.enable = lib.mkForce false;
  systemd.sockets.sshd-vsock.enable = lib.mkForce false;

  environment.defaultPackages = lib.mkForce [ ];

  documentation = {
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  # TODO: Check that the system does not contain a Nix store path that contains the string "perl".
  # system.forbiddenDependenciesRegexes = [ "perl" ];

  # If /etc is read-only, we need to provide the machine-id file as a mount point for systemd.
  # https://www.freedesktop.org/software/systemd/man/256/machine-id.html#Initialization
  # environment.etc."machine-id".text = "";
  # system.etc.overlay.enable = true; # multiple errors for now

  systemd.enableStrictShellChecks = true; # CONFIG: will become default
  services.dbus.implementation = "broker"; # CONFIG: will become default
}
