{ lib, pkgs, ... }:

{
  # Perlless https://github.com/NixOS/nixpkgs/blob/0260f927b7c1578b5c7cdefd7db7b660565cd362/nixos/modules/profiles/perlless.nix

  system.disableInstallerTools = true; # remove generate, install, enter, option, version, build-vms, firewall
  system.tools.nixos-rebuild.enable = true; # but keep rebuild
  programs.nano.enable = false;
  boot.loader.grub.enable = lib.mkDefault false;

  i18n.extraLocales = [ "ru_RU.UTF-8/UTF-8" ];

  environment.defaultPackages = [ ];
  environment.systemPackages = with pkgs; [
    uutils-coreutils-noprefix
    uutils-findutils
    uutils-diffutils
  ];

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

  # Man-db cache generation cause it's very slow for fish
  # Stolen from https://github.com/MidAutumnMoon/TaysiTsuki/blob/025509df115b5d589f10d5c0d6d11d56ae74c4a2/nixos/documentation/module.nix
  /*
    documentation.man.generateCaches = false;
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
    ''
  */
}
