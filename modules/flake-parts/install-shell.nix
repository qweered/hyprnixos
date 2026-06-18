# `nix develop github:qweered/hyprnixos#install`

{ config, lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      anyHost = lib.head (lib.attrValues config.flake.nixosConfigurations);
      nixSettings = anyHost.config.nix.settings;
      substitutersArg = lib.concatStringsSep " " nixSettings.substituters;
      trustedKeysArg = lib.concatStringsSep " " nixSettings.trusted-public-keys;

      # Wrap a one-line install step that always needs the caches passed by hand.
      # `$1` is the host (the directory name under modules/hosts); `$FLAKE`
      # overrides where to install from.
      mkInstallStep =
        {
          name,
          usage,
          defaultFlakeRef ? "github:qweered/hyprnixos",
          body,
        }:
        pkgs.writeShellApplication {
          inherit name;
          runtimeInputs = [ pkgs.nh ];
          text = ''
            host="''${1:-}"
            if [ -z "$host" ]; then
              echo "usage: ${name} ${usage}" >&2
              exit 1
            fi
            flake="''${FLAKE:-${defaultFlakeRef}}"
            ${body}
          '';
        };

      hyprnixos-format = mkInstallStep {
        name = "hyprnixos-format";
        usage = "<host> <device>   # partition + format + install via disko-install (DESTRUCTIVE)";
        body = ''
          device="''${2:-}"
          if [ -z "$device" ]; then
            echo "usage: hyprnixos-format <host> <device>   # device e.g. /dev/disk/by-id/nvme-..." >&2
            exit 1
          fi
          # disko-install overrides the disko config's `device` with this path and
          # then runs nixos-install, so it both formats the disk and installs the
          # system. `main` is the disk name in modules/hosts/<host>/filesystems.nix.
          sudo nix --extra-experimental-features "nix-command flakes" \
            run github:nix-community/disko/latest#disko-install -- \
            --flake "$flake#$host" \
            --disk main "$device" \
            --option extra-substituters "${substitutersArg}" \
            --option extra-trusted-public-keys "${trustedKeysArg}"
        '';
      };

      hyprnixos-switch = mkInstallStep {
        name = "hyprnixos-switch";
        usage = "<host>   # first 'nh os switch' on the booted system";
        defaultFlakeRef = ".";
        body = ''
          sudo nh os switch "$flake" -H "$host" \
            --option extra-substituters "${substitutersArg}" \
            --option extra-trusted-public-keys "${trustedKeysArg}"
        '';
      };
    in
    {
      devShells.install = pkgs.mkShellNoCC {
        name = "hyprnixos-install-shell";
        packages = [
          hyprnixos-format
          hyprnixos-switch
        ];
        shellHook = ''
          cat <<'EOF'
          hyprnixos install shell — caches are baked into every command.

            hyprnixos-format <host> <device>   format + install via disko-install (DESTRUCTIVE), then reboot
            hyprnixos-switch <host>            first 'nh os switch' on the booted system

          Override the flake source with FLAKE=<ref> (default: github:qweered/hyprnixos;
          hyprnixos-switch defaults to the current directory ".").
          EOF
        '';
      };
    };
}
