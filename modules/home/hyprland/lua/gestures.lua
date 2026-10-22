-- Keep gesture-related config with the gestures, so this module does not
-- depend on settings.lua having run first.
hl.config({
  gestures = {
    workspace_swipe_forever = false,
  },
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

hl.gesture({
  fingers = 3,
  direction = "up",
  action = "special",
  workspace_name = "magic",
})

hl.gesture({
  fingers = 4,
  direction = "left",
  action = function()
    hl.dispatch(hl.dsp.window.move({ workspace = -1 }))
  end,
})

hl.gesture({
  fingers = 4,
  direction = "right",
  action = function()
    hl.dispatch(hl.dsp.window.move({ workspace = "+1" }))
  end,
})

hl.gesture({
  fingers = 4,
  direction = "pinch",
  action = "fullscreen",
})

hl.workspace_rule({
  workspace = "special:magic",
  on_created_empty = "uwsm app -- " .. vars.terminal,
})
