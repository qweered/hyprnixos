{ inputs, lib, ... }:
let
  # Read the host's static hardware facts straight from its options module.
  # Only the literal cpu/gpu fields are touched, so the lazy `kernel = pkgs.…`
  # field — and thus this throwaway `pkgs` — is never forced.
  host = (import ../hosts/hyprnix/options.nix { pkgs = { }; }).hyprnix;

  # Map of "variant directory" -> chosen vendor. Files living directly under one
  # of these directories are named after a vendor (e.g. system/hardware/cpu/amd.nix);
  # every file whose vendor does not match the host is dropped at import time so
  # only this host's hardware modules are ever evaluated.
  variantDirs = {
    inherit (host) cpu;
    inherit (host) gpu;
  };

  # `import-tree` hands the predicate each file's path (relative to the root, with a
  # leading slash, e.g. "/system/hardware/cpu/amd.nix"). Drop it when its parent dir
  # is a known variant dir and the filename (sans .nix) is a different vendor.
  isForeignVariant =
    path:
    let
      parts = lib.splitString "/" path;
      parent = lib.elemAt parts (lib.length parts - 2);
      vendor = lib.removeSuffix ".nix" (lib.last parts);
    in
    variantDirs ? ${parent} && variantDirs.${parent} != vendor;
in
{
  imports = with inputs; [
    git-hooks.flakeModule
    agenix-rekey.flakeModule
  ];

  flake.nixosConfigurations.hyprnix = inputs.nixpkgs-patcher.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    nixpkgsPatcher = {
      inherit inputs;
      enableTroubleshootingShell = false;
    };
    modules = ((inputs.import-tree.matchNot ".*/(home|flake-parts)/.*").filterNot isForeignVariant ./..).imports;
  };

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
