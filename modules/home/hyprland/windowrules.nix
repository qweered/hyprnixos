let
  fc = regex: "float on, match:class ^.*${regex}.*$";
  ft = regex: "float on, match:title ^.*${regex}.*$";
  fct = class: title: "float on, match:class ^.*${class}.*$, match:title ^.*${title}.*$";
  dim = regex: "dim_around on, match:class ^.*${regex}.*$";
in
{
  wayland.windowManager.hyprland.settings.windowrule = [
    (fc "xdg-desktop-portal")
    (fc "pwvucontrol")
    (fc "easyeffects")
    (fc "Overskride")
    (ft "Picture-in-Picture")
    (ft "Bitwarden - Vivaldi")
    (ft "Bitwarden Password Manager")
    (ft "PortProton")

    (fct "ayugram" "Media viewer")
    (fct "thunar" "File Operation Progress")

    # make Firefox/Zen PiP window float and sticky
    "match:title ^(Picture-in-Picture)$, float on, pin on"

    (dim "xdg-desktop-portal")

    # throw sharing indicators away
    "match:title ^((Firefox|Zen) — Sharing Indicator)$, workspace special silent"
    "match:title ^(.*is sharing (your screen|a window).)$, workspace special silent"

    # start Spotify and YouTube Music in ws9
    # "match:title ^(Spotify( Premium)?)$, workspace 9 silent"
    # "match:title ^(YouTube Music)$, workspace 9 silent"

    "suppress_event maximize, match:class .*" # ignore maximizing requests from apps
  ];
}
