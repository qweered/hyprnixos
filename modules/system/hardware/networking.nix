{ pkgs, ... }:
let
  # use cloudflare, quad9 (slower) and adguard with DNS over TLS
  nameservers = [
    "1.1.1.2#security.cloudflare-dns.com"
    "9.9.9.9#dns.quad9.net"
    "94.140.14.14#dns.adguard-dns.com"
  ];
in
{
  # TODO: testing
  # The notion of "online" is a broken concept
  # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
  # systemd.services.NetworkManager-wait-online.enable = false;
  # systemd.network.wait-online.enable = false;

  programs.nm-applet.enable = true; # TODO: unneeded

  networking = {
    # CONFIG: may replace networkmanager
    # but currently creates wait-online- (yes with -) service that cannot be disabled
    # useNetworkd = true;
    inherit nameservers;
    firewall.enable = false; # CONFIG
    networkmanager = {
      enable = true;
      wifi.powersave = true;
      plugins = with pkgs; [ networkmanager-openvpn ];
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
