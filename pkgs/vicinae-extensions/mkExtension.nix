# Vendored extension builder, adapted from the vicinae flake's
# nix/mkVicinaeExtension.nix and the vicinaehq/extensions flake packaging.
# Building here (from the plain source input) instead of consuming the
# upstream flakes keeps the vicinae flake and its big closure out of the
# lock file — pkgs.vicinae comes from nixpkgs.
{
  buildNpmPackage,
  importNpmLock,
  inputs,
}:
name: extraArgs:
let
  src = inputs.vicinae-extensions + "/extensions/${name}";
in
buildNpmPackage (
  {
    pname = "vicinae-extension-${name}";
    version = "0";
    inherit src;

    npmDeps = importNpmLock { npmRoot = src; };
    inherit (importNpmLock) npmConfigHook;
    npmFlags = [ "--legacy-peer-deps" ];

    # some extensions' tsconfig extends ../../tsconfig.json from the monorepo
    # root, which is outside the per-extension src
    postPatch = ''
      substituteInPlace tsconfig.json --replace-quiet "../../" "${inputs.vicinae-extensions}/"
    '';

    # `npm run build` invokes the @vicinae/api bundler; --out doesn't expand
    # $out when passed via npmBuildFlags, hence the manual buildPhase
    buildPhase = ''
      runHook preBuild
      npm run build -- --out=$out
      runHook postBuild
    '';
    dontNpmInstall = true;
  }
  // extraArgs
)
