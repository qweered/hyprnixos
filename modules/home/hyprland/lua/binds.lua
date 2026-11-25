hl.config({
  binds = {
    allow_workspace_cycles = true,
  },
})

local function run(app)
  return "uwsm app -- " .. app
end

local function toggle(app)
  local command = app:match("^%S+")
  return "pkill " .. command .. " || uwsm app -- " .. app
end

local function exec(command)
  return hl.dsp.exec_cmd(command)
end

-- Relative to the main Hyprland config (~/.config/hypr/hyprland.lua)
local shader = "shaders/shadow-lift.frag"

local function toggleShader()
  local current = hl.get_config("decoration:screen_shader")
  if current ~= nil and current ~= "" then
    hl.config({ decoration = { screen_shader = "[[EMPTY]]" } })
    hl.exec_cmd('dms notify "shader: disabled"')
  else
    hl.config({ decoration = { screen_shader = shader } })
    hl.exec_cmd('dms notify "shader: enabled"')
  end
end

-- Most important
hl.bind("SUPER + SHIFT + Slash", exec("dms ipc call keybinds toggle hyprland"))
hl.bind("SUPER + SPACE", exec("dms ipc call spotlight toggle"))
hl.bind("ALT + space", exec("dms ipc call spotlight-bar toggle"))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle"}))
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind("SUPER + S", hl.dsp.layout("togglesplit"))
hl.bind("ALT + Tab", hl.dsp.focus({ last = true }))

-- Specific Apps
hl.bind("SUPER + B", exec(run("$BROWSER")))
hl.bind("SUPER + Return", exec(run(vars.terminal)))
hl.bind("SUPER + W", exec(toggle("activate-linux -d")))

-- Other
hl.bind("SUPER + Print", exec("dms screenshot")) -- TODO: then edit
hl.bind("SUPER + F12", toggleShader)
hl.bind("SUPER + TAB", exec("dms ipc call hypr toggleOverview"))
hl.bind("SUPER + V", exec("dms ipc call clipboard toggle"))
hl.bind("SUPER + M", exec("dms ipc call dash toggle media"))
hl.bind("SUPER + N", exec("dms ipc call notepad toggle"))
hl.bind("SUPER + X", exec("dms ipc call powermenu toggle"))
hl.bind("SUPER + SHIFT + C", exec("dms color pick -a"))
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("dms ipc call processlist focusOrToggle"))

-- brightness and audio
hl.bind("XF86MonBrightnessUp", exec("dms ipc call brightness increment 5"), {
  locked = true,
  repeating = true,
})
hl.bind("XF86MonBrightnessDown", exec("dms ipc call brightness decrement 5"), {
  locked = true,
  repeating = true,
})
hl.bind("XF86AudioRaiseVolume", exec("dms ipc call audio increment 5"), {
  locked = true,
  repeating = true,
})
hl.bind("XF86AudioLowerVolume", exec("dms ipc call audio decrement 5"), {
  locked = true,
  repeating = true,
})

hl.bind("XF86AudioPlay", exec("dms ipc call mpris playPause"), { locked = true })
hl.bind("XF86AudioPause", exec("dms ipc call mpris playPause"), { locked = true })
hl.bind("XF86AudioPrev", exec("dms ipc call mpris previous"), { locked = true })
hl.bind("XF86AudioNext", exec("dms ipc call mpris next"), { locked = true })
hl.bind("XF86AudioMute", exec("dms ipc call audio mute"), { locked = true })
hl.bind("XF86AudioMicMute", exec("dms ipc call audio micmute"), { locked = true })
-- FIXME: works only on FN + SHIFT + XF86AudioMute
hl.bind("SHIFT + XF86AudioMute", exec("dms ipc call audio micmute"), { locked = true })

-- Move windows and workspaces
for i = 1, 9 do
  hl.bind("SUPER + SHIFT + " .. tostring(i), hl.dsp.window.move({ workspace = i }))
end

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), {
  mouse = true,
  description = "Move window",
})
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), {
  mouse = true,
  description = "Resize window",
})

-- Move focus
for i = 1, 9 do
  hl.bind("SUPER + " .. tostring(i), hl.dsp.focus({ workspace = i }))
end

hl.bind("SUPER + K", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + H", hl.dsp.focus({ direction = "left" }))

-- Not checked

hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "d" }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "r" }))

hl.bind("SUPER + left", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ workspace = "e+1" }))

hl.bind("SUPER + CTRL + k", hl.dsp.window.resize({ x = 0, y = -20, relative = true }))
hl.bind("SUPER + CTRL + j", hl.dsp.window.resize({ x = 0, y = 20, relative = true }))
hl.bind("SUPER + CTRL + l", hl.dsp.window.resize({ x = 20, y = 0, relative = true }))
hl.bind("SUPER + CTRL + h", hl.dsp.window.resize({ x = -20, y = 0, relative = true }))

-- === Focus Navigation ===
-- hl.bind("SUPER + left", hl.dsp.focus({ direction = "l" }))
-- hl.bind("SUPER + down", hl.dsp.focus({ direction = "d" }))
-- hl.bind("SUPER + up", hl.dsp.focus({ direction = "u" }))
-- hl.bind("SUPER + right", hl.dsp.focus({ direction = "r" }))
-- hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }))
-- hl.bind("SUPER + J", hl.dsp.focus({ direction = "d" }))
-- hl.bind("SUPER + K", hl.dsp.focus({ direction = "u" }))
-- hl.bind("SUPER + L", hl.dsp.focus({ direction = "r" }))

-- === Workspace Navigation ===
-- hl.bind("SUPER + U", hl.dsp.focus({ workspace = "e+1" }))
-- hl.bind("SUPER + I", hl.dsp.focus({ workspace = "e-1" }))
-- hl.bind("SUPER + CTRL + down", hl.dsp.window.move({ workspace = "e+1" }))
-- hl.bind("SUPER + CTRL + up", hl.dsp.window.move({ workspace = "e-1" }))
-- hl.bind("SUPER + CTRL + U", hl.dsp.window.move({ workspace = "e+1" }))
-- hl.bind("SUPER + CTRL + I", hl.dsp.window.move({ workspace = "e-1" }))
-- hl.bind("SUPER + SHIFT + Page_Down", hl.dsp.window.move({ workspace = "e+1" }))
-- hl.bind("SUPER + SHIFT + Page_Up", hl.dsp.window.move({ workspace = "e-1" }))
-- hl.bind("SUPER + SHIFT + U", hl.dsp.window.move({ workspace = "e+1" }))
-- hl.bind("SUPER + SHIFT + I", hl.dsp.window.move({ workspace = "e-1" }))
-- === Mouse Wheel Navigation ===
-- hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
-- hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
-- hl.bind("SUPER + CTRL + mouse_down", hl.dsp.window.move({ workspace = "e+1" }))
-- hl.bind("SUPER + CTRL + mouse_up", hl.dsp.window.move({ workspace = "e-1" }))


-- TODO: multimonitor
-- hl.bind("SUPER + CTRL + left", hl.dsp.focus({ monitor = "l" }))
-- hl.bind("SUPER + CTRL + right", hl.dsp.focus({ monitor = "r" }))
-- hl.bind("SUPER + CTRL + H", hl.dsp.focus({ monitor = "l" }))
-- hl.bind("SUPER + CTRL + J", hl.dsp.focus({ monitor = "d" }))
-- hl.bind("SUPER + CTRL + K", hl.dsp.focus({ monitor = "u" }))
-- hl.bind("SUPER + CTRL + L", hl.dsp.focus({ monitor = "r" }))
-- === Move to Monitor ===
-- hl.bind("SUPER + SHIFT + CTRL + left", hl.dsp.window.move({ monitor = "l" }))
-- hl.bind("SUPER + SHIFT + CTRL + down", hl.dsp.window.move({ monitor = "d" }))
-- hl.bind("SUPER + SHIFT + CTRL + up", hl.dsp.window.move({ monitor = "u" }))
-- hl.bind("SUPER + SHIFT + CTRL + right", hl.dsp.window.move({ monitor = "r" }))
-- hl.bind("SUPER + SHIFT + CTRL + H", hl.dsp.window.move({ monitor = "l" }))
-- hl.bind("SUPER + SHIFT + CTRL + J", hl.dsp.window.move({ monitor = "d" }))
-- hl.bind("SUPER + SHIFT + CTRL + K", hl.dsp.window.move({ monitor = "u" }))
-- hl.bind("SUPER + SHIFT + CTRL + L", hl.dsp.window.move({ monitor = "r" }))
-- === Scratchpad ===
--hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special", follow = false }))
--hl.bind("SUPER + CTRL + S", hl.dsp.window.move({ workspace = "+0" }))
-- hl.bind("SUPER + M", hl.dsp.workspace.toggle_special("magic")) or S, Special
-- hl.bind("SUPER + P", hl.dsp.window.move({ workspace = "special:magic" }))
-- hl.bind("SUPER + W", hl.dsp.group.toggle())
-- hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("dms ipc call window-rules toggle"))
-- hl.bind("SUPER + ALT + N", hl.dsp.exec_cmd("dms ipc call night toggle"))
-- hl.bind("SUPER + ALT + I", hl.dsp.exec_cmd("dms ipc call inhibit toggle"))
-- === Workspace Management ===
--hl.bind("SUPER + ALT + R", hl.dsp.exec_cmd("dms ipc call workspace-rename open"))
-- === Column Management ===
--hl.bind("SUPER + bracketleft", hl.dsp.layout("preselect l"))
--hl.bind("SUPER + bracketright", hl.dsp.layout("preselect r"))
-- -- === Manual Sizing ===
-- hl.bind("SUPER + minus", hl.dsp.window.resize({ x = -100, y = 0, relative = true }), { repeating = true })
-- hl.bind("SUPER + equal", hl.dsp.window.resize({ x = 100, y = 0, relative = true }), { repeating = true })
-- hl.bind("SUPER + SHIFT + minus", hl.dsp.window.resize({ x = 0, y = -100, relative = true }), { repeating = true })
-- hl.bind("SUPER + SHIFT + equal", hl.dsp.window.resize({ x = 0, y = 100, relative = true }), { repeating = true })
-- -- === Security ===
-- hl.bind("SUPER + comma", hl.dsp.exec_cmd("dms ipc call settings focusOrToggle"))
-- TODO: recheck this:
--       bind = ${modifier}SHIFT,SPACE,movetoworkspace,special
--       bind = ${modifier}CONTROL,right,workspace,e+1
--       bind = ${modifier}CONTROL,left,workspace,e-1
--       bind = ${modifier},mouse_down,workspace, e+1
--       bind = ${modifier},mouse_up,workspace, e-1
-- "col.nogroup_border" = 1;
-- "col.nogroup_border_active" = 1;
-- snap =  {
--    enabled = true;
-- };
-- CONFIG: choose between dim and opacity for inactive windows
--        decoration.inactive_opacity = 0.7;
--        decoration.dim_inactive = true;
