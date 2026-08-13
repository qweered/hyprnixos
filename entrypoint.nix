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
  hostNames = lib.attrNames (
    lib.filterAttrs (name: type: type == "directory" && builtins.pathExists (hostReport name)) (builtins.readDir hostsDir)
  );

  # Same rule for users: modules/users/<name>.nix is a profile *body*, so it
  # never repeats its own name. Excluded from the import-tree below and handed to
  # every host as one generated module instead. Profiles are declared on every
  # host, so sops.nix reads the set back off a host rather than re-enumerating.
  userNames = lib.map (lib.removeSuffix ".nix") (lib.attrNames (builtins.readDir usersDir));
  userSecret = name: ./secrets/users + "/${name}.yaml";

  usersModule =
    { cfg, ... }:
    {
      hyprnixos.users = lib.genAttrs userNames (name: import (usersDir + "/${name}.nix"));

      # A user's sops file is encrypted only to hosts that enable the profile
      # (see .sops.yaml), so the gate matches what the host can actually
      # decrypt -- declaring these elsewhere would fail at activation.
      # TODO: hosts should import only used users, remove mkIf
      sops.secrets = lib.mkMerge (
        lib.map (
          name:
          lib.mkIf cfg.users.${name}.enable {
            "password-${name}" = {
              sopsFile = userSecret name;
              neededForUsers = true; # provided before user creation
            };
          }
        ) (lib.filter (name: builtins.pathExists (userSecret name)) userNames)
      );
    };

  mkHost =
    name:
    let
      # Drop a file when it is:
      #   - in the home/ or flake-parts/ trees (not host modules), or
      #   - a users/ profile body, supplied by usersModule above, or
      #   - inside another host's private directory.
      exclude =
        path:
        lib.hasInfix "/home/" path
        || lib.hasInfix "/flake-parts/" path
        || lib.hasInfix "/users/" path
        || (lib.hasInfix "/hosts/" path && !lib.hasInfix "/hosts/${name}/" path);

    in
    inputs.nixpkgs-patcher.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      nixpkgsPatcher = {
        inherit inputs;
        enableTroubleshootingShell = false;
      };
      # The directory name is the single source of truth for the hostname: it
      # already keys this nixosConfiguration, so deriving networking.hostName from
      # it makes a folder/hostname mismatch impossible by construction.
      modules = (inputs.import-tree.filterNot exclude ./modules).imports ++ [
        inputs.disko.nixosModules.disko # needed for every host
        usersModule
        {
          networking.hostName = name;
          hardware.facter.reportPath = hostReport name;
        }
      ];
    };
in
{
  inherit (inputs.import-tree ./modules/flake-parts) imports;

  flake.nixosConfigurations = lib.genAttrs hostNames mkHost;
  systems = inputs.nixpkgs.lib.systems.flakeExposed;

  # TODO: expose options for nixd, needs zed config
  debug = false;
}
