# HyprNixOS

A NixOS configuration flake for a Hyprland-based desktop, built with
[`flake-parts`](https://flake.parts) and [`import-tree`](https://github.com/vic/import-tree).

Every sub-directory of `modules/hosts/` is a host: its name becomes the
`nixosConfiguration` (and hostname), and its private modules live alongside it.
Everything else under `modules/` is shared across all hosts. CPU/GPU variant
files (e.g. `modules/system/hardware/cpu/amd.nix`) are auto-selected per host
from the `cpu`/`gpu` options.

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
- **`new-host` needs real values before it'll install.** `hostName = null`,
  `cpu`/`gpu`, and `device = "/dev/disk/by-id/some-disk-id"` in
  `modules/hosts/new-host/{options,filesystems}.nix` are `CHANGE ME`
  placeholders — disko will refuse the bogus disk id.
- **agenix secrets** are keyed to the host's SSH key. On a brand-new host whose
  host key isn't enrolled yet, secrets won't decrypt on first boot — but thanks
  to the `or null` guard in `modules/system/config.nix`, users cleanly fall back
  to `initialPassword = "password"` instead of failing the build. Re-run
  `agenix rekey` + switch once the host key exists.

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
  a host with `hyprnix.users.<name>.enable = true`
- Add secrets with `agenix edit secrets/<name>.age` and rekey with
  `agenix rekey -a`

## Secure Boot (first boot on a new host)

Key creation and enrollment are handled automatically by the Limine bootloader:
on the first `nixos-rebuild` where no keys exist yet, it runs `sbctl create-keys`,
`sbctl enroll-keys`, and signs the bootloader. This only triggers when the host
sets `isSecureBootConfigured = true` and `/var/lib/sbctl` does not already exist.

Only the firmware-side steps remain manual, because they require physical
presence and cannot be scripted:

1. `systemctl reboot --firmware-setup`
2. In the firmware, enable Secure Boot **Setup Mode** (or erase the existing
   keys). `sbctl enroll-keys` only succeeds while the Platform Key is cleared.
   Take care on ThinkPad and Framework 13.
3. Set `isSecureBootConfigured = true` in the host options.
4. Run `nixos-rebuild boot --flake .` — the module now creates, enrolls, and
   signs with no further input.
5. Reboot into the firmware once more and confirm Secure Boot is enabled.

## Attributions

- [Zaney](https://gitlab.com/Zaney/zaneyos) and his ZaneyOS for the solid base
  for my system
- [Fufexan](https://github.com/fufexan/dotfiles) for the Hyprland, hyprlock, and
  hypridle stuff
