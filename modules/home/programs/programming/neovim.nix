_:

{
  # imports = [ inputs.nvf.homeManagerModules.default ];

  # Neovim gui wrapper
  # programs.neovide = {
  #   enable = true;
  #   settings = {
  #     # TODO: Is this true for all home-manager configurations?
  #     neovim-bin = "/etc/profiles/per-user/${vars.username}/bin/nvim";
  #     font = {
  #       normal = [ ];
  #       size = 14.0;
  #     };
  #   };
  # };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # CONFIG: https://notashelf.github.io/nvf/options
  # Neovim config framework
  # programs.nvf = {
  #   enable = false;
  #   settings = {
  #     vim = {
  #       enableLuaLoader = true;
  #       debugMode.enable = false;
  #       # extraPackages = with pkgs; [ fzf ripgrep ];
  #       assistant = {
  #         # avante-nvim.enable = true;
  #         copilot.enable = true;
  #         copilot.cmp.enable = true;
  #       };
  #       # autogroups = {};
  #       # autocomds = {};
  #       autocomplete = {
  #         enableSharedCmpSources = true; # with nvim-cmp
  #         blink-cmp = {
  #           enable = true;
  #           friendly-snippets.enable = true;
  #           # sourcePlugins = [];
  #         };
  #       };
  #       autopairs.nvim-autopairs.enable = true;
  #       binds = {
  #         cheatsheet.enable = true;
  #         hardtime-nvim.enable = true;
  #         whichKey.enable = true;
  #       };
  #       clipboard = {
  #         enable = true;
  #         providers.wl-copy.enable = true;
  #         registers = "unnamed,unnamedplus";
  #       };
  #       comments = {
  #         comment-nvim.enable = true;
  #       };
  #       # dashboard = {};
  #       # debugger = {};
  #       diagnostics = {
  #         # TODO
  #         enable = true;
  #         nvim-lint.enable = true;
  #       };
  #       filetree = {
  #         neo-tree.enable = true; # or nvim-tree
  #       };
  #       formatter.conform-nvim.enable = true;
  #       # fzf-lua.enable = true;
  #       # gestures = {};
  #       git = {
  #         enable = true;
  #         # git-conflict.enable = true;
  #       };
  #       lsp = {
  #         enable = true;
  #       };
  #     };
  #   };
  # };
}
