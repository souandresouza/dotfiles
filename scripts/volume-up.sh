#!/bin/bash
wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+

VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o MUTED)

if [ "$MUTED" = "MUTED" ]; then
    notify-send -t 1000 -h string:x-dunst-stack-tag:volume -u low "🔇 Muted"
elif [ $VOLUME -eq 0 ]; then
    notify-send -t 1000 -h string:x-dunst-stack-tag:volume -h int:value:0 -u low "🔈 $VOLUME%"
elif [ $VOLUME -lt 30 ]; then
    notify-send -t 1000 -h string:x-dunst-stack-tag:volume -h int:value:$VOLUME -u low "🔉 $VOLUME%"
elif [ $VOLUME -lt 70 ]; then
    notify-send -t 1000 -h string:x-dunst-stack-tag:volume -h int:value:$VOLUME -u low "🔊 $VOLUME%"
else
    notify-send -t 1000 -h string:x-dunst-stack-tag:volume -h int:value:$VOLUME -u low "🔊 $VOLUME% (Loud!)"
fi
