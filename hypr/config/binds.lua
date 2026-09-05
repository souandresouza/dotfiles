local terminal = "kitty"
local browser = "firefox"
local launcher = "fuzzel"
local fileManager = "thunar"
local restart_waybar = "killall waybar && waybar & "
local scripts = "$HOME/.config/scripts"

hl.bind("SUPER + B", hl.dsp.exec_cmd(browser),{ description = "browser" })
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager),{ description = "file manager" })
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd(terminal),{ description = "terminal" })
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(launcher),{ description = "app launcher" })

hl.bind("SUPER + D", hl.dsp.exec_cmd("hyprctl reload"),{ description = "reload hyprland" })
hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock"),{ description = "lock screen" })
hl.bind("SUPER + T", hl.dsp.exec_cmd("Telegram"),{ description = "telegram" })
hl.bind("SUPER + U", hl.dsp.exec_cmd("res=$(fuzzel --dmenu --prompt='Emoji: ' < $HOME/.config/hypr/emoji-list.txt | awk '{print $1}') && [ -n \"$res\" ] && echo -n \"$res\" | wl-copy"),{ description = "emoji selector" })
hl.bind("SUPER + W", hl.dsp.exec_cmd("kitty --class btop -e btop"),{ description = "btop" })
hl.bind("SUPER + X", hl.dsp.exec_cmd("kitty -e scrcpy"),{ description = "scrcpy" })
hl.bind("SUPER + Y", hl.dsp.exec_cmd("kitty --class elio -e elio"),{ description = "elio" })
hl.bind("SUPER + P", hl.dsp.exec_cmd("kitty -e nmtui"),{ description = "nmtui" })
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd("kitty -e bluetui"),{ description = "bluetui" })
hl.bind("SUPER + O", hl.dsp.exec_cmd("wineserver -k"),{ description = "close wine" })

hl.bind("SUPER + C", hl.dsp.exec_cmd(scripts .. "/hyprpicker.sh -hex"),{ description = "hyprpicker" })
hl.bind("SUPER + G", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/run-scripts.sh"))
hl.bind("SUPER + A", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/hyprkeys.sh"),{ description = "show binds" })
hl.bind("SUPER + I", hl.dsp.exec_cmd(scripts .. "/converter_imagens.sh"),{ description = "image format conversor" })
hl.bind("SUPER + J", hl.dsp.exec_cmd(scripts .. "/extract_frames.sh"),{ description = "frames extractor" })
hl.bind("SUPER + K", hl.dsp.exec_cmd(scripts .. "/wlsunset.sh"),{ description = "wlsunset" })
hl.bind("SUPER + M", hl.dsp.exec_cmd(scripts .. "/powermenu.sh"),{ description = "power menu" })
hl.bind("SUPER + N", hl.dsp.exec_cmd(scripts .. "/qr.sh"),{ description = "image downloader" })
hl.bind("SUPER + R", hl.dsp.exec_cmd(scripts .. "/refreshWaybar.sh"),{ description = "reload waybar" })
hl.bind("SUPER + S", hl.dsp.exec_cmd(scripts .. "/calendar.sh"),{ description = "calendar notification" })
hl.bind("SUPER + H", hl.dsp.exec_cmd(scripts .. "/random-wallpaper.sh"),{ description = "change wallpaper" })
hl.bind("SUPER + Z", hl.dsp.exec_cmd(scripts .. "/take-screenshot.sh"),{ description = "capture with satty" })
hl.bind("SUPER + V", hl.dsp.exec_cmd(scripts .. "/clipboard_toggle.sh"),{ description = "clipboard" })
hl.bind("SUPER + SHIFT + G", hl.dsp.exec_cmd(scripts .. "/screenrecord.sh"),{ description = "screen recorder" })
hl.bind("SUPER + SHIFT + B", hl.dsp.exec_cmd(scripts .. "/dashboard_toggle.sh"),{ description = "dashboard info" })

hl.bind("SUPER + SHIFT + J", hl.dsp.window.fullscreen({ mode = "fullscreen" }),{ description = "window fullscreen" })
hl.bind("SUPER + Q", hl.dsp.window.close(),{ description = "close window" })
--hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- Focus windows
hl.bind("SUPER + left", hl.dsp.focus({ direction = "l" }),{ description = "focus left window" })
hl.bind("SUPER + right", hl.dsp.focus({ direction = "r" }),{ description = "focus right window" })
hl.bind("SUPER + up", hl.dsp.focus({ direction = "u" }),{ description = "focus up window" })
hl.bind("SUPER + down", hl.dsp.focus({ direction = "d" }),{ description = "focus down window" })

-- Swap windows
hl.bind("SUPER + SHIFT + left",  hl.dsp.window.swap({ direction = "left" }),{ description = "swap left window" })
hl.bind("SUPER + SHIFT + right", hl.dsp.window.swap({ direction = "right" }),{ description = "swap right window" })
hl.bind("SUPER + SHIFT + up",    hl.dsp.window.swap({ direction = "up" }),{ description = "swap up window" })
hl.bind("SUPER + SHIFT + down",  hl.dsp.window.swap({ direction = "down" }),{ description = "swap down window" })

-- Resize windows with keyboard
hl.bind("SUPER + CTRL + left", hl.dsp.window.resize({x=-15, y=0, relative=true}), { description = "resize left window" })
hl.bind("SUPER + CTRL + right", hl.dsp.window.resize({x=15, y=0, relative=true}), { description = "resize right window" })
hl.bind("SUPER + CTRL + up", hl.dsp.window.resize({x=0, y=-15, relative=true}), { description = "resize up window" })
hl.bind("SUPER + CTRL + down", hl.dsp.window.resize({x=0, y=15, relative=true}), { description = "resize down window" })

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
hl.bind("PRINT", hl.dsp.exec_cmd(scripts .. "/screenshot.sh all"),{ description = "capture all" })
hl.bind("SUPER + PRINT", hl.dsp.exec_cmd(scripts .. "/screenshot.sh monitor"),{ description = "capture focused monitor" })
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd(scripts .. "/screenshot.sh region"),{ description = "capture selected region" })
hl.bind("ALT + PRINT", hl.dsp.exec_cmd(scripts .. "/screenshot.sh window"),{ description = "capture selected window" })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"),{ description = "Audio Raise Volume" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),{ description = "Audio Lower Volume" })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),{ description = "Audio Mute" })
hl.bind("XF86MonBrightnessUp",hl.dsp.exec_cmd("brightnessctl set 10%+"),{ description = "Brightness Up" })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl set 10%-"),{ description = "Brightness Down" })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),{ description = "Audio Next" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),{ description = "Audio Pause" })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),{ description = "Audio Play" })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous",{ description = "Audio Previous" }))
