{
  lib,
  config,
  pkgs,
  ...
}:

{
  options.hyprnixos = {
    desktop = lib.mkOption {
      type = lib.types.enum [
        "hyprland"
        "kde"
      ];
      description = "Which desktop environment / window manager to enable.";
    };
    isWindowManager = lib.mkOption {
      type = lib.types.bool;
      default = config.hyprnixos.desktop == "hyprland";
      description = "Whether current desktop environment is a window-manager.";
    };
    defaultScreenResolution = lib.mkOption {
      type = lib.types.strMatching "[0-9]+x[0-9]+";
      default = "1920x1080";
      example = "2560x1440";
      description = "Default screen resolution, formatted as WIDTHxHEIGHT, used for monitor and display configuration.";
    };
    stateVersion = lib.mkOption {
      type = lib.types.str;
      example = "26.05";
      description = "State version of the system.";
    };
    users = lib.mkOption {
      default = { };
      example = {
        qweered = { };
      };
      description = ''
        User profiles, keyed by username. Defining a user here only describes it
        (shell, browser, home directory, ...) and leaves it disabled; profiles are
        typically supplied by the shared `modules/users/<name>.nix` tree, so every
        host sees every definition. A profile is created on a host only when that
        host sets `users.<name>.enable = true`, at which point a normal user account
        is created and a home-manager configuration importing the shared
        `modules/home` tree is wired up.
      '';
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              enable = lib.mkEnableOption "this user on the host; profiles default to disabled so they are only created where explicitly enabled";
              name = lib.mkOption {
                type = lib.types.str;
                default = name;
                description = "Username; defaults to the attribute name.";
              };
              description = lib.mkOption {
                type = lib.types.str;
                description = "GECOS description of the user.";
              };
              shell = lib.mkOption {
                type = lib.types.shellPackage;
                default = pkgs.fish;
                description = "Login shell for the user.";
              };
              groups = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                description = "Additional groups to add the user to, on top of system defaults.";
              };
              browser = lib.mkOption {
                type = lib.types.str;
                description = "Preferred web browser; exported as $BROWSER in the user's session.";
              };
              keyboardLayouts = lib.mkOption {
                type = lib.types.str;
                default = "us,ru";
                description = "Comma-separated X keyboard layouts, passed to services.xserver.xkb.layout (system-wide).";
              };
              homeDirectory = lib.mkOption {
                type = lib.types.str;
                default = "/home/${name}";
                description = "Home directory of the user.";
              };
              flakeDirectory = lib.mkOption {
                type = lib.types.str;
                default = "/home/${name}/hyprnixos";
                description = "Path to this user's clone of the flake.";
              };
            };
          }
        )
      );
    };
    secureBootConfigured = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set to true if manual configuration for secure boot has been performed";
    };
    cpu = lib.mkOption {
      type = lib.types.enum [
        "amd"
        "intel"
      ];
      description = "CPU architecture of the host.";
    };
    gpu = lib.mkOption {
      type = lib.types.enum [
        "amd"
        "intel"
        "nvidia"
      ];
      description = "GPU architecture of the host.";
    };
    hostPlatform = lib.mkOption {
      type = lib.types.enum lib.systems.flakeExposed;
      example = "x86_64-linux";
      description = "Platform of the host.";
    };
  };

  # TODO: configure keyboard, timezone, locale
  # TODO: for cpu and gpu migrate to facter

  config = {
    _module.args.cfg = config.hyprnixos;
    nixpkgs.hostPlatform = config.hyprnixos.hostPlatform;
    system.stateVersion = config.hyprnixos.stateVersion;
  };
}
