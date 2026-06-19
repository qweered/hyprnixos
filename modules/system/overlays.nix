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
    inputs.nix-output-monitor.overlays.default
    (_: prev: {
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
