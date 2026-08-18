{ config, pkgs, ... }:
let
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

  vpnImport = pkgs.writeShellApplication {
    name = "vpn-import";
    runtimeInputs = with pkgs; [
      networkmanager # nmcli
      coreutils # comm, sort
    ];
    text = ''
      mode="''${1:-}"
      file="''${2:-}"
      name="''${3:-}"

      usage() {
        echo "Usage: vpn-import <--split|--full> <file.ovpn> [name]" >&2
        echo "  --split  HTB-style: only the VPN's pushed subnets route via the tunnel" >&2
        echo "  --full   route ALL traffic through the VPN (privacy/full-tunnel)" >&2
      }

      case "$mode" in
        --split | --full) ;;
        *) usage; exit 1 ;;
      esac

      if [ ! -f "$file" ]; then
        echo "vpn-import: no such file: $file" >&2
        exit 1
      fi

      # Diff the connection list to learn the UUID the import created, without
      # assuming how NetworkManager names the new connection.
      before="$(nmcli -g UUID connection show)"
      nmcli connection import type openvpn file "$file"
      after="$(nmcli -g UUID connection show)"
      mapfile -t new < <(comm -13 <(sort <<<"$before") <(sort <<<"$after"))
      uuid="''${new[0]:-}"

      if [ -z "$uuid" ]; then
        echo "vpn-import: no new connection appeared (already imported?)" >&2
        exit 1
      fi

      if [ "$mode" = "--split" ]; then
        nmcli connection modify "$uuid" ipv4.never-default yes ipv6.never-default yes
        tunnel="split-tunnel (only the VPN's pushed subnets)"
      else
        nmcli connection modify "$uuid" ipv4.never-default no ipv6.never-default no
        tunnel="full-tunnel (ALL traffic)"
      fi

      if [ -n "$name" ]; then
        nmcli connection modify "$uuid" connection.id "$name"
      fi

      id="$(nmcli -g connection.id connection show "$uuid")"
      echo "Imported '$id' as $tunnel."
      echo "Connect:  nmcli connection up '$id'"
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

  # We use resolved insteead
  hardware.facter.detected.dhcp.enable = false;

  # NOTE: this config is not ready for servers with static networking
  networking = {
    # CONFIG: may replace networkmanager for static networks
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
      wifi.powersave = config.hardware.facter.detected.chassis.laptop;

      plugins = with pkgs; [ networkmanager-openvpn ];

      # NOTE on DHCP DNS leak (tested 2026-07): on a fresh Wi-Fi activation NM
      # pushes the router (e.g. 192.168.0.1) into resolved as a +DefaultRoute
      # resolver. This is harmless here: strict `DNSOverTLS` refuses to use a
      # plaintext resolver, so queries fall through to the DoT nameservers
      # (verified: encrypted transport, router never sees plaintext). Blocking
      # it would need a per-profile `ipv4.ignore-auto-dns` (a plain boolean, so
      # NOT settable via a NetworkManager.conf [connection] default) — not worth
      # a dispatcher script for a purely cosmetic resolver-list cleanup.
    };
  };

  # Mutable /etc/hosts for CTF/pentesting, impure changes will be discarded during rebuild
  environment.etc."hosts".mode = "0644";

  # `captive-portal-login`: temporarily hand DNS back to the gateway to log in.
  # `vpn-import <--split|--full> file.ovpn`: import an OpenVPN profile into NM
  #   with the right default-route intent (split for HTB, full for privacy VPNs).
  environment.systemPackages = [
    captivePortalLogin
    vpnImport
  ];

  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        # DNS servers are from networking.nameservers
        Cache = true;
        DNSOverTLS = "opportunistic"; # TODO: flip to true for servers
        DNSSEC = false; # DNSOverTLS is enough
        Domains = [ "~." ];

        # Both default to "yes", which is resolver *and* responder. The responder
        # half announces this host's name and addresses to the whole L2 segment
        # unsolicited — free recon for anyone on a public AP. "resolve" keeps
        # lookups and drops the announcements; nothing here speaks LLMNR at all,
        # so it goes entirely (which also closes the :5355 sockets, whereas
        # "resolve" would keep them bound to receive replies).
        LLMNR = "false";
        MulticastDNS = "resolve"; # keeps .local reachable for printers/IoT
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
