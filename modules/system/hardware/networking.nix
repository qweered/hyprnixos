{ pkgs, lib, ... }:
let
  nmcli = lib.getExe' pkgs.networkmanager "nmcli";

  captivePortalLogin = pkgs.writeShellApplication {
    name = "captive-portal-login";
    runtimeInputs = with pkgs; [
      systemd # resolvectl
      iproute2 # ip
      xdg-utils # xdg-open
    ];
    text = ''
      iface=$(ip route show default | awk '{print $5; exit}')
      gw=$(ip route show default | awk '{print $3; exit}')
      if [ -z "$iface" ] || [ -z "$gw" ]; then
        echo "No default route found - are you associated with the network yet?" >&2
        exit 1
      fi

      echo "Routing DNS for $iface via gateway $gw (plaintext) for portal login..."
      # Restore enforced DoT no matter how we exit.
      trap 'echo "Restoring enforced DoT-only DNS..."; resolvectl revert "$iface"' EXIT
      resolvectl dns "$iface" "$gw"
      resolvectl domain "$iface" "~."

      # neverssl.com is plain HTTP and never redirects to HTTPS, so the portal
      # can transparently intercept it and show its login page.
      xdg-open http://neverssl.com >/dev/null 2>&1 \
        || echo "Open http://neverssl.com in your browser to reach the portal."
      read -r -p "Press Enter once the captive-portal login is complete... " _
    '';
  };
in
{
  # TODO: testing
  # The notion of "online" is a broken concept
  # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
  # systemd.services.NetworkManager-wait-online.enable = false;
  # boot.initrd.systemd.network.wait-online.enable = false;
  # systemd.network.wait-online.enable = false;

  # I don't use mobile modems
  systemd.services.ModemManager.enable = false;

  networking = {
    # CONFIG: may replace networkmanager
    # but currently creates wait-online- (yes with -) service that cannot be disabled
    # useNetworkd = true;

    # We configure dns manually
    useDHCP = false;
    dhcpcd.enable = false;

    # use cloudflare, quad9 (slower) and adguard with DNS over TLS
    nameservers = [
      "1.1.1.2#security.cloudflare-dns.com"
      "9.9.9.9#dns.quad9.net"
      "94.140.14.14#dns.adguard-dns.com"
    ];
    firewall.enable = false; # CONFIG
    networkmanager = {
      enable = true;
      wifi.powersave = true;
      # for captive portals but don't work it seems
      # contribute to nixpkgs https://wiki.archlinux.org/title/NetworkManager#Checking_connectivity
      # settings.connectivity.uri = "http://nmcheck.gnome.org/check_network_status.txt";

      plugins = with pkgs; [ networkmanager-openvpn ];
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
        {
          # Enforce DoT-only DNS: drop DHCP-provided resolvers (e.g. the router
          # at 192.168.0.1) so only `networking.nameservers` are used.
          # `ipv4.ignore-auto-dns` is NOT an overridable NetworkManager.conf
          # [connection] default, so it must be set on each profile. Scoped to
          # Wi-Fi/Ethernet so VPN- and Tailscale-pushed DNS still work.
          # The ignore-auto-dns guard makes this idempotent and avoids a
          # modify -> reapply -> dispatcher loop.
          source = pkgs.writeShellScript "ignore-dhcp-dns" ''
            case "$2" in
              up | dhcp4-change | dhcp6-change)
                case "$(${nmcli} -g connection.type connection show "$CONNECTION_UUID")" in
                  802-11-wireless | 802-3-ethernet)
                    if [ "$(${nmcli} -g ipv4.ignore-auto-dns connection show "$CONNECTION_UUID")" != "yes" ]; then
                      ${nmcli} connection modify "$CONNECTION_UUID" ipv4.ignore-auto-dns yes ipv6.ignore-auto-dns yes
                      ${nmcli} device reapply "$DEVICE_IFACE"
                    fi
                    ;;
                esac
                ;;
            esac
          '';
          type = "basic";
        }
      ];
    };
  };

  # Mutable /etc/hosts for CTF/pentesting, impure changes will be discarded during rebuild
  environment.etc."hosts".mode = "0644";

  # `captive-portal-login`: temporarily hand DNS back to the gateway to log in.
  environment.systemPackages = [ captivePortalLogin ];

  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        # DNS comes from networking.nameservers
        Cache = true;
        DNSOverTLS = "opportunistic";
        DNSSEC = "allow-downgrade";
        Domains = [ "~." ];
      };
    };
  };

  # TODO: configure through cachyos-kernel bbr3 option
  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_mtu_probing" = 1;
    "net.ipv4.tcp_slow_start_after_idle" = 0;
  };
}
