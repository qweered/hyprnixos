{ osConfig, user, ... }:
{
  programs.mcp = {
    enable = true;
    servers = {
      context7 = {
        command = "bunx";
        args = [
          "-y"
          "@upstash/context7-mcp"
        ];
        env.CONTEXT7_API_KEY.file = osConfig.sops.secrets."${user.name}/context7-api-key".path;
      };
      mantine = {
        command = "bunx";
        args = [
          "-y"
          "@mantine/mcp-server"
        ];
      };
      exa = {
        mode = "http";
        url = "https://mcp.exa.ai/mcp";
      };
    };
  };
}
