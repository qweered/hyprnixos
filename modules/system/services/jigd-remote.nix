{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.jigd-remote;
in
{
  options.services.jigd-remote = {
    enable = lib.mkEnableOption "tunnel to the remote jigd compilation-cache socket";

    host = lib.mkOption {
      type = lib.types.str;
      default = "jonringer.us";
      description = "Host running jigd.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 2222;
      description = "SSH port of the jigd host.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "qweered";
      description = "SSH user on the jigd host. Remote-builder key works once its server-side entry allows port forwarding.";
    };

    remoteSocket = lib.mkOption {
      type = lib.types.str;
      default = "/run/jigd/jigd.sock";
      description = "jigd socket path on the remote host (services.jigd.socketPath in server-configuration).";
    };

    localSocket = lib.mkOption {
      type = lib.types.str;
      default = "/nix/var/nix/jigd/socket";
      description = "Local path to forward the remote socket to. Default is what repkgs checks (tools/repkgs/nix.nu INSIDE), so `repkgs build` finds it with no env vars.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.jigd-remote = {
      description = "Forward remote jigd socket (${cfg.host}:${toString cfg.port})";
      wants = [ "network-online.target" ];
      requires = [ "sops-install-secrets.service" ];
      after = [
        "network-online.target"
        "sops-install-secrets.service"
      ];
      wantedBy = [ "multi-user.target" ];
      unitConfig.StartLimitIntervalSec = 0;
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = 5;
        StateDirectory = "jigd-remote";
        StateDirectoryMode = "0700";
        ExecStartPre = [
          # NOTE: no shell here — compute the parent directory in Nix (dirOf),
          # systemd would pass $(...) through literally and mkdir created
          # a junk `socket)` directory from it.
          "${pkgs.coreutils}/bin/mkdir -p ${dirOf cfg.localSocket}"
        ];
        ExecStart = lib.escapeShellArgs [
          "${pkgs.openssh}/bin/ssh"
          "-N"
          "-T"
          "-o"
          "BatchMode=yes"
          "-o"
          "ExitOnForwardFailure=yes"
          "-o"
          "ConnectTimeout=10"
          "-o"
          "ServerAliveInterval=15"
          "-o"
          "ServerAliveCountMax=3"
          "-o"
          "StrictHostKeyChecking=accept-new"
          "-o"
          "UserKnownHostsFile=/var/lib/jigd-remote/known_hosts"
          "-o"
          "StreamLocalBindUnlink=yes"
          # sshd creates the local listener 0700-root by default; jig's own
          # socket is 0666 (jigd peer_linux.go) so build users can connect.
          # 0111 mask -> 0666.
          "-o"
          "StreamLocalBindMask=0111"
          "-i"
          config.sops.secrets.nix-builder-key.path
          "-p"
          (toString cfg.port)
          "-L"
          "${cfg.localSocket}:${cfg.remoteSocket}"
          "${cfg.user}@${cfg.host}"
        ];
      };
    };
  };
}
