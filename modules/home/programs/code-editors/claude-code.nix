{
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      outputStyle = "Explanatory";
      enabledPlugins = {
        "coderabbit@claude-plugins-official" = true;
        "frontend-design@claude-plugins-official" = true;
        # "github@claude-plugins-official" = true;
        "feature-dev@claude-plugins-official" = true;
        "code-simplifier@claude-plugins-official" = true;
        "typescript-lsp@claude-plugins-official" = true;
        "commit-commands@claude-plugins-official" = true;
        "security-guidance@claude-plugins-official" = true;
      };
      attribution = {
        commit = "";
        pr = "";
      };
    };
  };
}
