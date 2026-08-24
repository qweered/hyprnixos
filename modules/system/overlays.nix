{
  config,
  inputs,
  lib,
  ...
}:
let
  inherit (lib)
    attrNames
    filter
    genAttrs
    last
    match
    naturalSort
    ;
  llm-agents = inputs.llm-agents.packages.${config.hardware.facter.report.system};
in
{
  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
    inputs.self.overlays.pkgs
    (
      _final: prev:
      let
        names = attrNames prev;
        newestElectron = last (naturalSort (filter (n: match "electron_[0-9]+" n != null) names));
      in
      {
        nurl = prev.nurl.override { nix = config.nix.package; };
        nixpkgs-review = prev.nixpkgs-review.override { nix = config.nix.package; };
        nix-update = prev.nix-update.override { nix = config.nix.package; };
        nix-direnv = prev.nix-direnv.override { nix = config.nix.package; };

        inherit (llm-agents)
          opencode
          claude-code
          kilocode-cli
          codex
          oh-my-claudecode
          oh-my-codex
          ;
        amp-cli = llm-agents.amp;
      }
      # Use latest electron everywhere
      // genAttrs (filter (n: match "electron(_[0-9]+)?(-bin)?" n != null && n != "${newestElectron}-bin") names) (_: prev.${newestElectron})
    )
  ];
}
