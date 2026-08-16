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

  # /etc becomes a read-only overlayfs generated from the nix config, masking
  # anything install-time that lived on the mutable /etc. Keep such state
  # elsewhere -- e.g. the sops host key on /var/lib, see
  # modules/system/security/sops.nix.
  system.etc.overlay = {
    enable = true;
    mutable = false;
  };

  # TODO: enable upstream cause it rebuild all systemd units
  # systemd.enableStrictShellChecks = true;

  # TODO: enable upstream cause it rebuilds all shell completions
  # programs.fish.useBabelfish = true;
}
