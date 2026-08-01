#!/bin/bash

ART=$(playerctl metadata mpris:artUrl 2>/dev/null)
TITLE=$(playerctl metadata title)
ARTIST=$(playerctl metadata artist)

# baixa capa se for URL
if [[ "$ART" == http* ]]; then
  COVER="/tmp/cover.jpg"
  curl -s "$ART" -o "$COVER"
else
  COVER="$ART"
fi

notify-send -i "$COVER" "$TITLE" "$ARTIST"
