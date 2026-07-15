{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (_finalAttrs: {
  pname = "rom";
  version = "0.2.0-unstable-2026-07-04";
  __structuredAttrs = true;

  # rom's drv-parser tests embed a real hello.drv (crates/cognos/src/aterm.rs)
  # whose text names the store path of stdenv's source-stdenv.sh — which is also
  # a build input of every fetch derivation since nixpkgs#357053. Nix's
  # fixed-output reference check then rejects the fetched source as "referencing"
  # an input. It's inert test data, not a real reference, so discard it.
  # (rev is a literal instead of tag = "v${version}" so that
  # nix-update --version=branch can bump to untagged main commits.)
  src =
    (fetchFromGitHub {
      owner = "manic-systems";
      repo = "rom";
      rev = "bdf5edf384cfbe7651b71f83324eadb9301abf62";
      hash = "sha256-7gCPo5Zl/KrGlj3+5/Ed6wUmmgKD93HgPHv1vWqf3WQ=";
    }).overrideAttrs
      { unsafeDiscardReferences.out = true; };

  # In pipe mode (`nix ... --log-format internal-json |& rom --json`, which is
  # how nh drives its monitor) rom echoed every `msg` action verbatim, with no
  # level filter. Nix's JSON logger emits messages according to the producer's
  # verbosity — and nh hard-codes `--verbose`, which raises nix to "talkative"
  # and unleashes an `evaluating file '...'` line per nixpkgs file. Filter the
  # passthrough to info-and-above. Drop when upstreamed (manic-systems/rom).
  patches = [ ./filter-json-msg-passthrough.patch ];

  cargoHash = "sha256-kB8qDrmhaaR3DSgGGaLfYDE4PP1fsq0w7FuIHncttMI=";

  # Track the latest main commit (no stable release beyond v0.2.0 yet). The bulk
  # updater (nix run .#update-pkgs) runs this per-package script, so rom stays on
  # unstable while packages without extraArgs follow their latest release.
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "A flamboyant output monitor for the Nix build tool";
    homepage = "https://github.com/manic-systems/rom";
    license = lib.licenses.eupl12;
    mainProgram = "rom";
  };
})
