{ osConfig, ... }:
{
  # context7 needs its API key in the environment; the secret is provided
  # unconditionally by modules/system/security/sops.nix
  programs.fish.interactiveShellInit = ''
    set -gx CONTEXT7_API_KEY (cat ${osConfig.sops.secrets.context7-api-key.path} 2>/dev/null)
  '';

  programs.mcp = {
    enable = true;
    servers = {
      context7 = {
        command = "bunx";
        args = [
          "-y"
          "@upstash/context7-mcp"
        ];
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
