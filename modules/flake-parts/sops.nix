# Single source of truth for sops recipients is the nix config:
# a host is a recipient by dropping its ssh_host_ed25519_key.pub into
# modules/hosts/<name>/, and hosts run users by naming them in `hyprnixos.userProfiles`.
#
# That keypair is minted by `nix run .#hostkey <host>`; the private half lives on
# /var/lib, not /etc (see modules/system/security/sops.nix).
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
  userNames = lib.attrNames (lib.mergeAttrsList (lib.catAttrs "users" (lib.attrValues hosts)));
in
{
  perSystem =
    { pkgs, ... }:
    let
      ageOf = name: "age1-placeholder-${name}";
      hostKeys = lib.mapAttrsToList (name: _: ageOf name);
      userHostKeys = user: hostKeys (lib.filterAttrs (_: cfg: cfg.users ? ${user}) hosts);

      rule = path: keys: {
        path_regex = "secrets/${path}\\.yaml$";
        pgp = adminPgpKeys;
        age = lib.naturalSort keys;
      };

      sopsConfig.creation_rules =
        # every host needs these
        [ (rule "common" (hostKeys hosts)) ]
        # per user: only the hosts that run them
        ++ lib.map (user: rule "users/${user}" (userHostKeys user)) userNames
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

      # Where a host keeps the private half. Read off a host config rather than
      # repeated here: every host sets it from modules/system/security/sops.nix.
      hostKeyPath = lib.head (lib.head (lib.attrValues config.flake.nixosConfigurations)).config.sops.age.sshKeyPaths;

      # Mint a new machine's identity before installing it. Nothing else creates
      # this key -- services.openssh is off, so there is no sshd-keygen unit --
      # and a host that cannot decrypt has no password hash on first boot.
      hostkey = pkgs.writeShellApplication {
        name = "hostkey";
        runtimeInputs = [
          pkgs.openssh
          pkgs.ssh-to-age
          pkgs.git
        ];
        text = ''
          host="''${1:-}"
          if [ -z "$host" ]; then
            echo "usage: hostkey <host>   # mint ${hostKeyPath} and stage its .pub" >&2
            exit 1
          fi

          if [ -e "${hostKeyPath}" ]; then
            echo ">>> ${hostKeyPath} already exists, reusing it"
          else
            echo ">>> Generating ${hostKeyPath}"
            sudo install -d -m 0755 "$(dirname "${hostKeyPath}")"
            sudo ssh-keygen -t ed25519 -N "" -C "$host" -f "${hostKeyPath}"
          fi

          dir="$(git rev-parse --show-toplevel)/modules/hosts/$host"
          mkdir -p "$dir"
          sudo cp "${hostKeyPath}.pub" "$dir/ssh_host_ed25519_key.pub"
          sudo chmod 0644 "$dir/ssh_host_ed25519_key.pub"

          echo ">>> Staged $dir/ssh_host_ed25519_key.pub"
          echo ">>> age recipient: $(ssh-to-age < "$dir/ssh_host_ed25519_key.pub")"
          echo ">>>"
          echo ">>> Next, where the admin PGP key lives:"
          echo ">>>   nix run .#sops-sync   # re-wrap secrets/ to include this host"
          echo ">>>   git add -A && git commit"
          echo ">>> Only then can this host decrypt anything."
        '';
      };

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

      # nix run <flake>#hostkey -- <host>
      apps.hostkey = {
        type = "app";
        program = lib.getExe hostkey;
      };

      pre-commit.settings.hooks.sops-config = {
        enable = true;
        entry = lib.getExe sops-config-sync;
        # every input the rendered recipient lists are derived from: the admin
        # pgp keys here, host *.pub files, and `hyprnixos.userProfiles`
        files = "^(\\.sops\\.yaml|modules/flake-parts/sops\\.nix|modules/(users|hosts)/.*\\.(nix|pub))$";
        pass_filenames = false;
      };
    };
}
