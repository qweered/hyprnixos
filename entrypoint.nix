{ inputs, lib, ... }:
let
  # A host is a sub-directory of modules/hosts holding a nixos-facter report: its
  # name becomes the nixosConfiguration (and hostname), and the directory holds
  # that host's private modules. Everything else under modules/ is shared.
  # The report is required because every module reads it unguarded, so a
  # directory without one (new-host) is a template to copy, not a machine.
  hostNames = lib.attrNames (
    lib.filterAttrs (name: type: type == "directory" && builtins.pathExists (./modules/hosts + "/${name}/facter.json")) (
      builtins.readDir ./modules/hosts
    )
  );

  mkHost =
    name:
    let
      # Drop a file when it is:
      #   - in the home/ or flake-parts/ trees (not host modules), or
      #   - inside another host's private directory.
      exclude =
        path:
        lib.hasInfix "/home/" path || lib.hasInfix "/flake-parts/" path || (lib.hasInfix "/hosts/" path && !lib.hasInfix "/hosts/${name}/" path);

      facterReport = ./modules/hosts + "/${name}/facter.json";
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
        {
          networking.hostName = name;
          hardware.facter.reportPath = facterReport;
        }
      ];
    };
in
{
  imports = with inputs; [
    git-hooks.flakeModule
    # TODO: import nicely instead
    ./modules/flake-parts/install-shell.nix
    ./modules/flake-parts/git-hooks.nix
    ./modules/flake-parts/sops.nix
    ./modules/flake-parts/pkgs-by-name.nix
    ./modules/flake-parts/update-pkgs.nix
  ];

  flake.nixosConfigurations = lib.genAttrs hostNames mkHost;
  systems = inputs.nixpkgs.lib.systems.flakeExposed;

  # TODO: expose options for nixd, needs zed config
  debug = false;
}
