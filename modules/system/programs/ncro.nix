{ lib, inputs, ... }:
let
  caches = [
    { "https://cache.nixos.org" = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="; }
    # cache for unfree packages
    {
      "https://nix-community.cachix.org" = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    }
    # my own cache
    {
      "https://qweered.cachix.org" = "qweered.cachix.org-1:X6WgfA8u+Xo+POju6JTr0/68YWNmT2bQjEww4qBvFZk=";
    }
    # determinate nix
    {
      "https://install.determinate.systems" = "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM=";
    }
    # llm agents
    {
      "https://cache.numtide.com" = "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=";
    }
    # cachyos kernel
    { "https://attic.xuyh0120.win/lantian" = "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="; }
    # devenv
    {
      "https://devenv.cachix.org" = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    }
    # some gaming packages
    {
      "https://nix-gaming.cachix.org" = "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=";
    }
    # neovim flake
    { "https://nvf.cachix.org" = "nvf.cachix.org-1:GMQWiUhZ6ux9D5CvFFMwnc2nFrUHTeGaXRlVBXo+naI="; }
    # corepkgs
    # { "https://ekala-corepkgs.cachix.org" = "ekala-corepkgs.cachix.org-1:DcZV+vegWoEzacbSdXFXU4S7728C0eS9RfGpKeyHd6w="; }
  ];

  toUpstream =
    priority: cache:
    let
      url = lib.head (lib.attrNames cache);
    in
    {
      inherit url priority;
      public_key = cache.${url};
    };
in
{
  imports = [ inputs.ncro.nixosModules.ncro ];

  services.ncro = {
    enable = true;
    settings = {
      upstreams = lib.imap1 toUpstream caches;
      logging.timestamps = false;
    };
  };

  # NOTE: ncro needs to be the *only* substituter if you wish to benefit from it fully.
  nix.settings =
    let
      proxy = "http://localhost:8080";
    in
    {
      # lib.mkForce is to overwrite the NixOS defaults and propagation from flake inputs
      substituters = lib.mkForce [ proxy ];
      trusted-substituters = lib.mkForce [ proxy ]; # So non-root users can use the proxy too
    };
}
