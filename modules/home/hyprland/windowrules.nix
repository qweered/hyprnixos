let
  fc = regex: {
    match.class = "^.*${regex}.*$";
    float = true;
  };
  ft = regex: {
    match.title = "^.*${regex}.*$";
    float = true;
  };
  fct = class: title: {
    match = {
      class = "^.*${class}.*$";
      title = "^.*${title}.*$";
    };
    float = true;
  };
  dim = regex: {
    match.class = "^.*${regex}.*$";
    dim_around = true;
  };
in
{
  wayland.windowManager.hyprland.settings.window_rule = [
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
    {
      match.title = "^(Picture-in-Picture)$";
      float = true;
      pin = true;
    }

    (dim "xdg-desktop-portal")

    # throw sharing indicators away
    {
      match.title = "^((Firefox|Zen) — Sharing Indicator)$";
      workspace = "special silent";
    }
    {
      match.title = "^(.*is sharing (your screen|a window).)$";
      workspace = "special silent";
    }

    # start Spotify and YouTube Music in ws9
    # {
    #   match.title = "^(Spotify( Premium)?)$";
    #   workspace = "9 silent";
    # }
    # {
    #   match.title = "^(YouTube Music)$";
    #   workspace = "9 silent";
    # }

    # ignore maximizing requests from apps
    {
      match.class = ".*";
      suppress_event = "maximize";
    }
  ];
}
