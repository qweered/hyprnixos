{ inputs, lib, ... }:
let
  # Every sub-directory of modules/hosts is a host: its name becomes the
  # nixosConfiguration (and hostname), and modules/hosts/<name>/ holds that host's
  # private modules. Everything else under modules/ is shared across all hosts.
  hostNames = lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./modules/hosts));

  mkHost =
    name:
    let
      # Drop a file when it is:
      #   - in the home/ or flake-parts/ trees (not host modules), or
      #   - inside another host's private directory.
      # Vendor variants (cpu/gpu) are all imported and self-gate via lib.mkIf on
      # Maybe TODO: to make them imported instead to reduce eval time
      exclude =
        path:
        lib.hasInfix "/home/" path || lib.hasInfix "/flake-parts/" path || (lib.hasInfix "/hosts/" path && !lib.hasInfix "/hosts/${name}/" path);
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
        { networking.hostName = name; }
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
  ];

  flake.nixosConfigurations = lib.genAttrs hostNames mkHost;
  systems = inputs.nixpkgs.lib.systems.flakeExposed;

  # TODO: expose options for nixd, needs zed config
  debug = false;
}
