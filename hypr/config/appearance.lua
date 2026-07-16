local colors = require("config.colors") 
local gaps = 6
local colors = {
    background = colors.inactive_border,
    inactive   = colors.inactive_border,
    active     = colors.active_border,
}

hl.config({
    general = {
        gaps_in = gaps,
        gaps_out = gaps,
        border_size = 4,
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
        
        col = {
            active_border = colors.active_border,
            inactive_border = colors.inactive_border,
        },
    },
    
    decoration = {
        rounding = 2,
        active_opacity = 1,
        inactive_opacity = 1,
        shadow = {
            enabled = true,
            range = 30,
            render_power = 4,
            color = colors.inactive_border,
        },
        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            vibrancy = 0.5
        }
    },
    
    animations = {
        enabled = true
    },
    
    misc = {
        disable_hyprland_logo = true,
        font_family = "JetBrainsMono Nerd Font",
        splash_font_family = "JetBrainsMono Nerd Font"
    }
})

return colors
