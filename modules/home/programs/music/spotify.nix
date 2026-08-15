{ inputs, osConfig, ... }:
let
  spicetifyPkgs = inputs.spicetify.legacyPackages.${osConfig.hardware.facter.report.system};
in
{
  imports = [ inputs.spicetify.homeManagerModules.default ];

  programs.spicetify = {
    enable = true;
    theme = spicetifyPkgs.themes.defaultDynamic;
    colorScheme = "Dark-Base";
    #    enabledCustomApps = with spicetifyPkgs.apps; [
    #      marketplace
    #    ];
    enabledExtensions = with spicetifyPkgs.extensions; [
      adblock
      shuffle # shuffle+ (special characters are sanitized out of extension names)
      groupSession
      fullAlbumDate
      wikify
      songStats
      betterGenres
      beautifulLyrics
      # lastfm - broken upstream
      # keyboardShortcut
      # popupLyrics
      # seekSong
      # skipStats
      # playlistIntersection
      # listPlaylistsWithSong
    ];
  };
}
