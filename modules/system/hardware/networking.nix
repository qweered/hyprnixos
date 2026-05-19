{ pkgs, lib, ... }:
let
  # use cloudflare, quad9 (slower) and adguard with DNS over TLS
  nameservers = [
    "1.1.1.2#security.cloudflare-dns.com"
    "9.9.9.9#dns.quad9.net"
    "94.140.14.14#dns.adguard-dns.com"
  ];
  nmcli = lib.getExe' pkgs.networkmanager "nmcli";
in
{
  # TODO: testing
  # The notion of "online" is a broken concept
  # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
  # systemd.services.NetworkManager-wait-online.enable = false;
  # systemd.network.wait-online.enable = false;

  # I don't use mobile modems
  systemd.services.ModemManager.enable = false;

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

      # Split tunneling: VPN connections should never become the default route.
      # VPN-specific subnets (e.g. 10.129.0.0/16) are still routed through the tunnel,
      # but general internet traffic stays on the normal connection.
      # NOTE: Not sure if this works or is correct
      dispatcherScripts = [
        {
          source = pkgs.writeShellScript "vpn-never-default" ''
            case "$2" in
              vpn-pre-up)
                # Ensure all VPN connections use split tunneling
                ${nmcli} connection modify uuid "$CONNECTION_UUID" ipv4.never-default yes ipv6.never-default yes
                ;;
            esac
          '';
          type = "basic";
        }
      ];
    };
  };

  # Mutable /etc/hosts for CTF/pentesting, impure changes will be overrited during rebuild
  environment.etc."hosts".mode = "0644";

  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        Cache = true;
        DNS = nameservers;
        DNSOverTLS = "opportunistic";
        DNSSEC = "allow-downgrade";
        Domains = [ "~." ];
        FallbackDNS = nameservers;
      };
    };
  };

  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_mtu_probing" = 1;
    "net.ipv4.tcp_slow_start_after_idle" = 0;
  };
}
