{
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    skills = {
      search-code = ./skills/search-code.md;
    };
    settings = {
      skipDangerousModePermissionPrompt = true;
      outputStyle = "Explanatory";
      enabledPlugins = {
        "frontend-design@claude-plugins-official" = true;
        "github@claude-plugins-official" = true;
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
