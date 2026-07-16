let
  mkBezier = name: points: {
    _args = [
      name
      {
        type = "bezier";
        inherit points;
      }
    ];
  };
  mkAnimation =
    leaf: speed: bezier: extra:
    {
      inherit
        leaf
        speed
        bezier
        ;
      enabled = true;
    }
    // extra;
in
{
  wayland.windowManager.hyprland.settings = {
    config = {
      general = {
        border_size = 5;
        gaps_in = 10;
        gaps_out = 10;
        gaps_workspaces = 5;

        # CONFIG: color based on wallpaper
        # LGBT lightning
        col = {
          inactive_border = {
            colors = [
              "rgba(90,90,110,0.3)"
              "rgba(100,100,120,0.3)"
              "rgba(110,110,130,0.3)"
              "rgba(120,120,140,0.3)"
              "rgba(130,130,150,0.3)"
              "rgba(140,140,160,0.3)"
              "rgba(150,150,170,0.3)"
            ];
            angle = 45;
          };
          active_border = {
            colors = [
              "rgba(179,0,0,0.8)"
              "rgba(179,89,0,0.8)"
              "rgba(179,179,0,0.8)"
              "rgba(0,179,0,0.8)"
              "rgba(0,0,179,0.8)"
              "rgba(53,0,92,0.8)"
              "rgba(101,0,179,0.8)"
            ];
            angle = 45;
          };
        };
      };

      decoration = {
        rounding = 7;
        rounding_power = 4;
        active_opacity = 1;

        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          noise = 0.01;
          contrast = 0.9;
          brightness = 0.8;
          popups = true;
        };
      };

      animations.enabled = true;
    };

    curve = [
      (mkBezier "wind" [
        [
          0.05
          0.9
        ]
        [
          0.1
          1.05
        ]
      ])
      (mkBezier "winIn" [
        [
          0.1
          1.1
        ]
        [
          0.1
          1.1
        ]
      ])
      (mkBezier "winOut" [
        [
          0.3
          (-0.3)
        ]
        [
          0
          1
        ]
      ])
      (mkBezier "liner" [
        [
          1
          1
        ]
        [
          1
          1
        ]
      ])
      (mkBezier "overshot" [
        [
          0.05
          0.9
        ]
        [
          0.1
          1.05
        ]
      ])
      (mkBezier "smoothOut" [
        [
          0.5
          0
        ]
        [
          0.99
          0.99
        ]
      ])
      (mkBezier "smoothIn" [
        [
          0.5
          (-0.5)
        ]
        [
          0.68
          1.5
        ]
      ])
    ];

    animation = [
      (mkAnimation "windows" 6 "wind" { style = "slide"; })
      (mkAnimation "windowsIn" 5 "winIn" { style = "slide"; })
      (mkAnimation "windowsOut" 3 "smoothOut" { style = "slide"; })
      (mkAnimation "windowsMove" 5 "wind" { style = "slide"; })
      (mkAnimation "border" 1 "liner" { })
      (mkAnimation "borderangle" 100 "liner" { style = "loop"; })
      (mkAnimation "fade" 3 "smoothOut" { })
      (mkAnimation "workspaces" 5 "overshot" { })
      (mkAnimation "workspacesIn" 5 "winIn" { style = "slide"; })
      (mkAnimation "workspacesOut" 5 "winOut" { style = "slide"; })
      (mkAnimation "specialWorkspace" 5 "overshot" { style = "slidevert bottom"; })
    ];
  };
}
