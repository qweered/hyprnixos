{
  lib,
  pkgs,
  config,
  ...
}:

{
  # Perlless https://github.com/NixOS/nixpkgs/blob/0260f927b7c1578b5c7cdefd7db7b660565cd362/nixos/modules/profiles/perlless.nix

  system.disableInstallerTools = true; # remove generate, install, enter, option, version, build-vms, firewall
  system.tools.nixos-rebuild.enable = true; # but keep rebuild
  programs.nano.enable = false;

  # https://blog.nsrun.io/2026/01/15/systemd-vsock-openssh-server
  systemd.generators.systemd-ssh-generator = "/dev/null";
  systemd.sockets.sshd-unix-local.enable = lib.mkForce false;
  systemd.sockets.sshd-vsock.enable = lib.mkForce false;

  i18n.extraLocales = [ "ru_RU.UTF-8/UTF-8" ];

  # Less bloated fix for "open with" in dolphin, see https://github.com/NixOS/nixpkgs/issues/409986
  environment.etc."xdg/menus/applications.menu".source = ./dolphin.menu;

  environment = {
    defaultPackages = lib.mkForce [ ];
    systemPackages = with pkgs; [
      uutils-coreutils-noprefix
      uutils-findutils
      uutils-diffutils
    ];
  };

  documentation = {
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  # TODO: Check that the system does not contain a Nix store path that contains the string "perl".
  # system.forbiddenDependenciesRegexes = [ "perl" ];

  # If /etc is read-only, we need to provide the machine-id file as a mount point for systemd.
  # https://www.freedesktop.org/software/systemd/man/256/machine-id.html#Initialization
  # environment.etc."machine-id".text = "";
  # system.etc.overlay.enable = true; # multiple errors for now

  systemd.enableStrictShellChecks = true; # CONFIG: will become default
  services.dbus.implementation = "broker"; # CONFIG: will become default

  # Protection against changing hostname between deploys
  # Stolen from https://github.com/nix-community/srvos/blob/c4a21c42efec0506ec352891fec84490dae2ded0/nixos/common/detect-hostname-change.nix
  system.preSwitchChecks.detectHostnameChange = lib.mkIf (config.networking.hostName != "") ''
    detectHostnameChange() {
      local actual
      actual=$(< /proc/sys/kernel/hostname)

      # Ignore if the system is getting installed
      # https://github.com/nix-community/nixos-images/blob/2fc023e024c0a5e8e98ae94363dbf2962da10886/nix/installer.nix#L12-L13
      if [[ ! -e /run/booted-system || "$actual" == "nixos-installer" ]]; then
        return
      fi

      desired=${config.networking.hostName}

      if [[ "$actual" = "$desired" ]]; then
        return
      fi

      # Useful for automation
      if [[ "''${EXPECTED_HOSTNAME:-}" = "$desired" ]]; then
        return
      fi

      log() {
        echo "$*" >&2
      }

      log "WARNING: machine hostname change detected from '$actual' to '$desired'"
      log
      log "Are you deploying on the right host?"
      log
      log "Type YES to continue:"
      read -r reply
      if [[ $reply != YES ]]; then
        echo "aborting"
        exit 1
      fi
    }
    detectHostnameChange
  '';

  # Man-db cache generation cause it's very slow for fish
  # Stolen from https://github.com/MidAutumnMoon/TaysiTsuki/blob/025509df115b5d589f10d5c0d6d11d56ae74c4a2/nixos/documentation/module.nix
  documentation.man.generateCaches = lib.mkForce false;
  systemd.services."man-db" = {
    requires = [ "sysinit-reactivation.target" ];
    after = [ "sysinit-reactivation.target" ];
    partOf = [ "sysinit-reactivation.target" ];
    wantedBy = [ "default.target" ];
    path = [
      config.documentation.man.man-db.package
      pkgs.gawk
    ];
    serviceConfig = {
      Nice = 19;
      IOSchedulingClass = "idle";
      IOSchedulingPriority = 7;
    };

    serviceConfig.ExecStart = pkgs.writers.writeFish "mandbsvc" ''
      set -l SystemManLoc "/run/current-system/sw/share/man"
      set -l ContentRecord "/var/cache/man/nixos/man-db-state"

      if [ ! -d "/var/cache/man/nixos" ]
          mkdir -pv "/var/cache/man/nixos" || exit 1
      end

      if [ ! -f "$ContentRecord" ]
          touch "$ContentRecord" || exit 1
      end

      set -l hashes "$(
          find -L "$SystemManLoc" -type f -iname "*.gz" \
              -exec sha256sum "{}" "+" \
          | awk '{ print $1 }'
          or exit 1
      )"

      set -l ultimate_hash (
          echo $hashes \
          | sort \
          | string join "" \
          | sha256sum - \
          | awk '{ print $1 }'
          or exit 1
      )

      set -l old_hash "$( string collect < "$ContentRecord" )"

      echo "Old hash: $old_hash"
      echo "New hash: $ultimate_hash"

      if [ "$old_hash" != "$ultimate_hash" ]
          echo "Hash changed, do a full man-db rebuild"
          mandb -psc || exit 1
          echo "Write new hash"
          echo "$ultimate_hash" > "$ContentRecord"
      else
          echo "Hash not changed, skip"
      end
    '';
  };

  environment.extraSetup = ''
    find "$out/share/man" \
        -mindepth 1 -maxdepth 1 \
        -not -name "man[1-8]" \
        -exec rm -r "{}" ";"
  '';
}
