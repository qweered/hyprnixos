{
  config,
  inputs,
  ...
}:
let
  llm-agents = inputs.llm-agents.packages.${config.hyprnixos.hostPlatform};
in
{
  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
    inputs.nix-output-monitor.overlays.default
    inputs.self.overlays.pkgs
    (final: prev: {
      nurl = prev.nurl.override { nix = config.nix.package; };
      nixpkgs-review = prev.nixpkgs-review.override { nix = config.nix.package; };
      nix-update = prev.nix-update.override { nix = config.nix.package; };
      nix-direnv = prev.nix-direnv.override { nix = config.nix.package; };

      # rom shipped under the literal binary name `nom`. Anything that resolves
      # `nom` from PATH (or a build monitor argument) then renders with rom.
      # (The "evaluating file" spam under nh is fixed in rom itself — see
      # pkgs/rom/filter-json-msg-passthrough.patch.)
      nom-rom-shim = prev.writeShellScriptBin "nom" ''
        exec ${prev.lib.getExe final.rom} "$@"
      '';

      # nh (4.x) has no flag to pick a build monitor: it hard-codes `nom --json`
      # and its wrapper bakes nix-output-monitor's bin into nh's PATH via
      # `--prefix`, which *prepends* — so a `nom` shim merely on the user PATH is
      # always shadowed. Repoint that baked-in dependency at rom so `nh os switch`
      # / nh-update render with rom. See modules/home/programs/nix/rom.nix.
      nh = prev.nh.override { nix-output-monitor = final.nom-rom-shim; };

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
