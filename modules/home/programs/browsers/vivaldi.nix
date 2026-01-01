{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (vivaldi.override {
      enableWidevine = true;
      proprietaryCodecs = true;
      inherit widevine-cdm vivaldi-ffmpeg-codecs;
    })
  ];
}
