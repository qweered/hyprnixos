# Adapted from https://github.com/drupol/pkgs-by-name-for-flake-parts/blob/7ba1cd4a9a72c9c6c272018a63f090f2c912a171/flake-module.nix
#
# Reworked into an option-free flake module: just `imports = [ ./pkgs-by-name.nix ]`
# and drop packages under <repo-root>/pkgs. Each package is exposed three ways:
#   - flake output `packages.<system>.<name>` (flat), for `nix build .#<name>`
#   - flake output `legacyPackages.<system>` (nested)
#   - `flake.overlays.pkgs`, so NixOS/home-manager modules can add it to
#     nixpkgs.overlays and use `pkgs.<name>` with no per-package wiring.
# Inert until the directory exists, so it is safe to import before you have any
# packages.
{
  lib,
  inputs,
  ...
}:
let
  # Path literals resolve relative to this file, so this always points at
  # <repo-root>/pkgs no matter where the flake is evaluated from.
  directory = ../../pkgs;

  # Separator used when flattening nested package names into flat attr names.
  separator = "/";

  hasPkgs = builtins.pathExists directory;

  flattenPkgs =
    path: value:
    if lib.isDerivation value then
      {
        ${lib.concatStringsSep separator path} = value;
      }
    else if lib.isAttrs value then
      lib.concatMapAttrs (name: flattenPkgs (path ++ [ name ])) value
    else
      { };

  # lib.makeScope takes two arguments:
  #   1. A newScope constructor (pkgs.newScope)
  #   2. A function (self: { packages... }) that builds the package set
  #
  # It returns a scope with helper functions AND a special `packages` attribute
  # that is the second function we passed in. By calling scope.packages with
  # scope itself as the argument, we:
  #   - Calculate the fixpoint (all packages can reference each other)
  #   - Extract just the packages attrset without helper functions (callPackage, etc.)
  #   - Avoid conflicts with the flake's top-level packages output
  #
  # Nix's laziness means this function call has no performance penalty.
  extractPackages =
    scope:
    let
      shouldRecurse = lib.isAttrs scope && !(lib.isDerivation scope) && scope ? "packages" && lib.isFunction scope.packages;
      mappedSet = lib.mapAttrs (_: extractPackages) (scope.packages scope);
    in
    if shouldRecurse then mappedSet else scope;

  # Build the nested package set from `directory`, resolving each package's
  # arguments against `pkgs` — so a package can depend both on nixpkgs and on
  # the flake `inputs` (injected into the scope). `pkgs` is the only thing that
  # varies between the flake output (per-system pkgs) and the overlay (`final`).
  legacyPackagesFor =
    pkgs:
    let
      inputsScope = lib.makeScope pkgs.newScope (_self: {
        inherit inputs;
      });
      scope = lib.filesystem.packagesFromDirectoryRecursive {
        inherit directory;
        inherit (inputsScope) newScope callPackage;
      };
    in
    extractPackages scope;
in
{
  # Merge every pkgs/ package into nixpkgs. Consumers opt in by adding
  # `inputs.self.overlays.pkgs` to `nixpkgs.overlays`.
  flake.overlays.pkgs = final: _prev: lib.optionalAttrs hasPkgs (legacyPackagesFor final);

  perSystem =
    { pkgs, ... }:
    lib.optionalAttrs hasPkgs (
      let
        legacyPackages = legacyPackagesFor pkgs;
      in
      {
        inherit legacyPackages;
        packages = flattenPkgs [ ] legacyPackages;
      }
    );
}
