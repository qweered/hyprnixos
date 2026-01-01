{
  # CONFIG: https://tealdeer-rs.github.io/tealdeer/config_style.html
  programs.tealdeer = {
    enable = true;
    settings = {
      display = {
        compact = false;
        use_pager = false;
      };
      updates = {
        auto_update = true;
      };
    };
  };
}
