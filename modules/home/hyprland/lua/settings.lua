hl.config({
  dwindle = {
    preserve_split = true,
    smart_split = false, -- split based on mouse position
    precise_mouse_move = true,
  },

  ecosystem = {
    no_donation_nag = true,
    no_update_news = true,
  },

  general = {
    layout = "dwindle",
    allow_tearing = true,
    resize_on_border = true,
  },

  input = {
    -- TODO: recheck, empty should inherit XKB_DEFAULT_LAYOUT (libxkbcommon)
    kb_layout = vars.keyboard_layouts,
    kb_options = vars.kb_options,
    repeat_rate = 30,
    repeat_delay = 300,
    follow_mouse = 1,
    float_switch_override_focus = 2,
    focus_on_close = 1,
    touchpad = {
      natural_scroll = true,
      disable_while_typing = false,
    },
  },

  misc = {
    vrr = 1,
    focus_on_activate = false, -- too noisy and causes issues with windows apps
    key_press_enables_dpms = true,
    render_unfocused_fps = 5,
    disable_hyprland_logo = true, -- no default wallpaper
    disable_splash_rendering = true, -- no funny text from vaxry
  },

  render = {
    -- 0 off, 1 always, 2 only when a fullscreen video surface is on top.
    -- 2 keeps the screen_shader applied to most fullscreen apps but
    -- bypasses for actual video, matching mpv/browser hardware planes.
    direct_scanout = 2,
    new_render_scheduling = true, -- triple buffering
  },
})
