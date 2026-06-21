{
  programs.zed-editor = {
    enable = true;
    # TODO: declarative settings
    # https://wiki.nixos.org/wiki/Zed

    # Make Nix-built language servers available to Zed. Zed otherwise downloads
    # generic prebuilt binaries, which NixOS can't run (no /lib64 loader).
    # extraPackages = [ pkgs.typos-lsp ];

    # userSettings = {
    # Point the Typos extension at the Nix-built (patchelf'd) server instead of
    # the generic binary it tries to download. The `typos` id matches the LSP
    # server name the extension registers.
    # lsp.typos.binary.path = "${pkgs.typos-lsp}/bin/typos-lsp";
    # };
  };
}
