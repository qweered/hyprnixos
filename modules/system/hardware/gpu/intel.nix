{ cfg, lib, ... }:
{
  config = lib.mkIf (cfg.gpu == "intel") {
    # TODO
  };
}
