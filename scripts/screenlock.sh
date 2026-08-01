#!/bin/sh

### Lockscreen configuration
# screenlock='swaylock -f -c 173f4f'
screenlock='swaylock -Fefkl -s fill -i $HOME/.cache/current_wallpaper.png'

### Idle configuration
# This will lock your screen after 300 seconds of inactivity
# It will also lock your screen before your computer goes to sleep.
swayidle -w \
    timeout 300 "$screenlock" \
    timeout 360 'swaylock -f -c 000000' \
    before-sleep "$screenlock" &