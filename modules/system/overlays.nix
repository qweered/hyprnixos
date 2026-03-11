{
  config,
  inputs,
  pkgs,
  ...
}:
let
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  # TODO: why overlays don't work in flake-parts?
  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
    (_: prev: {
      nix-output-monitor = prev.nix-output-monitor.overrideAttrs (_: {
        src = prev.fetchFromGitHub {
          owner = "maralorn";
          repo = "nix-output-monitor";
          rev = "4c34e115ab344df485316d4a61768b8d561fbeb3";
          hash = "sha256-CcdGDNLkCsncYI+S5O71YgxQm2XLD8zPiDQQIebEdJ0=";
        };
      });
      nurl = prev.nurl.override { nix = config.nix.package; };
      nix-init = prev.nix-init.override { nix = config.nix.package; };
      inherit (llm-agents) opencode claude-code kilocode-cli;
      codex = llm-agents.code; # community fork
      amp-cli = llm-agents.amp;
    })
  ];
}
