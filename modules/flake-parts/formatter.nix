{
  perSystem =
    { lib, pkgs, ... }:
    {
      # Wrapped so the pre-commit hook can reuse it as `config.formatter` and the
      # flags can't drift. `nix fmt` passes no filenames, which nixfmt-rs reads as
      # stdin; nixfmt-rs walks a directory itself, so default to the tree.
      formatter = pkgs.writeShellScriptBin "nixfmt" ''
        if [ "$#" -eq 0 ]; then
          set -- .
        fi
        exec ${lib.getExe pkgs.nixfmt-rs} --width=140 --strict "$@"
      '';
    };
}
