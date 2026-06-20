{ cfg, lib, ... }:
{
  config = lib.mkIf (cfg.gpu == "nvidia") {
    # TODO
  };
}
