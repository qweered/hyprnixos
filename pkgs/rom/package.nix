{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rom";
  version = "0.2.0";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "rom";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mK+Nm5YA07SPodGscEVdWmNNzRCs64wSuBU+HTD2QCM=";
  };

  cargoHash = "sha256-FvBdpEgFv/WHrfe0U2oy4k7neCN7iOSmNJhNxWNI1Kc=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A flamboyant output monitor for the Nix build tool";
    homepage = "https://github.com/manic-systems/rom";
    license = lib.licenses.eupl12;
    mainProgram = "rom";
  };
})
