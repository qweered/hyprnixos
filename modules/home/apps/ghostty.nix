{
  # over alacritty (slow development), ghostty (1 sec startup, recheck after 1.2.0)
  # foot (very lightweight), kitty (3 langs, but it may be better idk)
  # TODO: fix comment

  programs.ghostty = {
    enable = true;
    settings = {
      theme = "Wez";
      cursor-style = "block";
      cursor-style-blink = true;
      confirm-close-surface = false;
      gtk-titlebar-hide-when-maximized = true;
    };
  };
}
