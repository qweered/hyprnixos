{ pkgs, lib, ... }:
let
  # nh (4.x) has no option to pick a different build monitor: it hard-codes
  #   nix build … --log-format internal-json --verbose |& nom --json
  # and resolves the literal binary name `nom` from PATH. rom speaks that exact
  # stdin protocol in `--json` mode, so shipping it under the name `nom` makes
  # `nh os switch` (and friends) render with rom automatically — no nh flags,
  # same as nix-output-monitor did before. Disable per-invocation with --no-nom.
  nom-compat = pkgs.runCommand "nom-rom-shim" { } ''
    mkdir -p $out/bin
    ln -s ${lib.getExe pkgs.rom} $out/bin/nom
  '';
in
{
  # pretty rebuild output — rom, a Rust nix-output-monitor replacement.
  home.packages = [
    pkgs.rom
    nom-compat
  ];
}
