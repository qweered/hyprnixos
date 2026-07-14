# HyprNixOS

A NixOS configuration flake for a Hyprland-based desktop, built with
[`flake-parts`](https://flake.parts) and [`import-tree`](https://github.com/vic/import-tree).

Every sub-directory of `modules/hosts/` is a host: its name becomes the
`nixosConfiguration` (and hostname), and its private modules live alongside it.
Everything else under `modules/` is shared across all hosts. CPU/GPU variant
files (e.g. `modules/system/hardware/cpu/amd.nix`) are auto-selected per host
from the `cpu`/`gpu` options, and each host picks its desktop with the
`desktop` option (`hyprland` or `kde`).

## Installing on a new host

```bash
nix develop github:qweered/hyprnixos#install
```

It prints its own help on entry. Each wrapper takes the host name (the directory
under `modules/hosts/`):

```bash
# 1. partition + format the disk and install the system (DESTRUCTIVE)
hyprnixos-format new-host
# override target devices by appending <disk>=<device> pairs (one per disko disk):
# hyprnixos-format new-host main=/dev/nvme0n1 data=/dev/sda

reboot

# 2. first `nh os switch` on the booted system
hyprnixos-switch new-host
```

`hyprnixos-format` follows the standard
[NixOS install flow](https://nixos.org/manual/nixos/stable/#sec-installation):
[`disko`](https://github.com/nix-community/disko) partitions/formats the disk
(the device comes from the host's `filesystems.nix`) and mounts it, a temporary
swapfile is activated on the target, the system is built with a live
[nix-output-monitor](https://github.com/maralorn/nix-output-monitor) progress
graph, `nixos-install` copies it onto the target, and the swapfile is removed.

> The swapfile is why this works on low-RAM machines. A NixOS live ISO keeps
> `/nix/store`'s writable layer in a RAM-backed tmpfs, and the manual notes the
> build "may need quite a bit of RAM" — so a large desktop closure runs out of
> memory ("No space left on device") without swap. The swapfile lets tmpfs spill
> to the disk; it lives only at `/mnt/.install-swap` during the install and is
> `swapoff`'d and deleted afterwards, so it never reaches the installed system
> (no swap in your declarative config). It defaults to 16G — bump the `count=` in
> `install-shell.nix` if a build still runs out.

A bare host installs from the flake in the current directory (the clone you're
in); pass a full `<flake#host>` to install from elsewhere instead (e.g.
`hyprnixos-format github:qweered/hyprnixos#new-host`). From the second
switch onward nothing extra is needed — `modules/system/programs/nix.nix` is now
live, so the plain `nh os switch` (the `nh-switch` alias) already knows every
cache.

### Notes specific to this setup

- **`-H <host>` is required**, which the wrappers pass for you. `nh` otherwise
  infers the config name from the running hostname (`nixos` in the ISO, or unset
  for `new-host`), which won't match the host directory.
- **`new-host` needs real values before it'll install.** The hostname is derived
  from the directory name, so there's nothing to set for it — but `cpu`/`gpu` in
  `modules/hosts/new-host/options.nix` are `CHANGE ME` placeholders, and `device`
  in `modules/hosts/new-host/filesystems.nix` defaults to `/dev/vda` (a VM disk).
  Point `device` at the host's real disk (or override it at install time with the
  `main=<device>` argument shown above) before formatting anything for real.
- **sops secrets** are keyed to the host's SSH key (converted to an age key).
  On a brand-new host whose `hyprnixos.hostAgeKey` isn't set yet, secrets won't
  decrypt at activation, so enroll it before the first real switch: get the key
  with `ssh-keyscan <host> | ssh-to-age` (or locally
  `ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub`), set it in the host's
  `options.nix`, and run `nix run .#sops-sync`.

  Hosts are not trusted by default. Each sops file has its own recipient list:
  `secrets/common.yaml` (all hosts), `secrets/users/<name>.yaml` (only hosts
  that enable that user, plus the user's own `ageKey` if set),
  `secrets/hosts/<name>.yaml` (only that host). A host can never decrypt a
  secret outside its scopes, and the nix declarations mirror the same
  boundaries (`modules/system/security/sops.nix`, the `modules/users/<name>.nix`
  profiles, `modules/hosts/<name>/`). `.sops.yaml` is generated from the host
  and user options by `nix run .#sops-sync` — never edit it by hand; a
  pre-commit hook rejects drift.

### Doing it by hand

If you'd rather not use the shell, run the same steps directly — pass the
caches with `--option extra-substituters "<urls>"` and
`--option extra-trusted-public-keys "<keys>"` (the exact values are in
`modules/system/programs/nix.nix`). The wrappers in
`modules/flake-parts/install-shell.nix` show the full command for each step.

## How to use

- Replace credentials in `modules/home/programs/programming/git.nix`
- For new hosts, add a directory under `modules/hosts/<name>/`
- For new users, add a profile under `modules/users/<name>.nix` and enable it on
  a host with `hyprnixos.users.<name>.enable = true`
- Add or edit secrets with `sops secrets/<scope>.yaml` (decrypts with the GPG
  admin key from `.sops.yaml`), then declare them at the matching scope:
  common ones in `modules/system/security/sops.nix`, user ones in
  `modules/users/<name>.nix`, host ones in `modules/hosts/<name>/`

## Secure Boot (first boot on a new host)

Key creation and enrollment are handled automatically by the Limine bootloader:
on the first `nixos-rebuild` where no keys exist yet, it runs `sbctl create-keys`,
`sbctl enroll-keys`, and signs the bootloader. This only triggers when the host
sets `secureBootConfigured = true` and `/var/lib/sbctl` does not already exist.

Only the firmware-side steps remain manual, because they require physical
presence and cannot be scripted:

1. `systemctl reboot --firmware-setup`
2. In the firmware, enable Secure Boot **Setup Mode** (or erase the existing
   keys). `sbctl enroll-keys` only succeeds while the Platform Key is cleared.
   Take care on ThinkPad and Framework 13.
3. Set `secureBootConfigured = true` in the host options.
4. Run `nixos-rebuild boot --flake .` — the module now creates, enrolls, and
   signs with no further input.
5. Reboot into the firmware once more and confirm Secure Boot is enabled.

## Attributions

- [Zaney](https://gitlab.com/Zaney/zaneyos) and his ZaneyOS for the solid base
  for my system
- [Fufexan](https://github.com/fufexan/dotfiles) for the Hyprland, hyprlock, and
  hypridle stuff
