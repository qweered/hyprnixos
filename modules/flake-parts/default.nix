{ inputs, lib, ... }:
# TODO: needs great simplification, look at other frameworks
let
  hostsDir = ../hosts;

  # Every sub-directory of modules/hosts is a host: its name becomes the
  # nixosConfiguration (and hostname), and modules/hosts/<name>/ holds that host's
  # private modules. Everything else under modules/ is shared across all hosts.
  hostNames = lib.attrNames (lib.filterAttrs (_: type: type == "directory") (builtins.readDir hostsDir));

  mkHost =
    name:
    let
      # This host's static facts, read straight from its options module. Only the
      # literal cpu/gpu fields are forced, never the lazy `kernel = pkgs.…` field,
      # so the throwaway `pkgs` is safe.
      host = (import (hostsDir + "/${name}/options.nix") { pkgs = { }; }).hyprnix;

      # Variant dirs hold vendor-named files (e.g. system/hardware/cpu/amd.nix),
      # one per cpu/gpu vendor; this host only wants the ones matching its choice.
      vendors = { inherit (host) cpu gpu; };

      # `import-tree` hands this each candidate file's path, relative to the root and
      # leading-slashed (e.g. "/system/hardware/cpu/amd.nix"). Drop a file when it is:
      #   - in the home/ or flake-parts/ trees (not host modules),
      #   - inside another host's private directory, or
      #   - a vendor variant for a vendor this host does not use.
      exclude =
        path:
        let
          dir = baseNameOf (dirOf path);
          vendor = lib.removeSuffix ".nix" (baseNameOf path);
        in
        lib.hasInfix "/home/" path
        || lib.hasInfix "/flake-parts/" path
        || (lib.hasInfix "/hosts/" path && !lib.hasInfix "/hosts/${name}/" path)
        || (vendors ? ${dir} && vendors.${dir} != vendor);
    in
    inputs.nixpkgs-patcher.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      nixpkgsPatcher = {
        inherit inputs;
        enableTroubleshootingShell = false;
      };
      modules = (inputs.import-tree.filterNot exclude ./..).imports;
    };
in
{
  imports = with inputs; [
    git-hooks.flakeModule
    agenix-rekey.flakeModule
    ./install-shell.nix
  ];

  flake.nixosConfigurations = lib.genAttrs hostNames mkHost;

  # TODO: expose options for nixd, needs zed config
  debug = false;

  perSystem =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        name = "hyprnixos";
        nativeBuildInputs = [ config.agenix-rekey.package ];
        shellHook = ''
          ${config.pre-commit.shellHook}
        '';
      };

      pre-commit.settings = {
        excludes = [ "flake.lock" ];
        package = pkgs.prek;
        # TODO: keep-sorted, nixf-diagnose
        hooks = {
          deadnix = {
            enable = true;
            files = "\\.nix$";
            priority = 0;
            settings.edit = true;
          };
          nixfmt-rs = {
            enable = true;
            package = pkgs.nixfmt-rs;
            entry = "${lib.getExe pkgs.nixfmt-rs} --width=140 --strict";
            files = "\\.nix$";
            priority = 2;
          };
          shellcheck = {
            enable = true;
            files = "\\.(sh|bash|fish)$|\\.envrc";
            priority = 0;
            types = [ "file" ];
          };
          statix = {
            enable = true;
            package = pkgs.statix;
            entry = lib.mkForce "${lib.getExe pkgs.statix} fix";
            files = "\\.nix$";
            priority = 1;
          };
        };
      };
    };
}
