{ pkgs, ... }:
let
  name = "Bibata-Modern-Ice";
  srcDir = "${pkgs.bibata-cursors}/share/icons/${name}";
  bibata-hyprcursor =
    pkgs.runCommand "bibata-modern-ice-hyprcursor"
      {
        nativeBuildInputs = [
          pkgs.hyprcursor
          pkgs.xcur2png
        ];
      }
      ''
        ${pkgs.writers.writeNu "build-bibata-hyprcursor" { } /* nu */ ''
          let icon_dir = $"($env.out)/share/icons/${name}"
          let ext = $"extracted/extracted_${name}"
          mkdir extracted created $icon_dir

          hyprcursor-util -x "${srcDir}" -o extracted
          open --raw $"($ext)/manifest.hl" | str replace "Extracted Theme" "${name}" | save -f $"($ext)/manifest.hl"
          hyprcursor-util -c $ext -o created

          cp -r ($"${srcDir}/*" | into glob) $icon_dir
          cp -r ($"created/theme_${name}/*" | into glob) $icon_dir
        ''}
      '';
in
{
  home.pointerCursor = {
    enable = true;
    package = bibata-hyprcursor;
    inherit name;
    size = 20;
    gtk.enable = true;
    x11.enable = true;
    hyprcursor.enable = true;
  };
}
