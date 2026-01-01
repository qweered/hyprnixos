{
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  inherit (lib) getExe' getExe;
  inherit (pkgs)
    writeShellScript
    wireplumber
    playerctl
    vicinae
    uwsm
    ghostty
    brillo
    clipse
    grim # screenshot
    slurp # screenshot
    satty # screenshot, over hyprshot swappy
    wl-clipboard # copy-paste in shell, over wl-clipboard-rs
    ;
  wpctl = getExe' wireplumber "wpctl";
  wlCopy = getExe' wl-clipboard "wl-copy";
  launcher = "${getExe vicinae} toggle";
  terminal = "${getExe ghostty}";
  brightnessUp = "${getExe brillo} -q -u 300000 -A 5";
  brightnessDown = "${getExe brillo} -q -u 300000 -U 5";
  clipboardManager = "${terminal} --class=clipse.app -e ${getExe clipse}";
  volumeUp = "${wpctl} set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
  volumeDown = "${wpctl} set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-";
  run = app: "${getExe uwsm} app -- ${app}";
  micInsteadOfSpeaker = if osConfig.networking.hostName == "hyprnix" then "@DEFAULT_AUDIO_SOURCE@" else "@DEFAULT_AUDIO_SINK@";
  screenshot = writeShellScript "screenshot" ''
    ${getExe grim} -g "$(${getExe slurp} -b 1B1F28CC -c E06B74ff -s C778DD0D -w 2)" - | \
    ${getExe satty} --filename - --fullscreen \
      --output-filename ~/Pictures/Screenshots/Screenshot_$(date +"%Y%m%d_%H%M%S").png \
      --init-tool brush --copy-command ${wlCopy}
  '';
in
{
  wayland.windowManager.hyprland.settings = {

    #      bind = ${modifier},P,pseudo,
    #      bind = ${modifier}SHIFT,SPACE,movetoworkspace,special
    #      bind = ${modifier},SPACE,togglespecialworkspace
    #      bind = ${modifier}CONTROL,right,workspace,e+1
    #      bind = ${modifier}CONTROL,left,workspace,e-1
    #      bind = ${modifier},mouse_down,workspace, e+1
    #      bind = ${modifier},mouse_up,workspace, e-1
    #      bind = ALT,Tab,bringactivetotop
    binds = {
      allow_workspace_cycles = true;
    };

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
        "SUPER, V, exec, ${run clipboardManager}"
        "SUPER, B, exec, ${run "$BROWSER"}"
        "SUPER_CTRL, RETURN, exec, ${launcher}"
        "SUPER, Print, exec, ${screenshot}"

        "ALT, Tab, focuscurrentorlast"
        "CTRL_ALT, Delete, exit"
        "SUPER, Q, killactive"
        "SUPER, T, togglefloating"
        "SUPER, F, fullscreen"
        "SUPER, S, togglesplit"

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
      ",XF86AudioPlay,  exec, ${getExe playerctl} play-pause"
      ",XF86AudioPrev,  exec, ${getExe playerctl} previous"
      ",XF86AudioNext,  exec, ${getExe playerctl} next"
      ",XF86AudioMute,    exec, ${wpctl} set-mute ${micInsteadOfSpeaker} toggle"
      ",XF86AudioMicMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ];

    bindm = [
      "SUPER, mouse:272, movewindow"
      "SUPER, mouse:273, resizewindow"
    ];
  };
}
