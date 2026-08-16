# One-shot, DESTRUCTIVE bare-metal installer: partition + format + install a host
# in a single command. The target disk is read from the host's filesystems.nix
# (disko config), NOT from the command line — edit disko.devices.disk.<name>.device
# to retarget. Runs in two phases (disko format+mount, then nixos-install --store
# /mnt) so the system closure streams to the real disk instead of the live ISO's
# RAM-backed tmpfs store; see the phase comments below for the low-RAM rationale.
#
# Runs unattended once started: every check that can refuse happens before the
# first destructive command, sudo is authenticated once up front and kept alive,
# and nothing else prompts. Add --reboot and it finishes the job by itself.
#
# A host must be enrolled as a sops recipient BEFORE it can be installed. That
# step is NOT unattended and does not happen here: re-wrapping the secrets needs
# the admin PGP key, so run it on your workstation —
#   nix run .#hostkey <host>   mint the key, drop its .pub in modules/hosts/<host>/
#   nix run .#sops-sync        re-wrap every secret to include the new recipient
# then bring the private key to the target (--host-key PATH, e.g. a USB stick).
# The install seeds it onto /mnt and refuses to run without it.
#
# git clone https://github.com/qweered/hyprnixos
# cd hyprnixos
# nix --extra-experimental-features "nix-command flakes" develop .#install
# hyprnixos-install <host>|<flake#host> [--host-key PATH] [--reboot]
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

      # Where the installed system reads its sops decryption key. Single-sourced
      # off a host config for the same reason as nixConf above: every host sets
      # it from the shared module, so any of them is a faithful reference.
      hostKeyPath = lib.head (lib.head (lib.attrValues config.flake.nixosConfigurations)).config.sops.age.sshKeyPaths;

      # The public half committed for each enrolled host, i.e. the recipient its
      # secrets are actually wrapped to (same source as modules/flake-parts/sops.nix).
      # Seeding a key that is not this one fails exactly like seeding no key at
      # all, only later and far quieter — so the installer compares them first.
      # Hosts not yet enrolled have no .pub and are simply absent here.
      hostPubs = lib.filterAttrs (_: builtins.pathExists) (
        lib.mapAttrs (name: _: ../hosts + "/${name}/ssh_host_ed25519_key.pub") config.flake.nixosConfigurations
      );

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
            pkgs.openssh # ssh-keygen -y, to derive the public half for the check below
          ];
          text = ''
                        usage() {
                          echo "usage: hyprnixos-install <host>|<flake#host> [--host-key PATH] [--reboot]" >&2
                          echo "  partition + format + install a host (DESTRUCTIVE, unattended once started)" >&2
                          echo "" >&2
                          echo "  --host-key PATH  read the host's sops key from PATH (e.g. a USB stick)" >&2
                          echo "                   instead of ${hostKeyPath}" >&2
                          echo "  --reboot         reboot into the installed system when the install succeeds" >&2
                        }

                        target=""
                        key_src="${hostKeyPath}"
                        do_reboot=0
                        while [ "$#" -gt 0 ]; do
                          case "$1" in
                            --host-key)
                              shift
                              [ "$#" -gt 0 ] || { echo "hyprnixos-install: --host-key needs a path" >&2; exit 1; }
                              key_src="$1"
                              ;;
                            --host-key=*) key_src="''${1#*=}" ;;
                            --reboot) do_reboot=1 ;;
                            -h | --help) usage; exit 0 ;;
                            -*)
                              echo "hyprnixos-install: unknown option: $1" >&2
                              usage
                              exit 1
                              ;;
                            *)
                              if [ -n "$target" ]; then
                                echo "hyprnixos-install: unexpected argument: $1" >&2
                                echo "  the target disk is read from the host's filesystems.nix (disko config)," >&2
                                echo "  not the command line. Edit disko.devices.disk.<name>.device to retarget." >&2
                                exit 1
                              fi
                              target="$1"
                              ;;
                          esac
                          shift
                        done

                        if [ -z "$target" ]; then
                          usage
                          exit 1
                        fi

                        case "$target" in
                          *#*) installable="$target" ;;
                          *)   installable="${defaultFlake}#$target" ;;
                        esac
                        flakeref="''${installable%%#*}"
                        host="''${installable#*#}"

                        # Pre-flight: refuse to wipe a disk we cannot produce a loginable system
                        # on. Nothing regenerates this key later (services.openssh is off, so
                        # there is no sshd-keygen unit) and the very first boot needs it: userborn
                        # reads the decrypted password out of /run/secrets-for-users to write
                        # /etc/shadow, so a machine installed without a working key comes up with
                        # no account anyone can authenticate as. Checked before phase 1, where
                        # failing still costs nothing.
                        expected_pub=""
                        case "$host" in
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: pub: "              ${name}) expected_pub=${pub} ;;") hostPubs)}
                        esac

                        # Cheap half of the pre-flight first: needs no privileges, so the common
                        # mistake (key not carried over) fails instantly instead of behind a
                        # password prompt.
                        if [ ! -e "$key_src" ]; then
                          echo "hyprnixos-install: $key_src is missing — '$host' is not enrolled." >&2
                          echo "  Enrolment needs the admin PGP key, so do it on your workstation:" >&2
                          echo "    nix run .#hostkey $host" >&2
                          echo "    git add modules/hosts/$host/ssh_host_ed25519_key.pub" >&2
                          echo "    nix run .#sops-sync && git commit -a" >&2
                          echo "  then bring the key here and pass --host-key PATH, or place it at" >&2
                          echo "  ${hostKeyPath}, and re-run this install." >&2
                          exit 1
                        fi

                        # Authenticate once, up front, and keep the credential alive for the whole
                        # run. Every privileged step below is a separate sudo, and they span the
                        # entire install (disko, dd, seeding, nixos-install) — far longer than
                        # sudo's ~5 minute credential cache. Without this refresher an install
                        # left alone stops dead on a password prompt somewhere in the middle,
                        # which is the one failure an unattended run cannot recover from. On the
                        # stock ISO sudo is passwordless and this is a no-op.
                        if ! sudo -n true 2>/dev/null; then
                          echo ">>> Authenticating once for the whole install"
                          sudo -v
                        fi
                        (
                          while kill -0 "$$" 2>/dev/null; do
                            sudo -n true 2>/dev/null || true
                            sleep 50
                          done
                        ) &
                        sudo_keepalive=$!

                        # Single teardown for everything this script leaves running. Registered
                        # before the destructive phases so an abort at any point still cleans up;
                        # both entries are no-ops until the thing they own actually exists.
                        swapfile=""
                        cleanup() {
                          if [ -n "$swapfile" ] && [ -e "$swapfile" ]; then
                            sudo swapoff "$swapfile" 2>/dev/null || true
                            sudo rm -f "$swapfile"
                          fi
                          kill "$sudo_keepalive" 2>/dev/null || true
                        }
                        trap cleanup EXIT

                        if [ -n "$expected_pub" ]; then
                          # Compare type+material only; the committed .pub carries a comment.
                          have="$(sudo ssh-keygen -y -f "$key_src" | cut -d' ' -f1,2)"
                          want="$(cut -d' ' -f1,2 < "$expected_pub")"
                          if [ "$have" != "$want" ]; then
                            echo "hyprnixos-install: $key_src is not the key '$host' secrets are wrapped to." >&2
                            echo "    on this machine: $have" >&2
                            echo "    committed .pub:  $want" >&2
                            echo "  Installing it would produce a system that decrypts nothing. Either put" >&2
                            echo "  the original key back, or re-enroll this one: commit the new" >&2
                            echo "  modules/hosts/$host/ssh_host_ed25519_key.pub and run 'nix run .#sops-sync'." >&2
                            exit 1
                          fi
                          echo ">>> Host key matches the committed recipient for $host"
                        else
                          echo ">>> WARNING: no committed .pub for '$host' in this checkout —" >&2
                          echo ">>>          cannot verify the host key is the right recipient." >&2
                        fi

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
                        # Assigning this arms the swap half of the cleanup() trap registered above.
                        swapfile=/mnt/.install-swap

                        echo ">>> Creating temporary 8G install swap at $swapfile"
                        # dd (not fallocate): swapon rejects files with unwritten extents on
                        # some filesystems (e.g. XFS, which this host uses for root).
                        # status=progress only when someone is watching — into a log or a serial
                        # console its carriage returns are just noise.
                        dd_status=none
                        [ -t 2 ] && dd_status=progress
                        sudo dd if=/dev/zero of="$swapfile" bs=1M count=8192 status="$dd_status"
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
                        echo ">>> Pre-instantiating system closure on host store (lets nom read .drv files)"
                        nix eval --raw \
                          "''${flakeref}#nixosConfigurations.\"''${host}\".config.system.build.toplevel.drvPath" \
                          >/dev/null 2>&1 \
                          || echo ">>> (instantiate skipped/failed — nom may show harmless DerivationReadError noise)"

                        # Deliver the key the pre-flight above vetted, now that /mnt exists. It
                        # has to be in place before the installed system's first boot, not after:
                        # sops-install-secrets-for-users.service runs before userborn writes
                        # /etc/shadow, and it reads exactly this path.
                        echo ">>> Seeding host key into /mnt${hostKeyPath}"
                        sudo install -Dm600 "$key_src" "/mnt${hostKeyPath}"

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
                        #
                        # nom is a full-screen renderer, so it only earns its place when a terminal
                        # is there to render into. Unattended the output is a log or a serial
                        # console, where its redraws are unreadable — drop both nom and the JSON
                        # stream it consumes and let nixos-install print plainly.
                        if [ -t 1 ]; then
                          sudo --preserve-env=NIX_USER_CONF_FILES nixos-install \
                            --flake "$installable" \
                            --log-format internal-json -v \
                            --no-channel-copy \
                            --no-root-password |& nom --json
                        else
                          sudo --preserve-env=NIX_USER_CONF_FILES nixos-install \
                            --flake "$installable" \
                            --no-channel-copy \
                            --no-root-password
                        fi

                        # Tear down the scratch swap now rather than at exit, so nothing is holding
                        # /mnt open when systemd starts killing things.
                        cleanup
                        trap - EXIT

                        if [ "$do_reboot" -eq 1 ]; then
                          echo ">>> Done. Rebooting into the installed system."
                          sudo systemctl reboot
                        else
                          echo ">>> Done. Reboot into the installed system when ready,"
                          echo ">>> or pass --reboot next time to finish without a prompt."
                        fi
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

          hyprnixos-install <host>|<flake#host> [--host-key PATH] [--reboot]

          A bare <host> resolves against the flake in the current directory; pass
          <flake#host> to install from anywhere, e.g. github:qweered/hyprnixos#new-host.

          The target disk comes from the host's filesystems.nix (disko config) —
          edit disko.devices.disk.<name>.device to retarget. The install runs in
          two phases (disko format+mount, then nixos-install) so the system closure
          lands on the disk instead of the live ISO's RAM-backed store.

          Runs unattended: it authenticates once, validates the host key before
          touching the disk, and never prompts after that. The host must already be
          enrolled (nix run .#hostkey + .#sops-sync, on your workstation) — bring its
          private key over and point --host-key at it.
          EOF
        '';
      };
    };
}
