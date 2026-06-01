{ inputs, ... }:
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
    modules = (inputs.import-tree.matchNot ".*/(home|flake-parts)/.*" ./..).imports;
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
