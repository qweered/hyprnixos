{ inputs, ... }:
let
  hostPlatform = "x86_64-linux";
in
{
  imports = with inputs; [
    treefmt-nix.flakeModule
    git-hooks.flakeModule
  ];

  flake.nixosConfigurations.hyprnix = inputs.nixpkgs-patcher.lib.nixosSystem {
    specialArgs = { inherit inputs hostPlatform; };
    nixpkgsPatcher.inputs = inputs;
    modules = inputs.self.moduleTree {
      users.qweered = true;
      hosts.hyprnix = true;
      unused = false;
      home = false; # loaded by user
      flake-parts = false; # loaded by flake.nix
    };
  };

  # expose options for nixd
  debug = true;

  perSystem =
    { pkgs, config, ... }:
    {
      devShells.default = pkgs.mkShell {
        name = "hyprnixos";
        shellHook = ''
          ${config.pre-commit.shellHook}
        '';
      };

      pre-commit.settings = {
        excludes = [ "flake.lock" ];
        hooks.treefmt.enable = true;
      };

      treefmt = {
        projectRootFile = "TODO.md";
        programs = {
          nixfmt = {
            enable = true;
            strict = true;
            width = 140;
          };
          statix.enable = true;
          deadnix.enable = true;
          shellcheck.enable = true;
          # keep-sorted.enable = true; CONFIG
          # nixf-diagnose.enable = true; CONFIG
        };
      };
    };
}
