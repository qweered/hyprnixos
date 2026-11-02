{
  description = "HyprNixOS";
  outputs =
    { self, ... }@args:
    let
      inputs = import ./.tack { overrides = args.tackOverrides or { }; } // {
        inherit self;
      };
      extendedSelf = self // {
        inherit inputs;
      };
    in
    inputs.flake-parts.lib.mkFlake
      {
        inherit inputs;
        self = extendedSelf;
      }
      {
        imports = [ ./entrypoint.nix ];
      };
}
