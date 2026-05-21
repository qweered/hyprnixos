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
    { pkgs, config, ... }:
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
            priority = 0;
            settings.edit = true;
          };
          nixfmt = {
            enable = true;
            entry = "${pkgs.lib.getExe pkgs.nixfmt} --width=140 --strict";
            priority = 2;
          };
          shellcheck = {
            enable = true;
            files = "(\\.sh|\\.bash|\\.envrc(\\..*)?|(^|/)\\.envrc)$";
            priority = 0;
            types = [ "file" ];
          };
          statix = {
            enable = true;
            pass_filenames = true;
            priority = 1;
            settings.config = ".";
          };
        };
      };
    };
}
