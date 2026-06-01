{ cfg, pkgs, ... }:

let
  launcher = "vicinae toggle";
  terminal = "ghostty";
  brightnessUp = "brillo -q -u 300000 -A 5";
  brightnessDown = "brillo -q -u 300000 -U 5";
  volumeUp = "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
  volumeDown = "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-";
  run = app: "uwsm app -- ${app}";
  toggle = app: "pkill ${builtins.head (builtins.split " " app)} || uwsm app -- ${app}";
  micInsteadOfSpeaker = if cfg.hostName == "hyprnix" then "@DEFAULT_AUDIO_SOURCE@" else "@DEFAULT_AUDIO_SINK@";
  screenshot = pkgs.writeShellScript "screenshot" ''
    grim -g "$(slurp -b 1B1F28CC -s C778DD0D)" - | \
    satty --filename - --fullscreen \
      --output-filename ~/Pictures/Screenshots/Screenshot_$(date +"%Y%m%d_%H%M%S").png \
      --init-tool brush --copy-command wl-copy
  '';
  toggleShader = pkgs.writeShellScript "toggle-shader" ''
    STATE="''${XDG_RUNTIME_DIR:-/tmp}/hypr-shader-on"
    if [[ -f "$STATE" ]]; then
      hyprctl keyword decoration:screen_shader '[[EMPTY]]'
      rm "$STATE"
      hyprctl notify -1 1200 0 "shader: off"
    else
      hyprctl keyword decoration:screen_shader "${../../../assets/shadow-lift.frag}"
      touch "$STATE"
      hyprctl notify -1 1200 0 "shader: on"
    fi
  '';
in
{
  wayland.windowManager.hyprland.settings = {

    #      bind = ${modifier}SHIFT,SPACE,movetoworkspace,special
    #      bind = ${modifier}CONTROL,right,workspace,e+1
    #      bind = ${modifier}CONTROL,left,workspace,e-1
    #      bind = ${modifier},mouse_down,workspace, e+1
    #      bind = ${modifier},mouse_up,workspace, e-1
    binds = {
      allow_workspace_cycles = true;
    };

    gestures = {
      workspace_swipe_forever = false; # swipe multiple workspaces at once
      gesture = [
        "3, horizontal, workspace"
        "4, left, dispatcher, movetoworkspace, -1" # or monitor when i have more than one
        "4, right, dispatcher, movetoworkspace, +1"
        "4, pinch, fullscreen"
      ];
    };

    bindm = [
      "SUPER, mouse:272, movewindow"
      "SUPER, mouse:273, resizewindow"
    ];

    bind =
      let
        binding =
          mod: cmd: key: arg:
          "${mod}, ${key}, ${cmd}, ${arg}";
        moveFocus = binding "SUPER" "movefocus";
        workspace = binding "SUPER" "workspace";
        resizeActive = binding "SUPER_CTRL" "resizeactive";
        moveActive = binding "SUPER_ALT" "moveactive";
        moveToWorkspace = binding "SUPER_SHIFT" "movetoworkspace";
        arr = [
          1
          2
          3
          4
          5
          6
          7
        ];
      in
      [
        "SUPER, Return, exec, ${run terminal}"
        "SUPER, B, exec, ${run "$BROWSER"}"
        "SUPER, SPACE, exec, ${launcher}"
        "SUPER, Print, exec, ${screenshot}"
        "SUPER, W, exec, ${toggle "activate-linux -d"}"
        "SUPER, F12, exec, ${toggleShader}"

        "ALT, Tab, focuscurrentorlast"
        "SUPER_ALT, Tab, bringactivetotop"
        "SUPER, M, togglespecialworkspace, magic"
        "SUPER, P, movetoworkspace, special:magic"
        "CTRL_ALT, Delete, exit"
        "SUPER, Q, killactive"
        "SUPER, T, togglefloating"
        "SUPER, F, fullscreen"
        "SUPER, S, layoutmsg, togglesplit"

        (moveFocus "k" "u")
        (moveFocus "j" "d")
        (moveFocus "l" "r")
        (moveFocus "h" "l")
        (workspace "left" "-1")
        (workspace "right" "+1")
        (moveToWorkspace "left" "-1")
        (moveToWorkspace "right" "+1")
        (resizeActive "k" "0 -20")
        (resizeActive "j" "0 20")
        (resizeActive "l" "20 0")
        (resizeActive "h" "-20 0")
        (moveActive "k" "0 -20")
        (moveActive "j" "0 20")
        (moveActive "l" "20 0")
        (moveActive "h" "-20 0")
      ]
      ++ (map (i: workspace (toString i) (toString i)) arr)
      ++ (map (i: moveToWorkspace (toString i) (toString i)) arr);

    bindle = [
      ",XF86MonBrightnessUp,   exec, ${brightnessUp}"
      ",XF86MonBrightnessDown, exec, ${brightnessDown}"
      ",XF86AudioRaiseVolume,  exec, ${volumeUp}"
      ",XF86AudioLowerVolume,  exec, ${volumeDown}"
    ];

    bindl = [
      ",XF86AudioPlay,  exec, playerctl play-pause"
      ",XF86AudioPrev,  exec, playerctl previous"
      ",XF86AudioNext,  exec, playerctl next"
      ",XF86AudioMute,    exec, wpctl set-mute ${micInsteadOfSpeaker} toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ];
  };
}
