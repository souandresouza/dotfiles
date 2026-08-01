#!/bin/bash

# Contar notificações
count=$(swaync-client -c)
dnd=$(swaync-client -D)

if [ "$dnd" = "true" ]; then
    class="dnd"
    icon=""
else
    class="notification"
    if [ "$count" -gt 0 ]; then
        icon=""
    else
        icon=""
        class="none"
    fi
fi

printf '{"text": "%s", "tooltip": "%s notificações", "class": "%s", "percentage": %s}\n' \
    "$icon" "$count" "$class" "$count"