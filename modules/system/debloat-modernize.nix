{ lib, ... }:

{
  # Perlless https://github.com/NixOS/nixpkgs/blob/0260f927b7c1578b5c7cdefd7db7b660565cd362/nixos/modules/profiles/perlless.nix
  # TODO: Check that the system does not contain a Nix store path that contains the string "perl".
  # system.forbiddenDependenciesRegexes = [ "perl" ];

  # Remove unnecessary packages
  environment.defaultPackages = lib.mkForce [ ];
  programs.nano.enable = false;
  services.speechd.enable = false;

  documentation = {
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  # /etc becomes a read-only overlayfs generated from the nix config, masking
  # anything install-time that lived on the mutable /etc. Keep such state
  # elsewhere -- e.g. the sops host key on /var/lib, see
  # modules/system/security/sops.nix.
  #
  # `mutable = false` stacks no upperdir over the erofs lowerdirs, so nothing
  # writes /etc at runtime. Note the overlay shadows the on-disk /etc rather
  # than migrating it, so state left there is lost on the first switch even with
  # mutable = true. What that costs, and where each stands upstream:
  #
  #   - NetworkManager's saved networks, i.e. Wi-Fi does not come up at all.
  #     TODO: set `networking.networkmanager.settings.keyfile.path` to
  #     /var/lib/NetworkManager/system-connections -- upstream derives its
  #     tmpfiles rule from that option, so the 0700 dir follows. Not applied
  #     yet because it only works together with a manual, one-shot
  #       sudo cp -aT /etc/NetworkManager/system-connections \
  #                   /var/lib/NetworkManager/system-connections
  #     run while still booted on a mutable-/etc generation; switching first
  #     drops every saved SSID and PSK.
  #
  #   - /etc/sub{u,g}id, so rootless podman/distrobox. userborn can write them,
  #     but nixos/userborn.nix passes neither the users.users.<name>.sub*Ranges
  #     options into its config JSON nor the files in `passwordFiles`, so
  #     /var/lib/nixos/sub*id come out empty and never reach /etc.
  #     TODO: NixOS/nixpkgs#508608 fixes both halves and seeds from the legacy
  #     /var/lib/nixos/auto-subuid-map. Open and mergeable 2026-08-16; its
  #     prerequisite #510342 merged 2026-08-14, a day past our pin. Don't
  #     hand-roll an environment.etc workaround -- that PR bind-mounts rather
  #     than symlinks the subid files, since newuidmap opens them O_NOFOLLOW.
  #
  #   - Automatic timezone, and runtime-editable /etc/hosts for CTF work.
  #     TODO: no upstream fix for either; /etc/localtime and /etc/hosts are
  #     hardcoded in glibc, so neither relocates the way the keyfiles did.
  system.etc.overlay = {
    enable = true;
    mutable = true; # Did you read comment above?
  };

  # TODO: enable upstream
  systemd.enableStrictShellChecks = true;

  # TODO: enable upstream
  programs.fish.useBabelfish = true;
}
