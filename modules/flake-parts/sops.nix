# Single source of truth for sops recipients is the nix config:
# a host is a recipient by dropping its /etc/ssh/ssh_host_ed25519_key.pub into
# modules/hosts/<name>/, and hosts enable users via `hyprnixos.users.<name>.enable`.
#
#   nix run .#sops-sync   regenerate .sops.yaml + re-wrap all secret files
#
# A pre-commit hook runs the same sync when the committed .sops.yaml drifts from
# the config, then fails the commit so the result is reviewed and staged.
{ config, lib, ... }:
let
  adminPgpKeys = [ "4D3C1993340D0ACEF6AF1903CACB28BA93CE71A2" ]; # qweered
  hosts = lib.mapAttrs (_: host: host.config.hyprnixos) config.flake.nixosConfigurations;
  hostPub = name: ../hosts + "/${name}/ssh_host_ed25519_key.pub";
  userNames = lib.attrNames (lib.head (lib.attrValues hosts)).users;
in
{
  perSystem =
    { pkgs, ... }:
    let
      ageOf = name: "age1-placeholder-${name}";
      hostKeys = lib.mapAttrsToList (name: _: ageOf name);
      enablingHostKeys = user: hostKeys (lib.filterAttrs (_: cfg: cfg.users.${user}.enable) hosts);

      rule = path: keys: {
        path_regex = "secrets/${path}\\.yaml$";
        pgp = adminPgpKeys;
        age = lib.naturalSort keys;
      };

      sopsConfig.creation_rules =
        # every host needs these
        [ (rule "common" (hostKeys hosts)) ]
        # per user: only the hosts that enable them
        ++ lib.map (user: rule "users/${user}" (enablingHostKeys user)) userNames
        # per host: only that host
        ++ lib.mapAttrsToList (name: _: rule "hosts/${name}" [ (ageOf name) ]) hosts;

      header = "# Generated from the nix config (modules/flake-parts/sops.nix) — do not edit.\n# Change host/user options instead and run: nix run .#sops-sync\n";
      configFile = (pkgs.formats.yaml { }).generate "sops.yaml" sopsConfig;
      render = pkgs.runCommand ".sops.yaml" { nativeBuildInputs = [ pkgs.ssh-to-age ]; } ''
        { printf '%s' ${lib.escapeShellArg header}; cat ${configFile}; } > $out
        ${lib.concatMapStringsSep "\n" (name: ''
          substituteInPlace $out --replace-fail '${ageOf name}' "$(ssh-to-age < ${hostPub name})"
        '') (lib.attrNames hosts)}
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

      # Re-wrapping needs a decryption key, so on a machine without the admin
      # key this fails partway. That is safe: .sops.yaml is regenerated first,
      # only secrets/ is left behind, and the next sync finishes the job.
      sops-config-sync = pkgs.writeShellApplication {
        name = "sops-config-sync";
        runtimeInputs = [ pkgs.git ];
        text = ''
          cd "$(git rev-parse --show-toplevel)"
          if diff -u --label .sops.yaml --label .sops.yaml.new .sops.yaml ${render}; then
            exit 0
          fi
          echo "sops-config: .sops.yaml drifted from the nix config, syncing..." >&2
          if ! ${lib.getExe sops-sync}; then
            echo "sops-config: re-wrapping secrets/ failed -- no decryption key on this machine?" >&2
            echo "sops-config: .sops.yaml is already regenerated; git add it, and run 'nix run .#sops-sync' where the admin key lives to finish secrets/." >&2
            exit 1
          fi
          echo "sops-config: synced. Review the diff above, git add, and commit again." >&2
          exit 1
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
        entry = lib.getExe sops-config-sync;
        # every input the rendered recipient lists are derived from: the admin
        # pgp keys here, host *.pub files, and `users.<name>.enable`
        files = "^(\\.sops\\.yaml|modules/flake-parts/sops\\.nix|modules/(users|hosts)/.*\\.(nix|pub))$";
        pass_filenames = false;
      };
    };
}
