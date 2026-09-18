{
  config,
  inputs,
  ...
}:
let
  llm-agents = inputs.llm-agents.packages.${config.hardware.facter.report.system};
in
{
  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
    inputs.self.overlays.pkgs
    (_final: prev: {
      nurl = prev.nurl.override { nix = config.nix.package; };
      nixpkgs-review = prev.nixpkgs-review.override { nix = config.nix.package; };
      nix-update = prev.nix-update.override { nix = config.nix.package; };
      nix-direnv = prev.nix-direnv.override { nix = config.nix.package; };

      inherit (llm-agents)
        claude-code
        kilocode-cli
        codex
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
