{ inputs, lib, ... }:
let
  hostsDir = ./modules/hosts;
  usersDir = ./modules/users;

  # A host is a sub-directory of modules/hosts holding a nixos-facter report: its
  # name becomes the nixosConfiguration (and hostname), and the directory holds
  # that host's private modules. Everything else under modules/ is shared.
  # The report is required because every module reads it unguarded, so a
  # directory without one (new-host) is a template to copy, not a machine.
  hostReport = name: hostsDir + "/${name}/facter.json";
  hostNames = lib.filter (name: builtins.pathExists (hostReport name)) (lib.attrNames (builtins.readDir hostsDir));

  # Same rule for users: modules/users/<name>.nix is a profile *body*, so it
  # never repeats its own name. A host names the ones it runs in
  # `hyprnixos.userProfiles` and only those are imported, so `users` on a host is
  # exactly its user set -- no enable flag, and sops.nix reads the set back off
  # each host rather than re-enumerating the directory.
  userSecretsFile = name: ./secrets/users + "/${name}.yaml";

  # The keys of secrets/users/<name>.yaml a profile asks for, as
  # /run/secrets/<name>/<key> owned by them. Namespaced so two profiles can ask
  # for the same key; `key` stays bare, which is how the per-user yaml is keyed.
  # `password` is always present and is the one the system reads itself, before
  # the user exists: sops-nix puts it in /run/secrets-for-users and forbids a
  # non-root owner there.
  userSecrets =
    name: keys:
    let
      secret =
        key: extra:
        lib.nameValuePair "${name}/${key}" (
          {
            inherit key;
            sopsFile = userSecretsFile name;
          }
          // extra
        );
    in
    lib.listToAttrs ([ (secret "password" { neededForUsers = true; }) ] ++ lib.map (key: secret key { owner = name; }) keys);

  usersModule =
    { cfg, ... }:
    {
      hyprnixos.users = lib.genAttrs cfg.userProfiles (name: import (usersDir + "/${name}.nix"));

      # A user's sops file is encrypted only to the hosts running the profile
      # (see .sops.yaml), which is exactly the set this module is declaring.
      sops.secrets = lib.mergeAttrsList (
        lib.map (name: userSecrets name cfg.users.${name}.secrets) (lib.filter (name: builtins.pathExists (userSecretsFile name)) cfg.userProfiles)
      );
    };

  # A host is the shared system tree plus its own directory -- the rest of
  # modules/ belongs to someone else: home/ to home-manager (imported by
  # system/config.nix), users/ to usersModule, flake-parts/ to the flake.
  mkHost =
    name:
    inputs.nixpkgs-patcher.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      nixpkgsPatcher = {
        inherit inputs;
        enableTroubleshootingShell = false;
      };
      modules = [
        (inputs.import-tree [
          ./modules/system
          (hostsDir + "/${name}")
        ])
        inputs.disko.nixosModules.disko # needed for every host
        usersModule
        {
          # The directory name is the single source of truth for the hostname: it
          # already keys this nixosConfiguration, so deriving networking.hostName
          # from it makes a folder/hostname mismatch impossible by construction.
          networking.hostName = name;
          hardware.facter.reportPath = hostReport name;
        }
      ];
    };
in
{
  imports = [ (inputs.import-tree ./modules/flake-parts) ];

  flake.nixosConfigurations = lib.genAttrs hostNames mkHost;
  systems = inputs.nixpkgs.lib.systems.flakeExposed;

  # TODO: expose options for nixd, needs zed config
  debug = false;
}
