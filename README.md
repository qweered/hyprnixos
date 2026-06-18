# HyprNixOS

A NixOS configuration flake for a Hyprland-based desktop, built with
[`flake-parts`](https://flake.parts) and [`import-tree`](https://github.com/vic/import-tree).

Every sub-directory of `modules/hosts/` is a host: its name becomes the
`nixosConfiguration` (and hostname), and its private modules live alongside it.
Everything else under `modules/` is shared across all hosts. CPU/GPU variant
files (e.g. `modules/system/hardware/cpu/amd.nix`) are auto-selected per host
from the `cpu`/`gpu` options.

## Installing on a new host

The binary caches are declared in `modules/system/programs/nix.nix`, but that
config only becomes active *after* the first switch. So during installation the
substituters and keys have to be passed by hand on every command. Rather than
retyping them, enter the **install shell** — it provides three wrappers with the
caches (read straight from the system's own nix config) baked in:

```bash
nix develop github:qweered/hyprnixos#install
```

It prints its own help on entry. Each wrapper takes the host name (the directory
under `modules/hosts/`):

```bash
# 1. partition + format the device and install the system in one step (disko-install)
hyprnixos-format new-host /dev/disk/by-id/nvme-...   # DESTRUCTIVE

reboot

# 2. first `nh os switch` on the booted system
hyprnixos-switch new-host
```

`hyprnixos-format` runs [`disko-install`](https://github.com/nix-community/disko/blob/master/docs/disko-install.md),
which partitions/formats the given device (overriding the `device` in the host's
disko config) and then runs `nixos-install` — so there is no separate install
step.

Set `FLAKE=<ref>` to install from somewhere other than the published flake
(e.g. `FLAKE=. hyprnixos-switch new-host` to use a local clone). From the second
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
