# One-shot, DESTRUCTIVE bare-metal installer: partition + format + install a host
# in a single command. The target disk is read from the host's filesystems.nix
# (disko config), NOT from the command line — edit disko.devices.disk.<name>.device
# to retarget. Runs in two phases (disko format+mount, then nixos-install --store
# /mnt) so the system closure streams to the real disk instead of the live ISO's
# RAM-backed tmpfs store; see the phase comments below for the low-RAM rationale.
#
# git clone https://github.com/qweered/hyprnixos
# cd hyprnixos
# nix --extra-experimental-features "nix-command flakes" develop .#install
# hyprnixos-install <host>|<flake#host>
# or
# nix --extra-experimental-features "nix-command flakes" run github:qweered/hyprnixos#install -- <host>

{ config, lib, ... }:
{
  perSystem =
    { pkgs, inputs', ... }:
    let
      # Install with the same nix the target host runs (Determinate Nix) instead
      # of whatever the live ISO happens to ship, so the installer honours the
      # host's experimental features (lazy-trees, cgroups, ca-derivations).
      determinateNix = inputs'.determinate.packages.default;

      # The target host's fully-rendered nix.conf — substituters, trusted keys and
      # experimental features all derived from our nix.settings, not a hand-picked
      # subset. Caches/keys are defined once for every host, so any host is a
      # faithful reference; take the first.
      #FIXME: binary caches are broken with ncro
      nixConf = (lib.head (lib.attrValues config.flake.nixosConfigurations)).config.environment.etc."nix/nix.conf".source;

      # Pinned via our own flake.lock instead of `nix run github:...#disko-install`,
      # which alone pulls ~1.3G of nixpkgs on the live ISO (disko#947).
      disko = lib.getExe inputs'.disko.packages.disko;

      mkInstaller =
        defaultFlake:
        pkgs.writeShellApplication {
          name = "hyprnixos-install";
          runtimeInputs = [
            determinateNix
            pkgs.nix-output-monitor
          ];
          text = ''
            target="''${1:-}"
            if [ -z "$target" ]; then
              echo "usage: hyprnixos-install <host>|<flake#host>   # partition + format + install (DESTRUCTIVE)" >&2
              exit 1
            fi
            shift

            if [ "$#" -ne 0 ]; then
              echo "hyprnixos-install: unexpected argument(s): $*" >&2
              echo "  the target disk is now read from the host's filesystems.nix (disko config)," >&2
              echo "  not the command line. Edit disko.devices.disk.<name>.device to retarget." >&2
              exit 1
            fi

            case "$target" in
              *#*) installable="$target" ;;
              *)   installable="${defaultFlake}#$target" ;;
            esac

            # Point every child `nix` (disko and nixos-install both shell out to
            # nix — now our Determinate Nix from runtimeInputs) at the target
            # host's own generated nix.conf, layered on top of the live ISO's
            # /etc/nix/nix.conf. This carries every substituter, trusted key and
            # experimental feature the installed system uses, instead of a
            # hand-forwarded subset. The config's trailing `!include /run/secrets/…`
            # is an optional include, silently skipped here since that sops secret
            # isn't mounted on the ISO. root is trusted, so `substituters` applies.
            export NIX_USER_CONF_FILES=${nixConf}

            # Headroom for flake eval / any from-source builds on the live ISO's
            # tmpfs store. No longer load-bearing for the system closure itself —
            # that now goes straight to /mnt (real disk) in phase 2 — but cheap
            # insurance on tiny-RAM machines. Skipped when not on a live ISO.
            if [ -d /nix/.rw-store ]; then
              sudo mount -o remount,size=30G,noatime /nix/.rw-store || true
            fi

            echo ">>> Phase 1/2: partition + format + mount target disk (disko)"
            # Only evaluates the disko config (small RAM footprint) and writes a
            # tiny format script — no system closure touches the tmpfs store here.
            sudo --preserve-env=NIX_USER_CONF_FILES ${disko} \
              --mode destroy,format,mount \
              --yes-wipe-all-disks \
              --flake "$installable"

            # Ephemeral install-time swap. The flake eval / any from-source build
            # can still exhaust RAM on small machines, and a swapfile needs real
            # disk — which only exists now that /mnt is formatted + mounted. We do
            # NOT declare a swap partition: the installed system uses zramSwap +
            # services.swapspace instead, so this scratch swap is torn down (incl.
            # on failure, via the trap) before reboot and leaves nothing behind.
            swapfile=/mnt/.install-swap
            cleanup_swap() {
              if [ -e "$swapfile" ]; then
                sudo swapoff "$swapfile" 2>/dev/null || true
                sudo rm -f "$swapfile"
              fi
            }
            trap cleanup_swap EXIT

            echo ">>> Creating temporary 8G install swap at $swapfile"
            # dd (not fallocate): swapon rejects files with unwritten extents on
            # some filesystems (e.g. XFS, which this host uses for root).
            sudo dd if=/dev/zero of="$swapfile" bs=1M count=8192 status=progress
            sudo chmod 600 "$swapfile"
            sudo mkswap "$swapfile"
            sudo swapon "$swapfile"

            # nom draws its build dependency graph by reading each build's .drv
            # from the host's /nix/store — a path it hardcodes (it has no --store
            # flag). But phase 2 below realises the closure with `nixos-install
            # --store /mnt`, so those .drv files physically live under
            # /mnt/nix/store; nom can't find them and prints a harmless
            # "DerivationReadError ... does not exist" for every build. Downloads
            # carry their own info in the JSON stream, so they stay clean — which
            # is why only builds are noisy.
            #
            # Pre-instantiate the system closure into the host store so nom's reads
            # resolve. Evaluating `.drvPath` writes only the .drv *text* files (a
            # few MB total), never their outputs, so it does NOT reintroduce the
            # tmpfs OOM the two-phase split exists to avoid. A .drv hash is
            # content-addressed by the evaluation and independent of the store
            # root, so it matches exactly what nixos-install reports. nixos-install
            # re-evaluates anyway, so peak RAM is unchanged — only one extra eval's
            # time, paid now that swap is up. Best-effort: a failure here merely
            # brings back the cosmetic noise, it never aborts the install.
            flakeref="''${installable%%#*}"
            host="''${installable#*#}"
            echo ">>> Pre-instantiating system closure on host store (lets nom read .drv files)"
            nix eval --raw \
              "''${flakeref}#nixosConfigurations.\"''${host}\".config.system.build.toplevel.drvPath" \
              >/dev/null 2>&1 \
              || echo ">>> (instantiate skipped/failed — nom may show harmless DerivationReadError noise)"

            echo ">>> Phase 2/2: install system to /mnt (nixos-install)"
            # Unlike disko-install, nixos-install copies the closure directly into
            # /mnt/nix/store (the freshly-formatted disk) rather than building it
            # in the tmpfs host store first, so it won't OOM / hit "No space left"
            # on low-RAM live ISOs. See https://github.com/nix-community/disko/issues/947
            #
            # `--log-format internal-json -v` is nom's recommended combo: nixos-install
            # forwards both to the underlying `nix build --store /mnt` (--log-format via
            # its build flags, -v via its verbosity passthrough). The -v is what lets nom
            # distinguish started vs. finished downloads and show per-build phases —
            # without it the JSON stream omits those events. The closure still streams to
            # disk (no tmpfs OOM); pipefail propagates an install failure through nom so
            # the EXIT trap still tears down swap.
            sudo --preserve-env=NIX_USER_CONF_FILES nixos-install \
              --flake "$installable" \
              --log-format internal-json -v \
              --no-channel-copy \
              --no-root-password |& nom --json

            echo ">>> Done. Reboot into the installed system when ready."
          '';
        };
    in
    {
      # nix run <flake>#install -- <host>
      apps.install = {
        type = "app";
        program = lib.getExe (mkInstaller "github:qweered/hyprnixos");
      };

      # nix develop .#install
      devShells.install = pkgs.mkShellNoCC {
        name = "hyprnixos-install-shell";
        packages = [
          (mkInstaller ".")
        ];
        shellHook = ''
          cat <<'EOF'

          hyprnixos-install <host>|<flake#host>

          A bare <host> resolves against the flake in the current directory; pass
          <flake#host> to install from anywhere, e.g. github:qweered/hyprnixos#new-host.

          The target disk comes from the host's filesystems.nix (disko config) —
          edit disko.devices.disk.<name>.device to retarget. The install runs in
          two phases (disko format+mount, then nixos-install) so the system closure
          lands on the disk instead of the live ISO's RAM-backed store.
          EOF
        '';
      };
    };
}
