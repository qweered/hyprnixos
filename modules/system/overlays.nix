{
  config,
  inputs,
  ...
}:
let
  llm-agents = inputs.llm-agents.packages.${config.hyprnix.hostPlatform};
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
      nixpkgs-review = prev.nixpkgs-review.override { nix = config.nix.package; };
      nix-update = prev.nix-update.override { nix = config.nix.package; };
      nix-direnv = prev.nix-direnv.override { nix = config.nix.package; };
      inherit (llm-agents)
        opencode
        claude-code
        kilocode-cli
        codex
        ;
      amp-cli = llm-agents.amp;
    })
  ];
}
