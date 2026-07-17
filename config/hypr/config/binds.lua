local terminal = "kitty"
local browser = "firefox"
local launcher = "fuzzel"
local fileManager = "thunar"
local restart_waybar = "killall waybar && waybar & "
local scripts = "$HOME/.config/scripts"

hl.bind("SUPER + B", hl.dsp.exec_cmd(browser))
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager))
--hl.bind("SUPER + H", hl.dsp.exec_cmd(restart_waybar))
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(launcher))

hl.bind("SUPER + A", hl.dsp.exec_cmd("code"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + P", hl.dsp.exec_cmd("vesktop"))
hl.bind("SUPER + S", hl.dsp.exec_cmd("kitty -e termusic"))
hl.bind("SUPER + T", hl.dsp.exec_cmd("Telegram"))
hl.bind("SUPER + U", hl.dsp.exec_cmd("res=$(fuzzel --dmenu --prompt='Emoji: ' < $HOME/.config/hypr/emoji-list.txt | awk '{print $1}') && [ -n \"$res\" ] && echo -n \"$res\" | wl-copy"))
hl.bind("SUPER + V", hl.dsp.exec_cmd("cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))
hl.bind("SUPER + W", hl.dsp.exec_cmd("kitty --class btop -e btop"))
hl.bind("SUPER + X", hl.dsp.exec_cmd("kitty -e scrcpy"))
hl.bind("SUPER + Y", hl.dsp.exec_cmd("kitty --class yazi -e yazi"))
hl.bind("SUPER + SHIFT + V", hl.dsp.exec_cmd("cliphist wipe"))
hl.bind("SUPER + O", hl.dsp.exec_cmd("wineserver -k"))

hl.bind("SUPER + C", hl.dsp.exec_cmd(scripts .. "/hyprpicker.sh -hex"))
hl.bind("SUPER + G", hl.dsp.exec_cmd(scripts .. "/sequencia.sh"))
hl.bind("SUPER + I", hl.dsp.exec_cmd(scripts .. "/converter_imagens.sh"))
hl.bind("SUPER + J", hl.dsp.exec_cmd(scripts .. "/extract_frames.sh"))
hl.bind("SUPER + K", hl.dsp.exec_cmd(scripts .. "/wlsunset.sh"))
hl.bind("SUPER + M", hl.dsp.exec_cmd(scripts .. "/powermenu.sh"))
hl.bind("SUPER + N", hl.dsp.exec_cmd(scripts .. "/qr.sh"))
--hl.bind("SUPER + O", hl.dsp.exec_cmd(scripts .. "/enable_services.sh"))
hl.bind("SUPER + R", hl.dsp.exec_cmd(scripts .. "/screenrecord.sh"))
hl.bind("SUPER + Z", hl.dsp.exec_cmd(scripts .. "/colors/telegram-colors.sh"))
hl.bind("SUPER + H", hl.dsp.exec_cmd(scripts .. "/random-wallpaper.sh"))

hl.bind("SUPER + SHIFT + J", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + Q", hl.dsp.window.close())
--hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Focus windows
hl.bind("SUPER + left", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "d" }))

-- Swap windows
hl.bind("SUPER + SHIFT + left",  hl.dsp.window.swap({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind("SUPER + SHIFT + up",    hl.dsp.window.swap({ direction = "up" }))
hl.bind("SUPER + SHIFT + down",  hl.dsp.window.swap({ direction = "down" }))

-- Resize windows with keyboard
hl.bind("SUPER + CTRL + left", hl.dsp.window.resize({x=-15, y=0, relative=true}), {repeating=true})
hl.bind("SUPER + CTRL + right", hl.dsp.window.resize({x=15, y=0, relative=true}), {repeating=true})
hl.bind("SUPER + CTRL + up", hl.dsp.window.resize({x=0, y=-15, relative=true}), {repeating=true})
hl.bind("SUPER + CTRL + down", hl.dsp.window.resize({x=0, y=15, relative=true}), {repeating=true})

-- Switch and move active window to workspaces
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind("SUPER + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind("SUPER + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e+1" }), { description = "Cycle through workspaces" })
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e-1" }), { description = "Cycle through workspaces" })

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { description = "Move window with mouse" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { description = "Resize window with mouse" })

hl.bind("F11", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), { description = "Toggle Fullscreen" })
hl.bind("F12", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle Floating" })

-- screenshot --
hl.bind("PRINT", hl.dsp.exec_cmd(scripts .. "/screenshot.sh all"))
hl.bind("SUPER + PRINT", hl.dsp.exec_cmd(scripts .. "/screenshot.sh monitor"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd(scripts .. "/screenshot.sh region"))
hl.bind("ALT + PRINT", hl.dsp.exec_cmd(scripts .. "/screenshot.sh window"))

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(scripts .. "/volume-up.sh"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(scripts .. "/volume-down.sh"))
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(scripts .. "/mute.sh"))
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(scripts .. "/mute-mic.sh"))
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd(scripts .. "/brilho.sh --up"))
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd(scripts .. "/brilho.sh --down"))

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"))

hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd("/usr/bin/quickshell ipc --any-display -p /usr/share/tide-island call overview toggle"))
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd("/usr/bin/quickshell ipc --any-display -p /usr/share/tide-island call tide showCustom"))
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("/usr/bin/quickshell ipc --any-display -p /usr/share/tide-island call tide showClock"))
hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd("/usr/bin/quickshell ipc --any-display -p /usr/share/tide-island call tide togglePlayer"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("/usr/bin/quickshell ipc --any-display -p /usr/share/tide-island call tide toggleControlCenter"))
--hl.bind("SUPER + SHIFT + F", hl.dsp.exec_cmd("/usr/bin/quickshell ipc --any-display -p /usr/share/tide-island call tide toggleWallpaperPicker"))
--hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd("/usr/bin/quickshell ipc --any-display -p /usr/share/tide-island call island toggle"))
--hl.bind("SUPER + SHIFT + H", hl.dsp.exec_cmd("/usr/bin/quickshell ipc --any-display -p /usr/share/tide-island call tide swipeRight"))
