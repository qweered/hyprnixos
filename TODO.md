# TODO

* make lazydocker work with podman
* fix plymouth flick
* home-manager in flake-parts? https://github.com/khaneliman/khanelinix/blob/4f55285944563cd24e07753eb484a557fa2d5cd1/flake/home.nix#L35
* matrix client
* right now users can't influence anything in system, only in home-manager
* sort (imports, something else)
* jj - git replacement
* stylix
* check if anything in system have home-manager stuff (for example podman)
* disko
* remove all TODO todos
* Hyprcursor
* this page https://github.com/nix-community/srvos/blob/c4a21c42efec0506ec352891fec84490dae2ded0/nixos/common/nix.nix
* home-manager.sharedModules
* see nixos-ez-flake and blueprint, dendritic, vic, den
* multi-user, multi-gpu [ZaneyOS](https://gitlab.com/Zaney/zaneyos)
* denoising? [rnnoise](https://github.com/fufexan/dotfiles/blob/17939d902a780a6db459312baa40940ff2a9c149/home/programs/media/rnnoise.nix#L1C1-L41C2)
* refactor assets into github repository
* setup portals (what application opens what file)
* check logs that there are no major errors
* configure more kernel parameters
* snap ? appimage ?
* remove all CONFIG todos
* check all comments
* check all config options of nixos and home-manager
* check all nix-community repos
* impermanence
* nix-mineral
* encrypt filesystem
* lanzaboote

## No longer want

* allow-dirty = false - i don't commit immediately some changes though it is bad practice
* deduplicate all flake inputs like fufexan did - no point saves few megabytes and can invalidate cache
* zfs - don't need its features

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
* diffoscope
* hellwal
* [firedragon](https://firedragon.garudalinux.org)
* zathura imv - pdf/image viewer
* wluma - automatic brightness control
* unzip zip rar unrar - over 7z
* mc superfile xplr ranger lf nnn yazi broot - over ranger (yazi is best?)
* xxh + sshpass - transfer shell config over ssh
