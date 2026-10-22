-- Curves, animations, and animation-related options all live here.
hl.curve("wind", {
  type = "bezier",
  points = {
    { 0.05, 0.9 },
    { 0.1, 1.05 },
  },
})

hl.curve("winIn", {
  type = "bezier",
  points = {
    { 0.1, 1.1 },
    { 0.1, 1.1 },
  },
})

hl.curve("winOut", {
  type = "bezier",
  points = {
    { 0.3, -0.3 },
    { 0, 1 },
  },
})

hl.curve("liner", {
  type = "bezier",
  points = {
    { 1, 1 },
    { 1, 1 },
  },
})

hl.curve("overshot", {
  type = "bezier",
  points = {
    { 0.05, 0.9 },
    { 0.1, 1.05 },
  },
})

hl.curve("smoothOut", {
  type = "bezier",
  points = {
    { 0.5, 0 },
    { 0.99, 0.99 },
  },
})

hl.curve("smoothIn", {
  type = "bezier",
  points = {
    { 0.5, -0.5 },
    { 0.68, 1.5 },
  },
})

hl.animation({
  leaf = "windows",
  speed = 6,
  bezier = "wind",
  enabled = true,
  style = "slide",
})

hl.animation({
  leaf = "windowsIn",
  speed = 5,
  bezier = "winIn",
  enabled = true,
  style = "slide",
})

hl.animation({
  leaf = "windowsOut",
  speed = 3,
  bezier = "smoothOut",
  enabled = true,
  style = "slide",
})

hl.animation({
  leaf = "windowsMove",
  speed = 5,
  bezier = "wind",
  enabled = true,
  style = "slide",
})

hl.animation({
  leaf = "border",
  speed = 1,
  bezier = "liner",
  enabled = true,
})

hl.animation({
  leaf = "borderangle",
  speed = 100,
  bezier = "liner",
  enabled = true,
  style = "loop",
})

hl.animation({
  leaf = "fade",
  speed = 3,
  bezier = "smoothOut",
  enabled = true,
})

hl.animation({
  leaf = "workspaces",
  speed = 5,
  bezier = "overshot",
  enabled = true,
})

hl.animation({
  leaf = "workspacesIn",
  speed = 5,
  bezier = "winIn",
  enabled = true,
  style = "slide",
})

hl.animation({
  leaf = "workspacesOut",
  speed = 5,
  bezier = "winOut",
  enabled = true,
  style = "slide",
})

hl.animation({
  leaf = "specialWorkspace",
  speed = 5,
  bezier = "overshot",
  enabled = true,
  style = "slidevert bottom",
})

-- Visual/rice configuration. Keep it together with the animation definitions.
hl.config({
  animations = {
    enabled = true,
  },

  decoration = {
    rounding = 12,
    rounding_power = 4,
    active_opacity = 0.95,
    inactive_opacity = 0.9,

    -- TODO: glow, motion_blur

    blur = {
      enabled = true,
      size = 8,
      passes = 2,
      noise = 0.01,
      contrast = 0.9,
      brightness = 0.8,
      popups = true,
    },

    shadow = {
      enabled = true,
      range = 30,
      render_power = 4,
      offset = "0 5",
      color = "rgba(00000070)",
    },
  },

  general = {
    border_size = 3,
    gaps_in = 5,
    gaps_out = 5,
    gaps_workspaces = 5,

    -- CONFIG: color based on wallpaper
    -- LGBT lightning
    col = {
      inactive_border = {
        colors = {
          "rgba(90,90,110,0.3)",
          "rgba(100,100,120,0.3)",
          "rgba(110,110,130,0.3)",
          "rgba(120,120,140,0.3)",
          "rgba(130,130,150,0.3)",
          "rgba(140,140,160,0.3)",
          "rgba(150,150,170,0.3)",
        },
        angle = 45,
      },
      active_border = {
        colors = {
          "rgba(179,0,0,0.8)",
          "rgba(179,89,0,0.8)",
          "rgba(179,179,0,0.8)",
          "rgba(0,179,0,0.8)",
          "rgba(0,0,179,0.8)",
          "rgba(53,0,92,0.8)",
          "rgba(101,0,179,0.8)",
        },
        angle = 45,
      },
    },
  },

  misc = {
    animate_manual_resizes = true,
    animate_mouse_windowdragging = true,
  },
})
