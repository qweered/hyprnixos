# Single source of truth for sops recipients is the nix config:
# hosts declare `hyprnixos.hostAgeKey`, hosts enable users via
# `hyprnixos.users.<name>.enable`, users may declare a personal
# `hyprnixos.users.<name>.ageKey`. This module derives .sops.yaml from that.
#
#   nix run .#sops-sync   regenerate .sops.yaml + re-wrap all secret files
#
# A pre-commit hook fails when the committed .sops.yaml drifts from the config.
{ config, lib, ... }:
let
  adminPgpKeys = [ "4D3C1993340D0ACEF6AF1903CACB28BA93CE71A2" ]; # qweered

  hosts = lib.mapAttrs (_: host: host.config.hyprnixos) config.flake.nixosConfigurations;
  # hosts without a declared key are on no recipient list
  keyedHosts = lib.filterAttrs (_: cfg: cfg.hostAgeKey != null) hosts;
  userNames = lib.map (lib.removeSuffix ".nix") (lib.attrNames (builtins.readDir ../users));

  # user profiles are shared, so any host can answer for a user's own key
  personalKey = user: (lib.head (lib.attrValues hosts)).users.${user}.ageKey;
  enablingHostKeys = user: lib.mapAttrsToList (_: cfg: cfg.hostAgeKey) (lib.filterAttrs (_: cfg: cfg.users.${user}.enable) keyedHosts);

  sopsConfig = {
    creation_rules =
      # secrets every host needs
      [
        {
          path_regex = "secrets/common\\.yaml$";
          pgp = adminPgpKeys;
          age = lib.naturalSort (lib.mapAttrsToList (_: cfg: cfg.hostAgeKey) keyedHosts);
        }
      ]
      # per-user secrets: the user's own key + only hosts that enable the user
      ++ lib.map (user: {
        path_regex = "secrets/users/${user}\\.yaml$";
        pgp = adminPgpKeys;
        age = lib.naturalSort (lib.filter (key: key != null) ([ (personalKey user) ] ++ enablingHostKeys user));
      }) userNames
      # per-host secrets: only that host
      ++ lib.mapAttrsToList (name: cfg: {
        path_regex = "secrets/hosts/${name}\\.yaml$";
        pgp = adminPgpKeys;
        age = [ cfg.hostAgeKey ];
      }) keyedHosts;
  };
in
{
  perSystem =
    { pkgs, config, ... }:
    let
      header = "# Generated from the nix config (modules/flake-parts/sops.nix) — do not edit.\n# Change host/user options instead and run: nix run .#sops-sync\n";
      configFile = (pkgs.formats.yaml { }).generate "sops.yaml" sopsConfig;
      render = pkgs.runCommand ".sops.yaml" { } ''
        { printf '%s' ${lib.escapeShellArg header}; cat ${configFile}; } > $out
      '';
    in
    {
      packages = {
        sops-sync = pkgs.writeShellApplication {
          name = "sops-sync";
          runtimeInputs = [
            pkgs.git
            pkgs.sops
          ];
          text = ''
            cd "$(git rev-parse --show-toplevel)"
            install -m 644 ${render} .sops.yaml
            find secrets -type f -name '*.yaml' -print0 | while IFS= read -r -d "" file; do
              sops updatekeys -y "$file"
            done
          '';
        };
        sops-config-check = pkgs.writeShellApplication {
          name = "sops-config-check";
          runtimeInputs = [ pkgs.git ];
          text = ''
            cd "$(git rev-parse --show-toplevel)"
            if ! diff -u .sops.yaml ${render}; then
              echo ".sops.yaml is out of sync with the nix config, run: nix run .#sops-sync" >&2
              exit 1
            fi
          '';
        };
      };

      pre-commit.settings.hooks.sops-config = {
        enable = true;
        entry = lib.getExe config.packages.sops-config-check;
        files = "^(\\.sops\\.yaml|modules/(users|hosts)/.*\\.nix)$";
        pass_filenames = false;
      };
    };
}
