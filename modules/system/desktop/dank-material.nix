{
  cfg,
  config,
  lib,
  pkgs,
  ...
}:
let
  # TODO: multiuser
  hyprFiles = config.home-manager.users.qweered.xdg.configFile;
  cursor = config.home-manager.users.qweered.home.pointerCursor;
in
{
  programs = {
    dux-shell.enable = true;
    dux-files = {
      enable = true;
      portal.enable = true;
    };
  };

  services.displayManager = {
    defaultSession = "hyprland-uwsm";
    dux-greeter = {
      enable = true;
      configHome = cfg.users.qweered.homeDirectory;
      compositor = {
        name = "hyprland";
        customConfig = /* lua */ ''
          hl.env("DMS_RUN_GREETER", "1")
          hl.env("XCURSOR_PATH", "${cursor.package}/share/icons")
          hl.env("XCURSOR_THEME", "${cursor.name}")
          hl.env("XCURSOR_SIZE", "${toString cursor.size}")
          hl.env("HYPRCURSOR_THEME", "${cursor.name}")
          hl.env("HYPRCURSOR_SIZE", "${toString cursor.size}")
          dofile("${hyprFiles."hypr/_vars.lua".source}")
          dofile("${hyprFiles."hypr/settings.lua".source}")
          dofile("${hyprFiles."hypr/hardware.lua".source}")
        '';
      };
    };
  };

  # The nixpkgs module only chowns non-hidden entries in /var/lib/dms-greeter:
  # `chown dms-greeter:dms-greeter *` and uses tmpfiles `.d` instead of `.Z`.
  # Leftovers from an earlier greeter account (e.g. .cache, .local owned by
  # `greeter`) stay inaccessible, and the greeter dies with "mkdir
  # /var/lib/dms-greeter/.cache/dms-greeter-shell: permission denied".
  # Fixed upstream in https://github.com/duxlabs-dev/dux-greeter/issues/11,
  # TODO: still present in nixpkgs `dux-greeter.nix`
  systemd.tmpfiles.settings = lib.mkIf config.services.displayManager.dux-greeter.enable {
    "10-dms-greeter"."/var/lib/dms-greeter".Z = {
      user = "dms-greeter";
      group = "dms-greeter";
    };
  };

  # NOTE: workaround for https://github.com/NixOS/nixpkgs/issues/86884
  # Needed to auto keyring unlock on login
  # Also see https://github.com/JohnRTitor/nix-conf/blob/10144967486579287e270ed31b9692b8d297b1e7/modules/system/services/oo7.nix#L11
  security.pam.services.dms-greeter.enableGnomeKeyring = true;

  xdg.portal = lib.mkIf (lib.elem "hyprland" cfg.sessions) {
    enable = true;
    # Remove xdg-desktop-portal-gtk (added by programs.hyprland) and any other
    # unrequested portals; keep only dux-files, hyprland, and gnome-keyring.
    # TODO: fix this properly, portal-gtk pulled by hyprland session, but it will be unneeded in next version
    extraPortals = lib.mkForce [
      config.programs.dux-files.package
      config.programs.hyprland.portalPackage
      pkgs.gnome-keyring
    ];
    config.hyprland = {
      default = [
        "dfiles"
        "hyprland"
      ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };
  };
}
