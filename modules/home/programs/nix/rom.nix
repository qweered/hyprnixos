{ pkgs, ... }:

{
  # pretty rebuild output — rom, a Rust nix-output-monitor replacement.
  #
  # `nom-rom-shim` (defined in modules/system/overlays.nix) ships rom under the
  # binary name `nom`, so anything resolving `nom` from PATH gets rom. nh is
  # handled in that same overlay: it bakes nix-output-monitor into its own
  # wrapper PATH, which would shadow this user-PATH shim, so nh's baked-in
  # dependency is repointed at rom directly there.
  home.packages = with pkgs; [
    rom
    nom-rom-shim
  ];
}
