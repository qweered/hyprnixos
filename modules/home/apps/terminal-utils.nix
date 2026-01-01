{ pkgs, ... }:

{
  # CONFIG: look and configure them all if needed
  home.packages = with pkgs; [
    btop # process viewer, over htop, mission-center
    gdu # du alternative, over dua dust dutree pdu godu ncdu duc diskus
    eza # ls alternative, over exa, lsd
    bat # cat alternative
    lazyjournal # over dmesg, journalctl
    duf # df alternative, over dysk (2 best) pydf di dfc dfrs
    rip2 # rm, trash-cli alternative
    procs # process viewer, over ps aux
    ripgrep # grep/ack alternative
    fzf # fuzzy finder
    fd # find alternative
    hyperfine # speed benchmarks
    ffmpeg # video/audio converter
    tree # directory tree
    yt-dlp # download videos

    libnotify # notifications in shell
    hyprpicker # color picker
    wget # download files, over curl

    jq
  ];
}
