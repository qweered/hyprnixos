{
  pkgs,
  vars,
  osConfig,
  ...
}:
let
  inherit (vars) flakeDirectory;
in
{
  home.packages = with pkgs; [
    grc
    fishPlugins.grc
  ];
  # CONFIG: https://www.reddit.com/r/NixOS/comments/1d174ds/how_can_i_get_colorful_man_pages/

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
      set -gx CONTEXT7_API_KEY (cat ${osConfig.age.secrets.context7-api-key.path} 2>/dev/null)
      fastfetch
    '';
    shellAliases =
      let
        common-nix-args = "--keep-going --keep-failed --fallback --show-trace";
        nhCmd = "nh os switch --ask --diff=always ${common-nix-args}";
      in
      {
        nh-switch = "${nhCmd}";
        nh-update = "${nhCmd} --update";
        nh-clean = "nh clean all --optimise --keep 3";
        nom-build = "nom-build ${common-nix-args}";

        svi = "sudo nvim";
        ls = "eza --icons";
        ll = "eza -l --icons";
        la = "eza -la --icons";

        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";

        claude = "claude --dangerously-skip-permissions";
        ff = "fastfetch";
        df = "duf";
        du = "gdu";
        top = "btop";
        htop = "btop";
        rm = "rip";
        nix-env = "echo 'Do not use nix-env ever, use nix shell or nix run instead'";
        nix-olde = "nix-olde -f ${flakeDirectory} > ${flakeDirectory}/OUTDATED.md"; # TODO: add verbosity for not existing in repology packages
        # "ps aux" = "procs"; TODO: add this
      };
  };
}
