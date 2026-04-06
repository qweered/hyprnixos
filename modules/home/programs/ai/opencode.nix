{
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      plugin = [
        "oh-my-opencode"
        "opencode-antigravity-auth"
      ];
      model = "openai/gpt-5.4";
      provider = {
        google = {
          models = {
            "antigravity-gemini-3.1-pro" = {
              name = "Gemini 3.1 Pro (Antigravity)";
              limit = {
                context = 1048576;
                output = 65535;
              };
              modalities = {
                input = [
                  "text"
                  "image"
                  "pdf"
                ];
                output = [ "text" ];
              };
              variants = {
                "low" = {
                  thinkingLevel = "low";
                };
                "high" = {
                  thinkingLevel = "high";
                };
              };
            };
            "antigravity-gemini-3-flash" = {
              name = "Gemini 3 Flash (Antigravity)";
              limit = {
                context = 1048576;
                output = 65536;
              };
              modalities = {
                input = [
                  "text"
                  "image"
                  "pdf"
                ];
                output = [ "text" ];
              };
              variants = {
                "minimal" = {
                  thinkingLevel = "minimal";
                };
                "low" = {
                  thinkingLevel = "low";
                };
                "medium" = {
                  thinkingLevel = "medium";
                };
                "high" = {
                  thinkingLevel = "high";
                };
              };
            };
          };
        };
      };
    };
  };
}
