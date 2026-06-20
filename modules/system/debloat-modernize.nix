{ lib, ... }:

{
  # Perlless https://github.com/NixOS/nixpkgs/blob/0260f927b7c1578b5c7cdefd7db7b660565cd362/nixos/modules/profiles/perlless.nix
  # TODO: Check that the system does not contain a Nix store path that contains the string "perl".
  # system.forbiddenDependenciesRegexes = [ "perl" ];

  # Remove unnecessary packages
  environment.defaultPackages = lib.mkForce [ ];
  programs.nano.enable = false;
  services.speechd.enable = false;

  documentation = {
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  # If /etc is read-only, we need to provide the machine-id file as a mount point for systemd.
  # https://www.freedesktop.org/software/systemd/man/256/machine-id.html#Initialization
  # environment.etc."machine-id".text = "";
  # system.etc.overlay.enable = true; # multiple errors for now

  systemd.enableStrictShellChecks = true; # CONFIG: will become default
}
