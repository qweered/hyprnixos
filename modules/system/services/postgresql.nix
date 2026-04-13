{ pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;

    authentication = ''
      # Allow local Unix socket connections without password
      local all all trust
    '';
  };
}
