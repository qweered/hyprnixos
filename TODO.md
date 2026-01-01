# TODO

* make lazydocker work with podman
* add devenv, in flake.nix or in home-manager?
* home-manager in flake-parts? https://github.com/khaneliman/khanelinix/blob/4f55285944563cd24e07753eb484a557fa2d5cd1/flake/home.nix#L35
* matrix client
* right now users can't influence anything in system, only in home-manager
* credentials, agenix
* sort (imports, something else)
* jj - git replacement
* stylix
* check if anything in system have home-manager stuff (for example podman)
* disko
* allow-dirty = false;
* remove all TODO todos
* Hyprcursor
* home-manager.sharedModules
* see nixos-ex-flake and blueprint
* fix that i need to enter gpg and immediately keyring password on every boot
* my own plymouth theme
* check logs that there are no major errors
* multi-user, multi-gpu [ZaneyOS](https://gitlab.com/Zaney/zaneyos)
* denoising? [rnnoise](https://github.com/fufexan/dotfiles/blob/17939d902a780a6db459312baa40940ff2a9c149/home/programs/media/rnnoise.nix#L1C1-L41C2)
* refactor assets into github repository
* setup portals (what application opens what file)
* configure more kernel parameters
* [declarative-flatpak](https://github.com/GermanBread/declarative-flatpak) or [nix-flatpak](https://github.com/gmodena/nix-flatpak)
* snap ? appimage ?
* remove all CONFIG todos
* check all comments
* check all config options of nixos and home-manager
* check all nix-community repos
* impermanence
* enable cachy ananicy rules [chaotic](https://www.nyx.chaotic.cx/), apparmor?
* nix-mineral
* encrypt filesystem
* lanzaboote

## No longer want

* deduplicate all flake inputs like fufexan did - no point saves few megabytes and can invalidate cache
* zfs [chaotic](https://www.nyx.chaotic.cx) - don't need its features

## Nixpkgs contributions

* why the fuck i need to have exact length for hash to it start building and showing me actual hash?
* rename network-manager-applet to nm-applet in home manager repo

## Software to add

* [kunkun](https://github.com/kunkunsh/kunkun)
* [goneovim](https://github.com/akiyosi/goneovim)
* espanso
* kando-menu
* clight, hyprsunset
* ddcutil
* nix-search-tv
* diffoscope
* hellwal
* [fd](https://github.com/sharkdp/fd)
* [firedragon](https://firedragon.garudalinux.org)
* zathura imv - pdf/image viewer
* wluma - automatic brightness control
* unzip zip rar unrar - over 7z
* mc superfile xplr ranger lf nnn yazi broot - over ranger (yazi is best?)
* xxh + sshpass - transfer shell config over ssh
* activate-linux - fun windows watermark
