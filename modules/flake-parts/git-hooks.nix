{ inputs, ... }:
{
  imports = [ inputs.git-hooks.flakeModule ];

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
        shellHook = ''
          ${config.pre-commit.shellHook}
        '';
      };

      formatter = pkgs.writeShellScriptBin "pre-commit-run" ''
        exec ${lib.getExe config.pre-commit.settings.package} run --all-files --config ${config.pre-commit.settings.configFile}
      '';

      pre-commit.settings = {
        package = pkgs.prek;
        excludes = [ "(^|/)\\.tack/" ];

        # TODO: keep-sorted, nixf-diagnose
        hooks = {
          deadnix = {
            enable = true;
            files = "\\.nix$";
            priority = 0;
            settings.edit = true;
          };
          shellcheck = {
            enable = true;
            files = "\\.(sh|bash|fish)$|\\.envrc";
            priority = 0;
            types = [ "file" ];
          };
          statix = {
            enable = true;
            entry = "${lib.getExe pkgs.statix} fix";
            pass_filenames = false;
            files = "\\.nix$";
            priority = 1;
          };
          nixfmt = {
            enable = true;
            package = pkgs.nixfmt-rs;
            settings.width = 140;
            args = [ "--strict" ];
            files = "\\.nix$";
            priority = 2;
          };
        };
      };
    };
}
