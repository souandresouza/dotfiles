-- Launcher
hl.window_rule({
	name = "launcher",
	match = { class = "sway-launcher-desktop" },
	float = true,
	size = { 500, 500 },
	center = true,
	stay_focused = true,
	dim_around = true,
})

-- Power menu
hl.window_rule({name = "powermenu", match = { class = "powermenu" }, float = true, size = { 200, 150 }, center = true,})

-- Suppress maximize events from all apps
hl.window_rule({name = "suppress-maximize-events", match = { class = ".*" }, suppress_event = "maximize",})

-- Fix XWayland drag issues
hl.window_rule({name = "fix-xwayland-drags", match = {class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false,}, no_focus = true,})

-- xwaylandvideobridge fixes
hl.window_rule({name = "xwayland-video-bridge-fixes", match = { class = "xwaylandvideobridge" }, no_initial_focus = true, no_focus = true, no_anim = true, no_blur = true, max_size = { 1, 1 }, opacity = "0.0 override 0.0 override",})

-- Mídia e Editores (Integração com Yazi)
hl.window_rule({name = "yazi-file-chooser", match = { class = "file_chooser" }, float = true, size = { "80%", "80%" }, center = true,})
hl.window_rule({name = "qview-images", match = { class = "[qQ][vV]iew" }, float = true, center = true,})
hl.window_rule({name = "geany-editor", match = { class = "geany" }, float = false, size = { "85%", "85%" }, center = true,})
hl.window_rule({name = "mpv-media", match = { class = "mpv" }, float = true, center = true,})
hl.window_rule({name = "float-blueman", match = { class = "blueman-manager" }, float = true, center = true,})
hl.window_rule({name = "float-pavucontrol", match = { class = "pavucontrol" }, float = true, center = true,})
hl.window_rule({name = "float-bluetui", match = { class = "bluetui" }, float = true, center = true,})
hl.window_rule({name = "float-nmtui", match = { class = "nmtui" }, float = true, center = true,})

-- Dialog windows – float+center these windows.
hl.window_rule({ name = "rule_42", match = { title = "^(Open File)(.*)$" }, center = true })
hl.window_rule({ name = "rule_43", match = { title = "^(Select a File)(.*)$" }, center = true })
hl.window_rule({ name = "rule_45", match = { title = "^(Open Folder)(.*)$" }, center = true })
hl.window_rule({ name = "rule_46", match = { title = "^(Save As)(.*)$" }, center = true })
hl.window_rule({ name = "rule_47", match = { title = "^(Library)(.*)$" }, center = true })
hl.window_rule({ name = "rule_48", match = { title = "^(File Upload)(.*)$" }, center = true })
hl.window_rule({ name = "rule_49", match = { title = "^(.*)(wants to save)$" }, center = true })
hl.window_rule({ name = "rule_50", match = { title = "^(.*)(wants to open)$" }, center = true })
hl.window_rule({ name = "rule_51", match = { title = "^(Open File)(.*)$" }, float = true })
hl.window_rule({ name = "rule_52", match = { title = "^(Select a File)(.*)$" }, float = true })
hl.window_rule({ name = "rule_53", match = { title = "^(Open Folder)(.*)$" }, float = true })
hl.window_rule({ name = "rule_54", match = { title = "^(Save As)(.*)$" }, float = true })
hl.window_rule({ name = "rule_55", match = { title = "^(Library)(.*)$" }, float = true })
hl.window_rule({ name = "rule_56", match = { title = "^(File Upload)(.*)$" }, float = true })
hl.window_rule({ name = "rule_57", match = { title = "^(.*)(wants to save)$" }, float = true })
hl.window_rule({ name = "rule_58", match = { title = "^(.*)(wants to open)$" }, float = true })
