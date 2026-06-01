{ inputs, ... }:
let
  hostPlatform = "x86_64-linux";
in
{
  imports = with inputs; [
    git-hooks.flakeModule
    agenix-rekey.flakeModule
  ];

  flake.nixosConfigurations.hyprnix = inputs.nixpkgs-patcher.lib.nixosSystem {
    specialArgs = { inherit inputs hostPlatform; };
    nixpkgsPatcher = {
      inherit inputs;
      enableTroubleshootingShell = false;
    };
    modules = (inputs.import-tree.matchNot ".*/(home|flake-parts)/.*" ./..).imports;
  };

  # expose options for nixd
  debug = true;

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
            entry = "${lib.getExe pkgs.nixfmt-rs} --width=140 --strict";
            files = "\\.nix$";
            package = pkgs.nixfmt-rs;
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
            files = "\\.nix$";
            priority = 1;
            settings.config = ".";
          };
        };
      };
    };
}
