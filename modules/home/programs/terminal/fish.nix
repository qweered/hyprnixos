{ pkgs, ... }:

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

        ff = "fastfetch";
        df = "duf";
        du = "gdu";
        top = "btop";
        htop = "btop";
        rm = "rip";
        nix-env = "echo 'Do not use nix-env ever, use nix shell or nix run instead'";
        # "ps aux" = "procs"; TODO: add this
      };
  };
}
