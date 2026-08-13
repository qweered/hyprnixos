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
  hostKeys = lib.mapAttrsToList (_: cfg: cfg.hostAgeKey);

  # every host declares every profile (entrypoint.nix), so one answers for the
  # whole set and for each user's own key
  anyHost = lib.head (lib.attrValues hosts);
  userNames = lib.attrNames anyHost.users;
  personalKey = user: anyHost.users.${user}.ageKey;
  enablingHostKeys = user: hostKeys (lib.filterAttrs (_: cfg: cfg.users.${user}.enable) keyedHosts);

  rule = path: keys: {
    path_regex = "secrets/${path}\\.yaml$";
    pgp = adminPgpKeys;
    age = lib.naturalSort (lib.filter (key: key != null) keys);
  };

  sopsConfig.creation_rules =
    # every host needs these
    [ (rule "common" (hostKeys keyedHosts)) ]
    # per user: their own key + only the hosts that enable them
    ++ lib.map (user: rule "users/${user}" ([ (personalKey user) ] ++ enablingHostKeys user)) userNames
    # per host: only that host
    ++ lib.mapAttrsToList (name: cfg: rule "hosts/${name}" [ cfg.hostAgeKey ]) keyedHosts;
in
{
  perSystem =
    { pkgs, ... }:
    let
      header = "# Generated from the nix config (modules/flake-parts/sops.nix) — do not edit.\n# Change host/user options instead and run: nix run .#sops-sync\n";
      configFile = (pkgs.formats.yaml { }).generate "sops.yaml" sopsConfig;
      render = pkgs.runCommand ".sops.yaml" { } ''
        { printf '%s' ${lib.escapeShellArg header}; cat ${configFile}; } > $out
      '';

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
    in
    {
      apps.sops-sync = {
        type = "app";
        program = lib.getExe sops-sync;
      };

      pre-commit.settings.hooks.sops-config = {
        enable = true;
        entry = lib.getExe sops-config-check;
        files = "^(\\.sops\\.yaml|modules/(users|hosts)/.*\\.nix)$";
        pass_filenames = false;
      };
    };
}
