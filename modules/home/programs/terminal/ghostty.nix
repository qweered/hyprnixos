{
  # over alacritty (slow development), wezterm,
  # foot (very lightweight), kitty (3 langs, but it may be better idk)

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

  xdg.configFile."kdeglobals".text = ''
    [General]
    TerminalApplication=ghostty
  '';

}
