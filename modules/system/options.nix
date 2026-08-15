{
  lib,
  config,
  pkgs,
  ...
}:

{
  options.hyprnixos = {
    sessions = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "hyprland"
          "kde"
        ]
      );
      example = [ "hyprland" ];
      description = "Desktop environments and window managers to install; the greeter offers one session per entry.";
    };
    stateVersion = lib.mkOption {
      type = lib.types.str;
      example = "26.05";
      description = "State version of the system.";
    };
    userProfiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "qweered" ];
      description = ''
        Names of `modules/users/<name>.nix` profiles this host runs. Each one
        becomes a normal user account with a home-manager configuration importing
        the shared `modules/home` tree, and populates `users.<name>` below.
      '';
    };
    secureBootConfigured = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set to true if manual configuration for secure boot has been performed";
    };
    # TODO: should be done via facter
    hostPlatform = lib.mkOption {
      type = lib.types.enum lib.systems.flakeExposed;
      example = "x86_64-linux";
      description = "Platform of the host.";
    };
    # TODO: should be done via facter
    defaultScreenResolution = lib.mkOption {
      type = lib.types.strMatching "[0-9]+x[0-9]+";
      default = "1920x1080";
      example = "2560x1440";
      description = "Default screen resolution, formatted as WIDTHxHEIGHT, used for monitor and display configuration.";
    };
    kernelFlavour = lib.mkOption {
      # `*` marks the flavours that also ship -march builds
      type = lib.types.enum [
        "bore" # * BORE scheduler over EEVDF, CachyOS' flagship
        "bore-lto" # *
        "latest" # * newest stable mainline
        "latest-lto" # *
        "lts" # * long-term support series
        "lts-lto" # *
        # All of kernels below have lts variants but without cache
        "server" # server workload tuning
        "hardened" # hardening patch set; trails mainline by a series
        "rc" # mainline release candidate
        "bmq" # BMQ (Project C) scheduler
        "deckify" # handheld / Steam Deck tuning
        "eevdf" # stock mainline EEVDF, no alternative scheduler
        "rt-bore" # PREEMPT_RT realtime + BORE
      ];
      default = "latest-lto";
      example = "server";
      description = ''
        CachyOS kernel flavour, without the `linuxPackages-cachyos-` prefix and
        without any `-x86_64-vN` suffix: that is derived from the facter report.
        `-lto` variants are the same tree built with Clang+ThinLTO.
      '';
    };
    users = lib.mkOption {
      readOnly = true;
      example = {
        qweered = { };
      };
      description = ''
        The profiles named by `userProfiles`, keyed by username and read back for
        their details (shell, browser, home directory, ...). Set by the generated
        users module in entrypoint.nix, not by hand.
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
                type = lib.types.listOf lib.types.str;
                default = [
                  "us"
                  "ru"
                ];
                example = [
                  "canary"
                  "rus_canary"
                ];
                description = "XKB layouts this user types in, most-preferred first. Merged with the other profiles' into services.xserver.xkb.layout.";
              };
              secrets = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                example = [ "context7-api-key" ];
                description = ''
                  Keys of secrets/users/<name>.yaml to expose as
                  /run/secrets/<name>/<key>, readable only by this user. Declared
                  on the hosts that run the profile, which are exactly the hosts
                  the file is encrypted to.
                '';
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
  };

  # TODO: configure locale

  config = {
    _module.args.cfg = config.hyprnixos;
    nixpkgs.hostPlatform = config.hyprnixos.hostPlatform;
    system.stateVersion = config.hyprnixos.stateVersion;
  };
}
