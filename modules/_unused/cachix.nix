{
  config,
  lib,
  pkgs,
  ...
}:
let
  cache_name = "qweered";
  socket = "/run/cachix-daemon/socket";

  # Watches the system profile and pushes the locally-produced part of every new
  # generation, handing paths to the daemon over a unix socket, so it needs no
  # credentials of its own. Runs only as cachix-push-system.service.
  # NOTE: if you have unlimited cachix, services.cachix-watch-store is simpler.
  pushSystem = pkgs.writeShellApplication {
    name = "cachix-push-system";
    runtimeInputs = [
      config.nix.package
      pkgs.cachix
      pkgs.coreutils
      pkgs.inotify-tools
      pkgs.jq
    ];
    text = ''
      profiles=/nix/var/nix/profiles

      # Re-pushing a generation is cheap and worth it: the daemon skips whatever
      # the cache already holds, so a repeat finishes in 0s, and a push whose
      # upload never landed gets another chance.
      push() {
        local resolved waited=0
        resolved=$(readlink -f "$profiles/system")

        # cachix-daemon is Type=simple, so its socket lands a moment after
        # systemd already considers the unit active.
        while [ ! -S ${socket} ] && [ "$waited" -lt 60 ]; do
          sleep 1
          waited=$((waited + 1))
        done
        if [ ! -S ${socket} ]; then
          echo "cachix: ${socket} never appeared, skipping push" >&2
          return 0
        fi

        # Substituted paths carry their cache's signature and local builds carry
        # none (asserted below), so "unsigned" means "built here" and stays
        # correct as substituters come and go.
        local paths
        mapfile -t paths < <(
          nix path-info --json-format 1 --json --recursive "$resolved" |
            jq -r 'to_entries[] | select((.value.signatures // []) | length == 0) | .key'
        )

        if [ "''${#paths[@]}" -eq 0 ]; then
          echo "cachix: nothing locally built in $resolved"
        else
          echo "cachix: queueing ''${#paths[@]} locally-built paths from $resolved"
          cachix daemon push --socket ${socket} "''${paths[@]}"
        fi
      }

      # Nothing watched the profile while we were down.
      push

      # The profile symlink itself cannot be watched: inotify resolves it and
      # watches the inode behind it, so an atomic replacement raises nothing
      # (systemd/systemd#31941, which .path units hit too). nix stages a
      # generation as system-N-link and then renames a temp symlink over
      # `system`, so moved_to on `system` is exactly one event per rebuild, at
      # the moment the profile changes. Deletions are outside the mask, so
      # `nh clean` reaping generations stays silent.
      inotifywait --quiet --monitor --event moved_to --format '%f' "$profiles" |
        while read -r changed; do
          if [ "$changed" = system ]; then
            push
          fi
        done
    '';
  };
in
{
  environment.systemPackages = [ pkgs.cachix ]; # for `cachix doctor`

  # nix.settings.secret-key-files is a freeform key with no declared option, so
  # a second definition would merge silently rather than conflict. Signing local
  # builds would leave cachix-push-system with nothing to push, and it would say
  # so only in the journal, so fail evaluation instead.
  assertions = [
    {
      assertion = (config.nix.settings.secret-key-files or [ ]) == [ ];
      message = ''
        nix.settings.secret-key-files is set, which signs locally-built paths.
        cachix-push-system tells local builds from substituted ones by the absence
        of a signature, so it would push nothing. Teach it to select paths signed
        by your own key before setting this.
      '';
    }
  ];

  systemd.services = {
    cachix-daemon = {
      description = "Cachix push daemon for ${cache_name} cache";
      wants = [ "network-online.target" ];
      requires = [ "sops-install-secrets.service" ];
      after = [
        "network-online.target"
        "sops-install-secrets.service"
      ];
      wantedBy = [ "multi-user.target" ];
      path = [ config.nix.package ];
      unitConfig = {
        # Allow restarting indefinitely; a wedged daemon must not stay down.
        StartLimitIntervalSec = 0;
        ConditionFileNotEmpty = config.sops.secrets.cachix-auth-token.path;
      };
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 1;
        RestartSteps = 5;
        RestartMaxDelaySec = "5min";
        DynamicUser = true;
        RuntimeDirectory = "cachix-daemon";
        # On SIGTERM cachix exits immediately and drops whatever it has not
        # committed; SIGINT takes its ShutdownGracefully path instead, which is
        # what makes TimeoutStopSec meaningful.
        KillSignal = "SIGINT";
        TimeoutStopSec = 180;
        Nice = 19;
        CPUWeight = 20;
        IOSchedulingClass = "idle";
        LoadCredential = [ "cachix-token:${config.sops.secrets.cachix-auth-token.path}" ];
      };
      script =
        let
          args = lib.escapeShellArgs [
            "daemon"
            "run"
            "--no-remote-stop"
            "--socket"
            socket
            "--compression-method"
            "zstd"
            "--compression-level"
            "12" # 4x faster than 16, ~same compression
            cache_name
          ];
        in
        ''
          exec env CACHIX_AUTH_TOKEN="$(<"$CREDENTIALS_DIRECTORY/cachix-token")" \
            ${lib.getExe pkgs.cachix} ${args}
        '';
    };

    cachix-push-system = {
      description = "Push each new system generation to ${cache_name} cache";
      wants = [ "cachix-daemon.service" ];
      after = [ "cachix-daemon.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = lib.getExe pushSystem;
        # Nothing else watches the profile, so never leave it down.
        Restart = "always";
        RestartSec = 5;
        Nice = 19;
        CPUWeight = 20;
        IOSchedulingClass = "idle";
      };
    };
  };
}
