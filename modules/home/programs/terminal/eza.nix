{
  # Modern ls replacement
  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
    extraOptions = [
      "--no-quotes"
      "--hyperlink"
      "--group-directories-first"
    ];
  };
}
