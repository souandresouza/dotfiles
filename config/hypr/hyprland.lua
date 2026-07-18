require("config.autostart")
require("config.binds")
require("config.env")
require("config.input")
require("config.appearance")
require("config.animations")
require("monitors")
require("workspaces")
require("config.windowrules")

-- Se a sua versão já usa a sintaxe em Lua (Hyprland 0.55+)
hl.config({
    misc = {
        disable_splash_rendering = true
    }
})