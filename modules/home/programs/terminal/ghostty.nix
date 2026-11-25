{
  # over alacritty (slow development), wezterm,
  # foot (very lightweight), kitty (3 langs, but it may be better idk)

  programs.ghostty = {
    enable = true;
    settings = {
      theme = "dankcolors";
      window-decoration = false;
      gtk-titlebar = false;
      font-size = 12;
      cursor-style = "block";
      cursor-style-blink = true;
      mouse-hide-while-typing = true;

      copy-on-select = "none";
      confirm-close-surface = false;
      app-notifications = false;
      gtk-single-instance = true;

      keybind = "ctrl+t=new_tab";
    };
  };
}
