# Bulk updater for the packages under pkgs/.
#
# Each package carries its own `passthru.updateScript` (a nix-update command,
# see pkgs/*/package.nix). This runs that script per package against the flake,
# so per-package update policy is honoured automatically — e.g. rom pins
# `--version=branch` to track its unstable main branch while a package without
# extra args just follows its latest release.
#
#   nix run .#update-pkgs                # update every package under pkgs/
#   nix run .#update-pkgs -- rom         # update only the named package(s)
#   nix run .#update-pkgs -- --commit    # forward extra flags to nix-update
#
# The package set is discovered from the flake's own `legacyPackages` (the
# pkgs-by-name output), so new packages are picked up with no wiring here.
_: {
  perSystem =
    {
      pkgs,
      system,
      lib,
      ...
    }:
    let
      update-pkgs = pkgs.writeShellApplication {
        name = "update-pkgs";
        runtimeInputs = [
          pkgs.nix
          pkgs.jq
          pkgs.git
        ];
        text = ''
          cd "$(git rev-parse --show-toplevel)"

          # Separate package-name arguments from pass-through flags (anything
          # starting with a dash is forwarded to nix-update, e.g. --commit).
          names=()
          passthru=()
          for arg in "$@"; do
            case "$arg" in
              -*) passthru+=("$arg") ;;
              *) names+=("$arg") ;;
            esac
          done

          # No names given → update every package exposed under pkgs/.
          if [ "''${#names[@]}" -eq 0 ]; then
            mapfile -t names < <(
              nix eval --json ".#legacyPackages.${system}" --apply builtins.attrNames | jq -r '.[]'
            )
          fi

          echo ">>> updating: ''${names[*]}"
          rc=0
          for name in "''${names[@]}"; do
            echo
            echo "==> $name"
            # A package's updateScript is a nix-update command list, e.g.
            # [ "…/nix-update" "--version=branch" ]. Run it against the flake attr.
            mapfile -t cmd < <(
              nix eval --json ".#legacyPackages.${system}.$name.updateScript" | jq -r '.[]'
            )
            if [ "''${#cmd[@]}" -eq 0 ]; then
              echo "    (no updateScript — skipping)"
              continue
            fi
            if ! "''${cmd[@]}" ''${passthru[@]+"''${passthru[@]}"} --flake "$name"; then
              rc=1
              echo "    !! update failed for $name"
            fi
          done
          exit "$rc"
        '';
      };
    in
    {
      apps.update-pkgs = {
        type = "app";
        program = lib.getExe update-pkgs;
      };
    };
}
