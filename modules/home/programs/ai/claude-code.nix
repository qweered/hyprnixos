{ config, pkgs, ... }:
let
  claudeCfg = config.programs.claude-code.settings;
  attributionTrail = "Assisted-by: claude-code with ${claudeCfg.model}-${claudeCfg.effortLevel}";
in
{
  home.packages = [ pkgs.oh-my-claudecode ];
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    skills = {
      search-code = ./skills/search-code.md;
    };
    settings = {
      model = "claude-opus-5[1m]";
      effortLevel = "high";
      skipDangerousModePermissionPrompt = true;
      outputStyle = "Explanatory";
      permissions = {
        defaultMode = "auto";
      };
      env = {
        CLAUDE_CODE_NO_FLICKER = "1";
        CLAUDE_CODE_AUTO_COMPACT_WINDOW = "550000";
      };
      enabledPlugins = {
        "expo@expo-plugins" = true;
        "frontend-design@claude-plugins-official" = true;
        "feature-dev@claude-plugins-official" = true;
        "code-simplifier@claude-plugins-official" = true;
        "typescript-lsp@claude-plugins-official" = true;
        "commit-commands@claude-plugins-official" = true;
        "security-guidance@claude-plugins-official" = true;
      };
      attribution = {
        commit = attributionTrail;
        pr = attributionTrail;
      };
    };
  };
}
