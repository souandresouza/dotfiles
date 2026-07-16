require("config.autostart")
require("config.binds")
require("config.env")
require("config.input")
require("config.appearance")
require("config.animations")
--require("monitors")
--require("workspaces")
require("config.windowrules")

-- Se a sua versão já usa a sintaxe em Lua (Hyprland 0.55+)
hl.config({
    misc = {
        disable_splash_rendering = true
    }
})

hl.monitor({output = "eDP-1",mode = "1366x768@60.0",position = "0x0",scale = 1.0})
hl.monitor({output = "HDMI-A-1",mode = "1920x1080@100.0",position = "1366x0",scale = 1.0})

hl.workspace_rule({workspace = "1",monitor = "eDP-1",default = true})
hl.workspace_rule({workspace = "2",monitor = "eDP-1"})
hl.workspace_rule({workspace = "3",monitor = "eDP-1"})
hl.workspace_rule({workspace = "4",monitor = "eDP-1"})
hl.workspace_rule({workspace = "5",monitor = "eDP-1"})
hl.workspace_rule({workspace = "6",monitor = "HDMI-A-1",default = true})
hl.workspace_rule({workspace = "7",monitor = "HDMI-A-1"})
hl.workspace_rule({workspace = "8",monitor = "HDMI-A-1"})
hl.workspace_rule({workspace = "9",monitor = "HDMI-A-1"})
hl.workspace_rule({workspace = "10",monitor = "HDMI-A-1"})