{
  services.tailscale = {
    enable = true;
    extraUpFlags = [ "--ssh" ];
    # NOTE: i can use authKeyFile but it expires at most every 90 days,
    # so lets have imperative auth instead
  };
}
