{
  programs.codex = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      model_reasoning_effort = "high";
      approvals_reviewer = "auto_review";
      features = {
        fast_mode = true;
        memories = true;
        mentions_v2 = true;
        goals = true;
      };
      tui.status_line = [
        "model-with-reasoning"
        "project-name"
        "git-branch"
        "context-used"
        "context-remaining"
        "total-input-tokens"
        "total-output-tokens"
      ];
    };
  };
}
