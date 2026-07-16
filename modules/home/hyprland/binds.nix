{
  lib,
  osConfig,
  pkgs,
  ...
}:

let
  lua = lib.generators.mkLuaInline;
  launcher = "vicinae toggle";
  terminal = "ghostty";
  brightnessUp = "brillo -q -u 300000 -A 5";
  brightnessDown = "brillo -q -u 300000 -U 5";
  volumeUp = "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
  volumeDown = "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-";
  run = app: "uwsm app -- ${app}";
  toggle = app: "pkill ${builtins.head (builtins.split " " app)} || uwsm app -- ${app}";
  micInsteadOfSpeaker = if osConfig.networking.hostName == "hyprnix" then "@DEFAULT_AUDIO_SOURCE@" else "@DEFAULT_AUDIO_SINK@";

  exec = command: "hl.dsp.exec_cmd(${builtins.toJSON command})";
  modKey = keys: lua ''mod .. " + ${keys}"'';
  bind = key: dispatcher: {
    _args = [
      key
      (lua dispatcher)
    ];
  };
  bindWith = key: dispatcher: options: {
    _args = [
      key
      (lua dispatcher)
      options
    ];
  };

  screenshot = pkgs.writeShellScript "screenshot" ''
    set -euo pipefail

    screenshot_dir="$HOME/Pictures/Screenshots"
    # TODO: do not create it on each call
    ${pkgs.coreutils}/bin/mkdir -p "$screenshot_dir"

    geometry="$(${pkgs.slurp}/bin/slurp -b 1B1F28CC -s C778DD0D)" || exit 0
    ${pkgs.grim}/bin/grim -g "$geometry" - | \
      ${pkgs.satty}/bin/satty --filename - --fullscreen \
        --output-filename "$screenshot_dir/Screenshot_$(${pkgs.coreutils}/bin/date +"%Y%m%d_%H%M%S").png" \
        --init-tool brush --copy-command ${pkgs.wl-clipboard}/bin/wl-copy
  '';
  toggleShader = pkgs.writeShellScript "toggle-shader" ''
    STATE="''${XDG_RUNTIME_DIR:-/tmp}/hypr-shader-on"
    if [[ -f "$STATE" ]]; then
      hyprctl eval 'hl.config({ decoration = { screen_shader = "[[EMPTY]]" } })'
      rm "$STATE"
      hyprctl notify -1 1200 0 "shader: off"
    else
      hyprctl eval 'hl.config({ decoration = { screen_shader = "${../../../assets/shadow-lift.frag}" } })'
      touch "$STATE"
      hyprctl notify -1 1200 0 "shader: on"
    fi
  '';

  workspaces = [
    1
    2
    3
    4
    5
    6
    7
  ];
in
{
  wayland.windowManager.hyprland.settings = {
    config = {
      binds.allow_workspace_cycles = true;
      gestures.workspace_swipe_forever = false;
    };

    gesture = [
      {
        fingers = 3;
        direction = "horizontal";
        action = "workspace";
      }
      {
        fingers = 3;
        direction = "down";
        action = lua "function() hl.dispatch(${exec "dms ipc call hypr toggleOverview"}) end";
      }
      {
        fingers = 3;
        direction = "up";
        action = "special";
        workspace_name = "magic";
      }
      {
        fingers = 4;
        direction = "left";
        action = lua "function() hl.dispatch(hl.dsp.window.move({ workspace = -1 })) end";
      }
      {
        fingers = 4;
        direction = "right";
        action = lua ''function() hl.dispatch(hl.dsp.window.move({ workspace = "+1" })) end'';
      }
      {
        fingers = 4;
        direction = "pinch";
        action = "fullscreen";
      }
    ];

    workspace_rule = {
      workspace = "special:magic";
      on_created_empty = run terminal;
    };

    bind = [
      (bind (modKey "Return") (exec (run terminal)))
      (bind (modKey "B") (exec (run "$BROWSER")))
      (bind (modKey "SPACE") (exec launcher))
      (bind (modKey "Print") (exec "${screenshot}"))
      (bind (modKey "W") (exec (toggle "activate-linux -d")))
      (bind (modKey "F12") (exec "${toggleShader}"))

      (bind "ALT + Tab" "hl.dsp.focus({ last = true })")
      (bind (modKey "ALT + Tab") "hl.dsp.window.bring_to_top()")
      (bind (modKey "M") ''hl.dsp.workspace.toggle_special("magic")'')
      (bind (modKey "P") ''hl.dsp.window.move({ workspace = "special:magic" })'')
      (bind "CTRL + ALT + Delete" "hl.dsp.exit()")
      (bind (modKey "Q") "hl.dsp.window.close()")
      (bind (modKey "T") ''hl.dsp.window.float({ action = "toggle" })'')
      (bind (modKey "F") "hl.dsp.window.fullscreen()")
      (bind (modKey "S") ''hl.dsp.layout("togglesplit")'')

      (bind (modKey "k") ''hl.dsp.focus({ direction = "up" })'')
      (bind (modKey "j") ''hl.dsp.focus({ direction = "down" })'')
      (bind (modKey "l") ''hl.dsp.focus({ direction = "right" })'')
      (bind (modKey "h") ''hl.dsp.focus({ direction = "left" })'')
      (bind (modKey "left") "hl.dsp.focus({ workspace = -1 })")
      (bind (modKey "right") ''hl.dsp.focus({ workspace = "+1" })'')
      (bind (modKey "SHIFT + left") "hl.dsp.window.move({ workspace = -1 })")
      (bind (modKey "SHIFT + right") ''hl.dsp.window.move({ workspace = "+1" })'')

      (bind (modKey "CTRL + k") "hl.dsp.window.resize({ x = 0, y = -20, relative = true })")
      (bind (modKey "CTRL + j") "hl.dsp.window.resize({ x = 0, y = 20, relative = true })")
      (bind (modKey "CTRL + l") "hl.dsp.window.resize({ x = 20, y = 0, relative = true })")
      (bind (modKey "CTRL + h") "hl.dsp.window.resize({ x = -20, y = 0, relative = true })")
      (bind (modKey "ALT + k") "hl.dsp.window.move({ x = 0, y = -20, relative = true })")
      (bind (modKey "ALT + j") "hl.dsp.window.move({ x = 0, y = 20, relative = true })")
      (bind (modKey "ALT + l") "hl.dsp.window.move({ x = 20, y = 0, relative = true })")
      (bind (modKey "ALT + h") "hl.dsp.window.move({ x = -20, y = 0, relative = true })")

      (bindWith "XF86MonBrightnessUp" (exec brightnessUp) {
        locked = true;
        repeating = true;
      })
      (bindWith "XF86MonBrightnessDown" (exec brightnessDown) {
        locked = true;
        repeating = true;
      })
      (bindWith "XF86AudioRaiseVolume" (exec volumeUp) {
        locked = true;
        repeating = true;
      })
      (bindWith "XF86AudioLowerVolume" (exec volumeDown) {
        locked = true;
        repeating = true;
      })

      (bindWith "XF86AudioPlay" (exec "playerctl play-pause") { locked = true; })
      (bindWith "XF86AudioPrev" (exec "playerctl previous") { locked = true; })
      (bindWith "XF86AudioNext" (exec "playerctl next") { locked = true; })
      (bindWith "XF86AudioMute" (exec "wpctl set-mute ${micInsteadOfSpeaker} toggle") { locked = true; })
      (bindWith "XF86AudioMicMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle") {
        locked = true;
      })

      (bindWith (modKey "mouse:272") "hl.dsp.window.drag()" { mouse = true; })
      (bindWith (modKey "mouse:273") "hl.dsp.window.resize()" { mouse = true; })
    ]
    ++ (map (i: bind (modKey (toString i)) "hl.dsp.focus({ workspace = ${toString i} })") workspaces)
    ++ (map (i: bind (modKey "SHIFT + ${toString i}") "hl.dsp.window.move({ workspace = ${toString i} })") workspaces);

    #TODO: recheck this:
    #      bind = ${modifier}SHIFT,SPACE,movetoworkspace,special
    #      bind = ${modifier}CONTROL,right,workspace,e+1
    #      bind = ${modifier}CONTROL,left,workspace,e-1
    #      bind = ${modifier},mouse_down,workspace, e+1
    #      bind = ${modifier},mouse_up,workspace, e-1
    # "col.nogroup_border" = 1;
    # "col.nogroup_border_active" = 1;
    # snap =  {
    #    enabled = true;
    # };
    # CONFIG: choose between dim and opacity for inactive windows
    #        decoration.inactive_opacity = 0.7;
    #        decoration.dim_inactive = true;
  };
}
