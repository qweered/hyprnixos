{
  user,
  pkgs,
  ...
}:
let
  inherit (user) flakeDirectory;
in
{
  home.packages = with pkgs; [
    fishPlugins.fish-you-should-use
    fishPlugins.fishbang
    fishPlugins.autopair
  ];

  home.sessionVariables.RIP_GRAVEYARD = "/tmp/graveyard"; # TODO: unneeded with imprermamence

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
    '';
    functions.which-real = ''
      readlink -f (command -v -- $argv)
    '';
    shellAliases =
      let
        nhCmd = "nh os switch --ask --show-activation-logs --show-trace";
      in
      {
        nh-switch = "${nhCmd}";
        nh-update = "${nhCmd} --update";
        nh-clean = "nh clean all --optimise --keep 3 --keep-one --no-direnv --cross-filesystems";

        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";

        ff = "fastfetch";
        cat = "bat --style=plain --paging=never";
        cp = "cp -iv"; # ask and show progress
        mv = "mv -iv";
        df = "duf";
        du = "gdu";
        top = "btop";
        htop = "btop";
        tree = "eza --tree";
        rm = "rip";
        terraform = "tofu";
        svi = "sudo nvim";
        codex = "codex --dangerously-bypass-hook-trust";
        nix-env = "echo 'Do not use nix-env ever, use nix shell or nix run instead'";
        nix-olde = "nix-olde -f ${flakeDirectory} > ${flakeDirectory}/OUTDATED.md"; # TODO: add verbosity for not existing in repology packages
        # "ps aux" = "procs"; TODO: add this
      };
  };
}
