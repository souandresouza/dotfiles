hl.config({
    input = {
        kb_layout = "br",
        numlock_by_default = true,
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
            scroll_factor = 0.8
        },
        repeat_rate = 35,
        repeat_delay = 200,
    },
    cursor = {
        zoom_factor = 1,
        zoom_rigid = false,
        zoom_disable_aa = false,
        hotspot_padding = 1,
        no_hardware_cursors = false,
        inactive_timeout = 1,
        no_warps = false,
        persistent_warps = true,
    },
    gestures = {
        workspace_swipe_touch = false,
    },
    xwayland = {
        force_zero_scaling = true,
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

hl.device({
    name = "instant-usb-gaming-mouse-",
    sensitivity = -0.5,
    natural_scroll = false
})
hl.device({
    name = "bt5.4-mouse",
    sensitivity = -0.5,
    natural_scroll = false
})
