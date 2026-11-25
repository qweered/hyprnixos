{
  config,
  inputs,
  ...
}:
let
  inherit (config.hardware.facter.report) system;
  llm-agents = inputs.llm-agents.packages.${system};
in
{
  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
    (_final: prev: {
      # TODO: nuke even more nix duplicates
      nurl = prev.nurl.override { nix = config.nix.package; };
      nixpkgs-review = prev.nixpkgs-review.override { nix = config.nix.package; };
      nix-update = prev.nix-update.override { nix = config.nix.package; };
      xdg-utils = inputs.xdg-utils-nu.packages.${system}.xdg-utils-nu-uutils;

      inherit (llm-agents)
        antigravity-cli
        claude-code
        codex
        freebuff
        ;

      # opencode v2 (upstream ships only bin/opencode2): expose as
      # pkgs.opencode with a compat `opencode` symlink so the HM module,
      # scripts and muscle memory keep working.
      opencode = llm-agents.opencode2.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          ln -s $out/bin/opencode2 $out/bin/opencode
        '';
        meta = old.meta // {
          mainProgram = "opencode";
        };
      });
    })
  ];
}
