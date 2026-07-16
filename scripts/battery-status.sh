#!/bin/bash

battery_path=$(find /sys/class/power_supply -name "BAT*" | head -1)

if [ -z "$battery_path" ]; then
    echo "󰚥 No battery"
    exit 0
fi

capacity=$(cat "$battery_path/capacity")
status=$(cat "$battery_path/status")

# Choose icon based on capacity and status
if [ "$status" = "Charging" ]; then
    icon="󰂄"
else
    if [ $capacity -ge 90 ]; then
        icon="󰁹"
    elif [ $capacity -ge 70 ]; then
        icon="󰂀"
    elif [ $capacity -ge 50 ]; then
        icon="󰁾"
    elif [ $capacity -ge 30 ]; then
        icon="󰁼"
    elif [ $capacity -ge 10 ]; then
        icon="󰁺"
    else
        icon="󰂎"
    fi
fi

echo "$icon $capacity%"