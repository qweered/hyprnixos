# How to use

* TODO: add other install commands and test on real system
* Replace credentials in `modules/home/programs/git.nix`
* For new hosts add configuration to `modules/hosts`
* For new users add configuration to `modules/users`
* Add secrets via `agenix edit secrets/<name>.age` and rekey with `agenix rekey -a`

## Secure Boot (first boot on a new host)

Key creation and enrollment are handled automatically by the Limine on the first `nixos-rebuild` where no keys exist yet, it runs `sbctl create-keys`, `sbctl enroll-keys --microsoft --firmware-builtin`, and signs the bootloader. This only triggers when the host sets `isSecureBootConfigured = true` and `/var/lib/sbctl` does not already exist.

Only the firmware-side steps remain manual, because they require physical presence and cannot be scripted:

1. `systemctl reboot --firmware-setup`
2. In the firmware, enable Secure Boot **Setup Mode** (or erase the existing keys). `sbctl enroll-keys` only succeeds while the Platform Key is cleared.
   Caution on ThinkPad and Framework 13.
3. Set `isSecureBootConfigured = true` in host options.
4. Run `nixos-rebuild boot --flake .` — the module now creates, enrolls, and signs with no further input.
4. Reboot into the firmware once more and confirm Secure Boot is enabled.

## Attributions

* [Zaney](https://gitlab.com/Zaney/zaneyos) and his ZaneyOS for the solid base for my system
* [Fufexan](https://github.com/fufexan/dotfiles) for the hyprland, hyprlock and hypridle stuff
