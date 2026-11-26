{ inputs, lib, ... }:

{
  imports = [ inputs.cade.nixosModules.default ];

  programs.cade = {
    enable = true;
    enableFishIntegration = false; # https://github.com/manic-systems/cade/issues/83
  };

  programs.fish.interactiveShellInit = lib.mkAfter ''
    function __cade_hook --on-event fish_prompt
      set -l __cade_status $status
      if set -q __cade_bg_pid; and kill -0 $__cade_bg_pid 2>/dev/null
        if test "$__cade_bg_pwd" = "$PWD"
          return $__cade_status
        end
        kill $__cade_bg_pid 2>/dev/null
      end

      set -l tmp (mktemp)
      set -g __cade_bg_pwd $PWD
      command cade --owner-pid $fish_pid --verbosity quiet reload --shell fish > $tmp 2>/dev/null &
      set -l pid $last_pid
      set -g __cade_bg_pid $pid

      function __cade_apply_$pid --on-process-exit $pid --inherit-variable tmp --inherit-variable pid
        if test "$__cade_bg_pid" = "$pid"
          set -e __cade_bg_pid
        end
        if test -f $tmp
          source $tmp
          rm -f $tmp
        end
        functions -e __cade_apply_$pid
        if status is-interactive
          commandline -f repaint 2>/dev/null
        end
      end

      return $__cade_status
    end
  '';
}
