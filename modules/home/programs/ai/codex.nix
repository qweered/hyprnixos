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
        goals = true;
      };
    };
  };
}
