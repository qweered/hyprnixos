let
  # use cloudflare, quad9 (slower) and adguard with DNS over TLS
  nameservers = [
    "1.1.1.2#security.cloudflare-dns.com"
    "9.9.9.9#dns.quad9.net"
    "94.140.14.14#dns.adguard-dns.com"
  ];
in
{
  networking = {
    inherit nameservers;
    firewall.enable = false; # CONFIG
    networkmanager = {
      enable = true;
      wifi.powersave = true;
      # for captive portals but don't work it seems
      # contribute to nixpkgs https://wiki.archlinux.org/title/NetworkManager#Checking_connectivity
      # settings.connectivity.uri = "http://nmcheck.gnome.org/check_network_status.txt";
    };
  };

  services.resolved = {
    enable = true;
    settings = {
      Resolve.DNSOverTLS = "opportunistic";
      Resolve.DNSSEC = "allow-downgrade";
      Resolve.FallbackDNS = nameservers;
    };
  };
}
