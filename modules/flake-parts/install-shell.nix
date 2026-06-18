# git clone https://github.com/qweered/hyprnixos.git
# `nix develop .#install`

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
          runtimeInputs ? [ ],
          body,
        }:
        pkgs.writeShellApplication {
          inherit name runtimeInputs;
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
        usage = "<host>   # partition + format + install (DESTRUCTIVE); device comes from the host config";
        runtimeInputs = [ pkgs.nix-output-monitor ];
        # Two steps instead of disko-install on purpose: disko-install builds the
        # whole closure into the live ISO's RAM-backed store *before* touching the
        # disk and forces DISKO_SKIP_SWAP, so a large desktop closure runs the ISO
        # out of memory. Plain `disko` formats *first* and runs `swapon` on the
        # swap partition, so the subsequent build can spill to disk-backed swap.
        body = ''
          # 1. Partition, format, and mount the target, activating swap. The disk
          #    device is read from modules/hosts/$host/filesystems.nix (plain disko
          #    has no CLI device override). --option goes on `nix`, not disko, which
          #    does not forward it.
          sudo nix \
            --extra-experimental-features "nix-command flakes" \
            --option extra-substituters "${substitutersArg}" \
            --option extra-trusted-public-keys "${trustedKeysArg}" \
            run github:nix-community/disko/latest -- \
            --mode destroy,format,mount --yes-wipe-all-disks \
            --flake "$flake#$host"

          # 2. Build the system with a live nom progress graph. Runs under sudo so
          #    the extra caches are trusted, and `env PATH=$PATH` carries nom past
          #    sudo's secure_path. tmpfs now spills to the swap from step 1.
          sudo env "PATH=$PATH" nom build --no-link \
            "$flake#nixosConfigurations.$host.config.system.build.toplevel" \
            --option extra-substituters "${substitutersArg}" \
            --option extra-trusted-public-keys "${trustedKeysArg}"

          # 3. Install the now-built system onto /mnt (disko's default mountpoint).
          sudo nixos-install --flake "$flake#$host" --no-root-password --no-channel-copy \
            --option extra-substituters "${substitutersArg}" \
            --option extra-trusted-public-keys "${trustedKeysArg}"
        '';
      };

      hyprnixos-switch = mkInstallStep {
        name = "hyprnixos-switch";
        usage = "<host>   # first 'nh os switch' on the booted system";
        defaultFlakeRef = ".";
        runtimeInputs = [ pkgs.nh ];
        body = ''
          nh os switch "$flake" -H "$host" \
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

            hyprnixos-format <host>   format + install (DESTRUCTIVE; device from host config), then reboot
            hyprnixos-switch <host>   first 'nh os switch' on the booted system

          Override the flake source with FLAKE=<ref> (default: github:qweered/hyprnixos;
          hyprnixos-switch defaults to the current directory ".").
          EOF
        '';
      };
    };
}
