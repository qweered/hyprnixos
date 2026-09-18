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
    (final: prev: {
      nurl = prev.nurl.override { nix = config.nix.package; };
      nix-output-monitor = prev.nix-output-monitor.overrideAttrs (_: {
        version = "2.2.0+pr313-0825c28";
        src = final.fetchzip {
          url = "https://github.com/xokdvium/nix-output-monitor/archive/0825c28af5a8576de1ea48e77336809756eadb84.tar.gz";
          hash = "sha256-ZIkZO0xiczYXiEAySQiUNww1AHd4kV187WdubkpPxwA=";
        };
      });
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
