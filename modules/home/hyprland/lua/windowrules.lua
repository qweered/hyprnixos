local function fc(regex)
  return {
    match = { class = "^.*" .. regex .. ".*$" },
    float = true,
  }
end

local function ft(regex)
  return {
    match = { title = "^.*" .. regex .. ".*$" },
    float = true,
  }
end

local function fct(class, title)
  return {
    match = {
      class = "^.*" .. class .. ".*$",
      title = "^.*" .. title .. ".*$",
    },
    float = true,
  }
end

local function dim(regex)
  return {
    match = { class = "^.*" .. regex .. ".*$" },
    dim_around = true,
  }
end

hl.window_rule(fc("xdg-desktop-portal"))
hl.window_rule(fc("pwvucontrol"))
hl.window_rule(fc("easyeffects"))
hl.window_rule(fc("Overskride"))
hl.window_rule(ft("Picture-in-Picture"))
hl.window_rule(ft("Bitwarden - Vivaldi"))
hl.window_rule(ft("Bitwarden Password Manager"))

hl.window_rule(fct("ayugram", "Media viewer"))
hl.window_rule(fct("thunar", "File Operation Progress"))

-- make Firefox/Zen PiP window float and sticky
hl.window_rule({
  match = { title = "^(Picture-in-Picture)$" },
  float = true,
  pin = true,
})

hl.window_rule(dim("xdg-desktop-portal"))

-- throw sharing indicators away
hl.window_rule({
  match = { title = "^((Firefox|Zen) — Sharing Indicator)$" },
  workspace = "special silent",
})
hl.window_rule({
  match = { title = "^(.*is sharing (your screen|a window).)$" },
  workspace = "special silent",
})

-- hl.window_rule({ match = { class = "^(org\\.wezfurlong\\.wezterm)$" }, tile = true })
-- hl.window_rule({ match = { class = "^(org\\.gnome\\.)" }, rounding = 12 })
-- hl.window_rule({ match = { class = "^(gnome-control-center)$" }, tile = true })
-- hl.window_rule({ match = { class = "^(pavucontrol)$" }, tile = true })
-- hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, tile = true })
-- hl.window_rule({ match = { class = "^(org\\.gnome\\.Calculator)$" }, float = true })
-- hl.window_rule({ match = { class = "^(gnome-calculator)$" }, float = true })
-- hl.window_rule({ match = { class = "^(galculator)$" }, float = true })
-- hl.window_rule({ match = { class = "^(blueman-manager)$" }, float = true })
-- hl.window_rule({ match = { class = "^(xdg-desktop-portal)$" }, float = true })
-- hl.window_rule({
--   match = { class = "^(steam)$", title = "^(notificationtoasts)" },
--   no_initial_focus = true,
--   pin = true,
-- })
-- hl.window_rule({
--   match = { class = "^(firefox)$", title = "^(Picture-in-Picture)$" },
--   float = true,
-- })
-- hl.window_rule({ match = { class = "^(zoom)$" }, float = true })
-- hl.layer_rule({ match = { namespace = "^(quickshell)$" }, no_anim = true })
-- hl.layer_rule({ match = { namespace = "^dms:.*" }, no_anim = true })

-- start Spotify and YouTube Music in ws9
-- {
--   match.title = "^(Spotify( Premium)?)$";
--   workspace = "9 silent";
-- }
-- {
--   match.title = "^(YouTube Music)$";
--   workspace = "9 silent";
-- }

-- ignore maximizing requests from apps
hl.window_rule({
  match = { class = ".*" },
  suppress_event = "maximize",
})
