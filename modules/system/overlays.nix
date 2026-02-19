{ config, ... }:
{
  # TODO: why overlays don't work in flake-parts?
  nixpkgs.overlays = [
    (_final: prev: {
      nix-output-monitor = prev.nix-output-monitor.overrideAttrs (_old: {
        src = prev.fetchFromGitHub {
          owner = "maralorn";
          repo = "nix-output-monitor";
          rev = "4c34e115ab344df485316d4a61768b8d561fbeb3";
          hash = "sha256-CcdGDNLkCsncYI+S5O71YgxQm2XLD8zPiDQQIebEdJ0=";
        };
      });
      nurl = prev.nurl.override { nix = config.nix.package; };
      nix-init = prev.nix-init.override { nix = config.nix.package; };
    })
  ];
}
