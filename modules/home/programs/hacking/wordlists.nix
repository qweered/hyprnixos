{ pkgs, ... }:
{
  # Wordlists for password cracking
  home.packages = with pkgs; [
    (wordlists.override {
      lists = [
        rockyou
        nmap
        # Adds 1.8 GB of bloat
        seclists
      ];
    })
  ];
}
