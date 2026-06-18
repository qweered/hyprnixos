{
  lib,
  config,
  pkgs,
  ...
}:

{
  options.hyprnix = {
    desktop = lib.mkOption {
      type = lib.types.enum [
        "hyprland"
        "kde"
      ];
      description = "Which desktop environment / window manager to enable.";
    };
    isWindowManager = lib.mkOption {
      type = lib.types.bool;
      default = config.hyprnix.desktop == "hyprland";
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
        Users to create on this host, keyed by username. For each entry a normal
        user account is created and a home-manager configuration is wired up that
        imports the shared `modules/home` tree.
      '';
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
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
    isSecureBootConfigured = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set to true if manual configuration for secure boot has been performed";
    };
    kernel = lib.mkOption {
      type = lib.types.raw;
      default = pkgs.cachyosKernels.linuxPackages-linux-cachyos-latest-lto;
      description = "The kernel packages set to use (passed to boot.kernelPackages)";
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
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "Hostname of the host.";
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
    _module.args.cfg = config.hyprnix;
    nixpkgs.hostPlatform = config.hyprnix.hostPlatform;
    networking.hostName = config.hyprnix.hostName;
    system.stateVersion = config.hyprnix.stateVersion;
  };
}
