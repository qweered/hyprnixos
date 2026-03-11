{
  programs.mcp = {
    enable = true;
    servers.context7 = {
      command = "npx";
      args = [
        "-y"
        "@upstash/context7-mcp"
      ];
    };
  };
}
