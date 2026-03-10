{
  # Modern cat replacement
  programs.bat = {
    enable = true;
    config = {
      style = "numbers,changes";
    };
  };

  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
  };
}
